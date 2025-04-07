import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_endpoints/api_endpoints.dart';
import '../../api_endpoints/api_provider.dart';

class ProfileController extends GetxController {
  final ApiProvider apiProvider = Get.find<ApiProvider>();

  // Existing states
  final Rx<Map<String, dynamic>> userData = Rx<Map<String, dynamic>>({});
  final RxBool isLoading = false.obs;
  final RxString profileImagePath = RxString('');
  final RxBool isImageLoading = false.obs;
  final RxInt userId = 0.obs;

  // Vlogs states
  final RxList<Map<String, dynamic>> vlogsList =
      RxList<Map<String, dynamic>>([]);
  final RxBool isVlogsLoading = false.obs;
  final Rx<Map<String, dynamic>> selectedVlog = Rx<Map<String, dynamic>>({});

  @override
  void onInit() {
    super.onInit();
    // Load user data when controller is initialized
    ever(userId, (_) => getUserData());
    loadUserIdFromPrefs();
  }

  // New method to handle API response
  Future<void> fetchVlogs() async {
    if (isVlogsLoading.value) {
      return;
    }

    isVlogsLoading.value = true;
    try {
      // Get token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw 'Authentication token not found';
      }

      final response = await apiProvider.get(
        ApiEndpoints.vlogs,
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true &&
          response.data['data'] is List) {
        final List<Map<String, dynamic>> processedVlogs = [];

        for (var vlog in response.data['data']) {
          // Process the photo URL
          if (vlog['photo'] != null) {
            vlog['photo'] = '${ApiEndpoints.imageBaseUrl}${vlog['photo']}';
          }
          processedVlogs.add(Map<String, dynamic>.from(vlog));
        }

        vlogsList.value = processedVlogs;
        update();
      } else {
        throw 'Failed to load vlogs: ${response.statusCode}';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load vlogs. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      // Clear the list in case of error
      vlogsList.clear();
    } finally {
      isVlogsLoading.value = false;
    }
  }

  void setSelectedVlog(Map<String, dynamic> vlog) {
    selectedVlog.value = vlog;
    update();
  }

  String getVlogImageUrl(String? photoName) {
    if (photoName == null || photoName.isEmpty) {
      return ''; // Return empty string or a default image URL
    }
    return '${ApiEndpoints.imageBaseUrl}$photoName';
  }

  // Helper method to process HTML content if needed
  String processVlogContent(String content) {
    // Remove HTML tags and decode HTML entities
    return content
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&');
  }

  // Navigate to vlogs list
  void navigateToVlogsList() {
    fetchVlogs(); // Start loading the vlogs
    Get.toNamed('/vlogs'); // Navigate to vlogs list screen
  }

  // Navigate to vlog details
  void navigateToVlogDetails(Map<String, dynamic> vlog) {
    setSelectedVlog(vlog);
    Get.toNamed('/vlog-details');
  }

  Future<void> loadUserIdFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getInt('user_id');
      if (storedUserId != null && storedUserId > 0) {
        userId.value = storedUserId;
      } else {
        // Try to get user data anyway if we have a token
        final token = prefs.getString('token');
        if (token != null) {
          await getUserData();
        }
      }
    } catch (e) {
      // Error handled silently
    }
  }

  // Initialize the controller with user ID
  Future<void> initialize(int id) async {
    try {
      // Validate user ID
      if (id <= 0) {
        return;
      }

      // Set user ID
      userId.value = id;

      // Save userId to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', id);

      // Fetch user data
      await getUserData();
    } catch (e, stackTrace) {
      // Optionally show a user-friendly error
      Get.snackbar('Error', 'Could not initialize profile. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> getUserData() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      final response = await apiProvider.getUserProfile(userId.value);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final updatedData = Map<String, dynamic>.from(response.data);

        // Handle profile image URL
        if (updatedData['profile'] != null) {
          final relativePath = updatedData['profile'] as String;
          updatedData['profile'] = relativePath.startsWith('http')
              ? relativePath
              : ApiEndpoints.apibaseUrl + relativePath;
        }

        // Update state with actual user data
        userData.value = updatedData;
        profileImagePath.value = updatedData['profile'] ?? '';

        // Cache the user data
        _cacheUserData(updatedData);

        update();
      } else {
        _loadCachedUserData();
      }
    } catch (e) {
      _loadCachedUserData();
      Get.snackbar(
        'Error',
        'Failed to fetch user data. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Set default user data when no data is available
  void _setDefaultUserData() {
    userData.value = {
      'fullname': 'User',
      'mobile_number': '+91 0123456789',
      'profile': '',
      'email': 'user@gmail.com',
      'ship_address1': '',
      'ship_address2': '',
      'ship_zip': '',
      'ship_city': '',
      'state': '',
      'landmark': '',
      'locality': '',
    };
    update();
  }

  Future<void> _cacheUserData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_user_data', jsonEncode(data));
    } catch (e) {
      // Error handled silently
    }
  }

  Future<void> _loadCachedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_user_data');
      if (cachedData != null) {
        final decodedData = jsonDecode(cachedData) as Map<String, dynamic>;
        userData.value = decodedData;
        profileImagePath.value = decodedData['profile'] ?? '';
        update();
      }
    } catch (e) {
      // Error handled silently
    }
  }

  // Clear user data on logout
  Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear essential auth data
      await prefs.remove('user_id');
      await prefs.remove('token');

      // Clear local state
      userId.value = 0;
      userData.value = {};
      profileImagePath.value = '';

      update();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear user data',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Update profile image
  Future<void> updateProfileImage(String imagePath) async {
    isImageLoading.value = true;

    try {
      if (userId.value <= 0) {
        throw 'Invalid user ID';
      }

      final imageFile = File(imagePath);
      final response = await apiProvider.updateUserProfile(
        userId.value,
        {},
        profileImage: imageFile,
      );

      if (response.statusCode == 200) {
        await getUserData();
        Get.snackbar(
          'Success',
          'Profile image updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw 'Failed to update profile image';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile image. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isImageLoading.value = false;
    }
  }

  // Remove profile image
  Future<void> removeProfileImage() async {
    try {
      if (userId.value <= 0) {
        throw 'Invalid user ID';
      }

      final response = await apiProvider.updateUserProfile(
        userId.value,
        {'profile': null},
      );

      if (response.statusCode == 200) {
        await getUserData();
        Get.snackbar(
          'Success',
          'Profile image removed successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw 'Failed to remove profile image';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove profile image. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Update user profile data
  Future<void> updateUserProfile(Map<String, dynamic> updatedData) async {
    isLoading.value = true;

    try {
      if (userId.value <= 0) {
        throw 'Invalid user ID';
      }

      final response = await apiProvider.updateUserProfile(
        userId.value,
        updatedData,
      );

      if (response.statusCode == 200) {
        await getUserData();
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw 'Failed to update profile';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get current user data
  Map<String, dynamic> getCurrentUserData() {
    return userData.value;
  }

  // Check if user data is loaded
  bool isUserDataLoaded() {
    return userData.value.isNotEmpty && userData.value['fullname'] != 'User';
  }

  // Get profile completion percentage
  double getProfileCompletionPercentage() {
    if (!isUserDataLoaded()) return 0.0;

    final requiredFields = [
      'fullname',
      'mobile_number',
      'email',
      'ship_address1',
      'ship_zip',
      'ship_city',
      'state',
    ];

    int filledFields = 0;
    for (var field in requiredFields) {
      if (userData.value[field] != null &&
          userData.value[field].toString().isNotEmpty) {
        filledFields++;
      }
    }

    return (filledFields / requiredFields.length) * 100;
  }

  // Validate email format
  bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(email);
  }

  // Format phone number
  String formatPhoneNumber(String phone) {
    if (phone.length == 10) {
      return '${phone.substring(0, 5)} ${phone.substring(5)}';
    }
    return phone;
  }

  @override
  void onClose() {
    // Clean up if needed
    super.onClose();
  }
}
