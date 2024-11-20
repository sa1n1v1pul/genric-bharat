import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_endpoints/api_provider.dart';
import '../../onboarding/on_boarding_view.dart';
import 'auth_controller.dart';

class LoginController extends GetxController {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final AuthController _authController = Get.find<AuthController>();

  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  final isOtpSent = false.obs;
  final isLoading = false.obs;
  final otpMessage = ''.obs;
  final displayedOtp = ''.obs;
  final userId = RxnInt();

  Future<void> requestOtp() async {
    if (phoneController.text.length != 10) {
      Get.snackbar('Error', 'Please enter a valid 10-digit phone number');
      return;
    }

    isLoading.value = true;
    try {
      final response = await _apiProvider.requestOtp(phoneController.text);
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          isOtpSent.value = true;
          otpMessage.value = responseData['message'] ?? 'OTP sent successfully';
          userId.value = responseData['id'];
          await getOtp();
        } else {
          Get.snackbar('Error', responseData['message'] ?? 'Failed to send OTP');
        }
      } else {
        Get.snackbar('Error', 'Failed to send OTP. Please try again.');
      }
    } catch (e) {
      print('Error in requestOtp: $e');
      Get.snackbar('Error', 'An error occurred. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getOtp() async {
    try {
      final response = await _apiProvider.getOtp(phoneController.text);
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null && responseData['otp'] != null) {
          displayedOtp.value = responseData['otp'].toString();
        } else {
          Get.snackbar('Error', 'Failed to retrieve OTP. Please try again.');
        }
      } else {
        Get.snackbar('Error', 'Failed to retrieve OTP. Please try again.');
      }
    } catch (e) {
      print('Error in getOtp: $e');
      Get.snackbar('Error', 'An error occurred while retrieving OTP.');
    }
  }

  Future<void> verifyOtp() async {
    if (otpController.text.length != 6) {
      Get.snackbar('Error', 'Please enter a valid 6-digit OTP');
      return;
    }

    isLoading.value = true;
    try {
      final response = await _apiProvider.verifyOtp(
        phoneController.text,
        otpController.text,
        userId.value,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          // Save user data
          String token = responseData['token'] ?? '';
          await _authController.saveToken(token);
          await _authController.setUserPhone(phoneController.text);

          // Save user ID
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', responseData['user']['id']);

          // Fetch user data and initialize cart
          await _authController.getUserData();

          Get.off(() => const OnBoardingView());
        } else {
          Get.snackbar('Error', responseData['message'] ?? 'Invalid OTP');
        }
      } else {
        Get.snackbar('Error', 'Failed to verify OTP. Please try again.');
      }
    } catch (e) {
      print('Error in verifyOtp: $e');
      Get.snackbar('Error', 'An error occurred. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void resetState() {
    isOtpSent.value = false;
    isLoading.value = false;
    phoneController.clear();
    otpController.clear();
    displayedOtp.value = '';
  }

  @override
  void onClose() {
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }
}