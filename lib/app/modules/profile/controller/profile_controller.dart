import 'dart:io';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_endpoints/api_provider.dart';

class ProfileController extends GetxController {
  final ApiProvider apiProvider = Get.find<ApiProvider>();

  // Observable states
  final Rx<Map<String, dynamic>> userData = Rx<Map<String, dynamic>>({});
  final RxBool isLoading = false.obs;
  final RxString profileImagePath = RxString('');
  final RxBool isImageLoading = false.obs;
  final RxInt userId = 0.obs;

  // Constants
  static const String baseUrl = 'https://hayshay.gullygood.com/';

  @override
  void onInit() async {
    super.onInit();
    // Try to get userId from SharedPreferences when controller initializes
    await loadUserIdFromPrefs();
  }

  Future<void> loadUserIdFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getInt('user_id');
      if (storedUserId != null && storedUserId > 0) {
        userId.value = storedUserId;
        print('Loaded userId from SharedPreferences: $storedUserId');
        await getUserData(); // Fetch user data once we have the userId
      } else {
        print('No userId found in SharedPreferences');
      }
    } catch (e) {
      print('Error loading userId from SharedPreferences: $e');
    }
  }

  // Initialize the controller with user ID
  Future<void> initialize(int id) async {
    print('Initializing ProfileController with userId: $id');
    userId.value = id;

    // Save userId to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', id);
      print('Saved userId to SharedPreferences: $id');
    } catch (e) {
      print('Error saving userId to SharedPreferences: $e');
    }

    await getUserData();
  }

  // Get user profile data
  Future<void> getUserData() async {
    print('Fetching user data...');
    if (isLoading.value) {
      print('Already loading data, skipping request');
      return;
    }

    isLoading.value = true;
    try {
      // First try to get userId from state, if not available try from SharedPreferences
      if (userId.value <= 0) {
        await loadUserIdFromPrefs();
        if (userId.value <= 0) {
          print('Invalid userId: ${userId.value}');
          _setDefaultUserData();
          return;
        }
      }

      final response = await apiProvider.getUserProfile(userId.value);
      print('User profile API response: ${response.data}');

      if (response.data != null && response.data is Map<String, dynamic>) {
        final updatedData = Map<String, dynamic>.from(response.data);

        // Handle profile image URL
        if (updatedData['profile'] != null) {
          final relativePath = updatedData['profile'] as String;
          updatedData['profile'] = relativePath.startsWith('http')
              ? relativePath
              : baseUrl + relativePath;
        }

        // Update state
        userData.value = updatedData;
        profileImagePath.value = updatedData['profile'] ?? '';

        print('Updated user data: ${userData.value}');
        update();
      } else {
        print('Invalid response data format');
        _setDefaultUserData();
      }
    } catch (e) {
      print('Error fetching user data: $e');
      _setDefaultUserData();
      Get.snackbar(
        'Error',
        'Failed to fetch user data. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      print('Profile data loading completed');
    }
  }

  // Set default user data when no data is available
  void _setDefaultUserData() {
    userData.value = {
      'fullname': 'User',
      'mobile_number': '',
      'profile': '',
      'email': '',
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

  // Clear user data on logout
  Future<void> clearUserData() async {
    try {
      print('Clearing user data...');
      final prefs = await SharedPreferences.getInstance();

      // Clear essential auth data
      await prefs.remove('user_id');
      await prefs.remove('token');

      // Clear local state
      userId.value = 0;
      userData.value = {};
      profileImagePath.value = '';

      update();
      print('User data cleared successfully');
    } catch (e) {
      print('Error clearing user data: $e');
      Get.snackbar(
        'Error',
        'Failed to clear user data',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Update profile image
  Future<void> updateProfileImage(String imagePath) async {
    print('Updating profile image: $imagePath');
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
      print('Error updating profile image: $e');
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
    print('Removing profile image...');
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
      print('Error removing profile image: $e');
      Get.snackbar(
        'Error',
        'Failed to remove profile image. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Update user profile data
  Future<void> updateUserProfile(Map<String, dynamic> updatedData) async {
    print('Updating user profile with data: $updatedData');
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
      print('Error updating user profile: $e');
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
      if (userData.value[field] != null && userData.value[field].toString().isNotEmpty) {
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