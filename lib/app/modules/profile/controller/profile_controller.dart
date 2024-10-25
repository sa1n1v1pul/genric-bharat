import 'package:get/get.dart';
import 'package:handyman/app/modules/api_endpoints/api_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  final Rx<Map<String, dynamic>> userData = Rx<Map<String, dynamic>>({});
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getUserData();
  }

  Future<void> getUserData() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      if (userId != null) {
        final response = await _apiProvider.getUserProfile(userId);
        userData.value = response.data;

        // Save user data to SharedPreferences
        await _saveUserDataToPrefs(userData.value);
      }
    } catch (e) {
      print('Error fetching user data: $e');
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
        final response =
            await _apiProvider.updateUserProfile(userId, updatedData);
        if (response.statusCode == 200) {
          userData.value = response.data;
          await _saveUserDataToPrefs(userData.value);
          Get.snackbar('Success', 'Profile updated successfully');
        } else {
          Get.snackbar('Error', 'Failed to update profile');
        }
      } else {
        Get.snackbar('Error', 'User ID not found');
      }
    } catch (e) {
      print('Error updating user profile: $e');
      Get.snackbar('Error', 'An error occurred while updating profile');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveUserDataToPrefs(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', data['fullname'] ?? '');
    await prefs.setString('user_email', data['email'] ?? '');
    await prefs.setString('user_mobile', data['mobile_number'] ?? '');
    await prefs.setString('user_title', data['title'] ?? '');
  }
}
