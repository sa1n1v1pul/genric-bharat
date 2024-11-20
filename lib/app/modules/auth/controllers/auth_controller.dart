// auth_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_endpoints/api_provider.dart';
import '../../cart/controller/cartcontroller.dart';
import '../../cart/controller/cartservice.dart';

import 'login_controller.dart';

class AuthController extends GetxController {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final pageController = PageController();
  final leftColor = Colors.black.obs;
  final rightColor = Colors.white.obs;
  final isLoggedIn = false.obs;
  final Rx<String> userPhone = ''.obs;
  final Rx<Map<String, dynamic>> userData = Rx<Map<String, dynamic>>({});

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
    loadUserPhone();
    // Listen to login status changes
    ever(isLoggedIn, _handleAuthStateChange);
  }

  void _handleAuthStateChange(bool loggedIn) async {
    if (loggedIn) {
      await _initializeCartServices();
    } else {
      _cleanupCartServices();
    }
  }

  Future<void> _initializeCartServices() async {
    try {
      print('Initializing cart services after login...');

      // Initialize CartApiService if not already initialized
      if (!Get.isRegistered<CartApiService>()) {
        final cartService = Get.put(CartApiService());
        await cartService.initializeService();
        print('✓ Cart service initialized');
      }

      // Initialize or reinitialize CartController
      if (Get.isRegistered<CartController>()) {
        Get.delete<CartController>(force: true);
      }


      await Future.delayed(Duration(milliseconds: 200));
      final cartController = Get.put(CartController());
      await cartController.initializeCart();
      // Wait a bit to ensure userId is available
      print('✓ Cart controller initialized');
    } catch (e) {
      print('❌ Error initializing cart services: $e');
    }
  }

  void _cleanupCartServices() {
    try {
      print('Cleaning up cart services...');
      if (Get.isRegistered<CartController>()) {
        Get.delete<CartController>();
      }
      print('✓ Cart services cleaned up');
    } catch (e) {
      print('❌ Error cleaning up cart services: $e');
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    isLoggedIn.value = token != null && token.isNotEmpty;
    if (isLoggedIn.value) {
      await getUserData();
    }
  }

  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    isLoggedIn.value = true;
  }

  Future<void> setUserPhone(String phone) async {
    userPhone.value = phone;
    await saveUserPhone(phone);
  }

  Future<void> saveUserPhone(String phone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_phone', phone);
  }

  Future<void> loadUserPhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phone = prefs.getString('user_phone');
    if (phone != null) {
      userPhone.value = phone;
    }
  }

  Future<void> getUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      if (userId != null) {
        final response = await _apiProvider.getUserProfile(userId);
        userData.value = response.data;

        await prefs.setString('user_name', userData.value['fullname'] ?? '');
        await prefs.setString('user_email', userData.value['email'] ?? '');
        await prefs.setString('user_mobile', userData.value['mobile_number'] ?? '');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> logout() async {
    // Clean up cart services before clearing user data
    _cleanupCartServices();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_phone');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_mobile');

    isLoggedIn.value = false;
    userData.value = {};

    Get.find<LoginController>().resetState();
    Get.offAllNamed('/auth');
  }
}