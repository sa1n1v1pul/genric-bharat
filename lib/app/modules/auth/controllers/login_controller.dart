import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_endpoints/api_provider.dart';
import '../../onboarding/on_boarding_view.dart';
import '../../prescription/controller/prescriptioncontroller.dart';
import '../../profile/controller/profile_controller.dart';
import '../../cart/controller/cartcontroller.dart';
import '../../cart/controller/cartservice.dart';
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

  @override
  void onInit() async {
    super.onInit();
    // Check if user is already logged in
    await checkExistingLogin();
  }

  Future<void> checkExistingLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getInt('user_id');
      final storedToken = prefs.getString('token');

      if (storedUserId != null && storedToken != null) {
        // User is already logged in, initialize controllers
        await initializeControllers(storedUserId);
      }
    } catch (e) {
      print('Error checking existing login: $e');
    }
  }

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
          Get.snackbar(
              'Error', responseData['message'] ?? 'Failed to send OTP');
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

  Future<void> initializeControllers(int userId) async {
    try {
      print('Initializing controllers for userId: $userId');

      // Initialize CartApiService
      if (!Get.isRegistered<CartApiService>()) {
        final cartService = Get.put(CartApiService());
        await cartService.initializeService();
        print('✓ CartApiService initialized');
      }

      // Initialize ProfileController
      if (!Get.isRegistered<ProfileController>()) {
        final profileController = Get.put(ProfileController());
        await profileController.initialize(userId);
        print('✓ ProfileController initialized');
      } else {
        final profileController = Get.find<ProfileController>();
        await profileController.initialize(userId);
        print('✓ Existing ProfileController reinitialized');
      }

      // Initialize PrescriptionController
      if (!Get.isRegistered<PrescriptionController>()) {
        final prescriptionController = Get.put(PrescriptionController());
        await prescriptionController.initialize(userId);
        print('✓ PrescriptionController initialized');
      } else {
        final prescriptionController = Get.find<PrescriptionController>();
        await prescriptionController.initialize(userId);
        print('✓ Existing PrescriptionController reinitialized');
      }

      // Initialize CartController with explicit user ID
      if (Get.isRegistered<CartController>()) {
        Get.delete<CartController>(force: true);
      }

      final cartController = Get.put(CartController());
      cartController.currentUserId = userId;
      await cartController.initializeCart(userId: userId);
      print('✓ CartController initialized with explicit userId');
    } catch (e) {
      print('Error initializing controllers: $e');
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
          if (Get.isRegistered<CartController>()) {
            Get.delete<CartController>(force: true);
          }
          // Save user data
          String token = responseData['token'] ?? '';
          await _authController.saveToken(token);
          await _authController.setUserPhone(phoneController.text);

          // Get and save user ID
          final userIdFromResponse = responseData['user']['id'];
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', userIdFromResponse);

          // Initialize controllers with the new user ID
          await initializeControllers(userIdFromResponse);

          // Navigate to onboarding
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
