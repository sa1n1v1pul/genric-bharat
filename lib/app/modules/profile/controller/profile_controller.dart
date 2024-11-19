import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_endpoints/api_provider.dart';

class ProfileController extends GetxController {
  final ApiProvider apiProvider = Get.find<ApiProvider>();
  final Rx<Map<String, dynamic>> userData = Rx<Map<String, dynamic>>({});
  final RxBool isLoading = false.obs;
  final RxString profileImagePath = RxString('');

  @override
  void onInit() {
    super.onInit();
    getUserData();
    loadProfileImagePath();
  }

  Future<void> loadProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    profileImagePath.value = prefs.getString('profile_image_path') ?? '';
  }

  Future<void> saveProfileImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', path);
    profileImagePath.value = path;
  }

  Future<void> removeProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_image_path');
    profileImagePath.value = '';
  }

  Future<void> getUserData() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      if (userId != null) {
        final response = await apiProvider.getUserProfile(userId);
        userData.value = response.data;
        await saveUserDataToPrefs(userData.value);
      }
    } catch (e) {
      print('Error fetching user data: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch user data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> updatedData) async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      if (userId != null) {
        final response = await apiProvider.updateUserProfile(userId, updatedData);
        if (response.statusCode == 200) {
          userData.value = response.data;
          await saveUserDataToPrefs(userData.value);
          Get.snackbar(
            'Success',
            'Profile updated successfully',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.snackbar(
            'Error',
            'Failed to update profile',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      print('Error updating user profile: $e');
      Get.snackbar(
        'Error',
        'An error occurred while updating profile',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveUserDataToPrefs(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', data['fullname'] ?? '');
    await prefs.setString('user_email', data['email'] ?? '');
    await prefs.setString('user_mobile', data['mobile_number'] ?? '');
    await prefs.setString('profile_url', data['profile'] ?? '');
  }
}