// ignore_for_file: avoid_print, unused_local_variable

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:genric_bharat/app/modules/auth/controllers/appstatecontroller.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../api_endpoints/api_endpoints.dart';
import '../../api_endpoints/api_provider.dart';
import '../../onboarding/on_boarding_view.dart';
import '../../prescription/controller/prescriptioncontroller.dart';
import '../../profile/controller/profile_controller.dart';
import '../../cart/controller/cartcontroller.dart';
import '../../cart/controller/cartservice.dart';
import 'auth_controller.dart';

class LoginController extends GetxController with CodeAutoFill {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final AuthController _authController = Get.find<AuthController>();
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Controllers
  final mergedController = TextEditingController();
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final phoneController = TextEditingController();
  final phoneOtpController = TextEditingController();

  // Observable variables
  final isOtpSent = false.obs;
  final isPhoneOtpSent = false.obs;
  final isLoading = false.obs;
  final otpMessage = ''.obs;
  final displayedOtp = ''.obs;
  final userId = RxnInt();
  final otpResendTimer = 60.obs;
  final _smsAutoFill = SmsAutoFill();
  bool _isPluginInitialized = false;

  // Private variables
  Timer? _timer;
  String? _verificationId;

  @override
  void onInit() async {
    super.onInit();
    await checkExistingLogin();
    await _initializeSmsPlugin();
  }

  Future<void> processAuthentication(int userId) async {
    try {
      isLoading.value = true;

      // First clean up existing controllers
      await Get.delete<CartController>(force: true);
      await Get.delete<ProfileController>(force: true);

      // Initialize AppStateController if not already initialized
      if (!Get.isRegistered<AppStateController>()) {
        Get.put(AppStateController());
      }

      // Initialize app state with proper error handling
      await AppStateController.to
          .initializeApp(userId: userId)
          .catchError((error) {
        // print('Error initializing app state: $error');
        throw error; // Rethrow to be caught by outer try-catch
      });

      // Only navigate if initialization was successful
      Get.off(() => const OnBoardingView());
    } catch (e) {
      // print('Error processing authentication: $e');
      Get.snackbar(
        'Error',
        'Failed to initialize app. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _initializeSmsPlugin() async {
    try {
      final appSignature = await SmsAutoFill().getAppSignature;
      print('SMS App Signature: $appSignature');
      _isPluginInitialized = true;

      // Listen for SMS right after initialization
      listenForCode();
    } catch (e) {
      print('Failed to initialize SMS plugin: $e');
      _isPluginInitialized = false;
    }
  }

  @override
  void codeUpdated() {
    try {
      if (code != null) {
        // print('Received OTP: $code');
        phoneOtpController.text = code!;
        // Add a small delay to ensure UI updates
        Future.delayed(const Duration(milliseconds: 100), () {
          verifyPhoneOtp();
        });
      }
    } catch (e) {
      // print('Error updating code: $e');
    }
  }

  @override
  void listenForCode({String? smsCodeRegexPattern}) {
    if (!_isPluginInitialized) return;

    try {
      SmsAutoFill().listenForCode;
      print('Started listening for SMS code');
    } catch (e) {
      print('Error in listenForCode: $e');
    }
  }

  void handleInputChange(String value) {
    // Clear existing values
    emailController.clear();
    phoneController.clear();

    // Check if input is email or phone
    if (value.contains('@')) {
      emailController.text = value;
    } else {
      // Remove any non-numeric characters
      final numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
      phoneController.text = numericValue;
    }
  }

  void handleSubmit() {
    if (emailController.text.isNotEmpty) {
      if (isValidEmail(emailController.text)) {
        requestOtp();
      } else {
        Get.snackbar('Error', 'Please enter a valid email address');
      }
    } else if (phoneController.text.isNotEmpty) {
      if (isValidPhoneNumber(phoneController.text)) {
        sendPhoneOtp();
      } else {
        Get.snackbar('Error', 'Please enter a valid phone number');
      }
    } else {
      Get.snackbar('Error', 'Please enter email or phone number');
    }
  }

  void startOtpResendTimer() {
    otpResendTimer.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpResendTimer.value > 0) {
        otpResendTimer.value--;
      } else {
        timer.cancel();
      }
    });
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isValidPhoneNumber(String phoneNumber) {
    return RegExp(r'^[6-9]\d{9}$').hasMatch(phoneNumber);
  }

  Future<void> sendPhoneOtp() async {
    if (!isValidPhoneNumber(phoneController.text)) {
      Get.snackbar('Error', 'Please enter a valid phone number');
      return;
    }

    isLoading.value = true;
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+91${phoneController.text}',
        timeout: const Duration(seconds: 60),
        forceResendingToken: null, // Add this
        autoRetrievedSmsCodeForTesting: null, // Add this for production
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('Auto verification completed');
          if (credential.smsCode != null) {
            phoneOtpController.text = credential.smsCode!;
            await verifyPhoneOtp();
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed: ${e.message}');
          isLoading.value = false;
          isPhoneOtpSent.value = false;
          Get.snackbar('Error', e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          print('OTP sent successfully');
          _verificationId = verificationId;
          isPhoneOtpSent.value = true;
          isLoading.value = false;
          startOtpResendTimer();
          listenForCode();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          isLoading.value = false;
        },
      );
    } catch (e) {
      print('Phone OTP Error: $e');
      isLoading.value = false;
      isPhoneOtpSent.value = false;
      Get.snackbar('Error', 'Failed to send OTP. Please try again.');
    }
  }

  Future<void> verifyPhoneOtp() async {
    if (phoneOtpController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter OTP');
      return;
    }

    if (_verificationId == null) {
      Get.snackbar('Error', 'Please request OTP first');
      return;
    }

    isLoading.value = true;
    try {
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: phoneOtpController.text,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        await processPhoneAuthentication(user);
      } else {
        throw Exception('User authentication failed');
      }
    } catch (e) {
      print('OTP Verification Error: $e');
      isLoading.value = false;
      Get.snackbar('Error', 'Invalid OTP. Please try again.');
    }
  }

  Future<void> requestOtp() async {
    if (!isValidEmail(emailController.text)) {
      Get.snackbar('Error', 'Please enter a valid email address');
      return;
    }

    isLoading.value = true;
    try {
      final response = await _apiProvider.requestOtp(emailController.text);
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          isOtpSent.value = true;
          otpMessage.value = responseData['message'] ?? 'OTP sent successfully';
          userId.value = responseData['id'];
          startOtpResendTimer();
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
      final response = await _apiProvider.getOtp(emailController.text);
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
        emailController.text,
        otpController.text,
        userId.value,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          if (Get.isRegistered<CartController>()) {
            Get.delete<CartController>(force: true);
          }

          String token = responseData['token'] ?? '';
          await _authController.saveToken(token);
          await _authController.setUserEmail(emailController.text);

          final userIdFromResponse = responseData['user']['id'];
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', userIdFromResponse);

          await processAuthentication(userIdFromResponse);

          // await initializeControllers(userIdFromResponse);
          Get.off(() => const OnBoardingView());
        } else {
          Get.snackbar('Error', responseData['message'] ?? 'Invalid OTP');
        }
      } else {
        Get.snackbar('Error', 'Failed to verify OTP. Please try again.');
      }
    } catch (e) {
      // print('Error in verifyOtp: $e');
      Get.snackbar('Error', 'An error occurred. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      // First sign out from both Firebase and Google
      await _auth.signOut();
      await _googleSignIn.signOut();

      // Create a new instance of GoogleSignIn with forced account picker
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        signInOption: SignInOption.standard, // Forces account picker
      );

      // Attempt to sign in and show account picker
      final GoogleSignInAccount? gUser = await googleSignIn.signIn();
      if (gUser == null) {
        isLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to get user details from Firebase');
      }

      final String? firebaseToken = await user.getIdToken();
      if (firebaseToken == null) {
        throw Exception('Failed to get Firebase token');
      }

      try {
        final checkUserResponse = await _apiProvider.get(
          '${ApiEndpoints.apibaseUrl}google-user-get?email=${user.email}',
        );

        int userIdToUse;
        Map<String, dynamic> userData;

        if (checkUserResponse.statusCode == 200) {
          userData = checkUserResponse.data['data'];
          userIdToUse = userData['id'];
        } else if (checkUserResponse.statusCode == 404) {
          final createUserResponse = await _apiProvider.post(
            '${ApiEndpoints.apibaseUrl}google-user-post',
            {
              'name': user.displayName ?? '',
              'email': user.email ?? '',
              'google_id': user.uid,
            },
          );

          if (createUserResponse.statusCode == 201) {
            userData = createUserResponse.data['data'];
            userIdToUse = userData['id'];
          } else {
            throw Exception(
                'Failed to create new user: ${createUserResponse.statusCode}');
          }
        } else {
          throw Exception(
              'Unexpected response checking user: ${checkUserResponse.statusCode}');
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', firebaseToken);
        await prefs.setString('user_email', user.email ?? '');
        await prefs.setString('user_name', user.displayName ?? '');
        await prefs.setInt('user_id', userIdToUse);

        await _authController.saveToken(firebaseToken);
        await _authController.setUserEmail(user.email ?? '');

        if (userIdToUse != null) {
          await processAuthentication(userIdToUse);
        }
        Get.off(() => const OnBoardingView());
      } catch (e) {
        print('API Error: $e');
        await googleSignIn.signOut();
        await _auth.signOut();
        throw Exception('Failed to process user data: $e');
      }
    } catch (e) {
      print('Google Sign In Error: $e');
      // Clean up on error
      await _googleSignIn.signOut();
      await _auth.signOut();
      Get.snackbar(
        'Error',
        'Failed to sign in with Google. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> processPhoneAuthentication(firebase_auth.User user) async {
    try {
      final checkUserResponse = await _apiProvider.get(
        '${ApiEndpoints.apibaseUrl}get-phone-user?phone=${phoneController.text}',
      );

      int userIdToUse;
      Map<String, dynamic> userData;

      if (checkUserResponse.statusCode == 200) {
        userData = checkUserResponse.data['data'];
        userIdToUse = userData['id'];
      } else if (checkUserResponse.statusCode == 404) {
        final createUserResponse = await _apiProvider.post(
          '${ApiEndpoints.apibaseUrl}phone-user',
          {
            'name': user.displayName ?? '',
            'phone': phoneController.text,
            'firebase_uid': user.uid,
          },
        );

        if (createUserResponse.statusCode == 201) {
          userData = createUserResponse.data['data'];
          userIdToUse = userData['id'];
        } else {
          throw Exception(
              'Failed to create new user: ${createUserResponse.statusCode}');
        }
      } else {
        throw Exception(
            'Unexpected response checking user: ${checkUserResponse.statusCode}');
      }

      final prefs = await SharedPreferences.getInstance();
      final firebaseToken = await user.getIdToken();
      await prefs.setString('token', firebaseToken ?? '');
      await prefs.setString('user_phone', phoneController.text);
      await prefs.setInt('user_id', userIdToUse);

      await _authController.saveToken(firebaseToken ?? '');
      await _authController.setUserPhone(phoneController.text);

      if (userIdToUse != null) {
        await processAuthentication(userIdToUse);
      }

      Get.off(() => const OnBoardingView());
    } catch (e) {
      print('Phone Authentication Error: $e');
      await _auth.signOut();
      throw Exception('Failed to process user data: $e');
    }
  }

  Future<void> initializeControllers(int userId) async {
    try {
      print('Initializing controllers for userId: $userId');

      // Clear existing cart controller if present
      if (Get.isRegistered<CartController>()) {
        Get.delete<CartController>(force: true);
      }

      // Initialize services and controllers
      await Future.wait([
        // Initialize CartApiService
        () async {
          if (!Get.isRegistered<CartApiService>()) {
            final cartService = Get.put(CartApiService());
            await cartService.initializeService();
          }
        }(),

        // Initialize or reinitialize ProfileController
        () async {
          if (!Get.isRegistered<ProfileController>()) {
            final profileController = Get.put(ProfileController());
            await profileController.initialize(userId);
          } else {
            final profileController = Get.find<ProfileController>();
            await profileController.initialize(userId);
          }
        }(),

        // Initialize or reinitialize PrescriptionController
        () async {
          if (!Get.isRegistered<PrescriptionController>()) {
            final prescriptionController = Get.put(PrescriptionController());
            await prescriptionController.initialize(userId);
          } else {
            final prescriptionController = Get.find<PrescriptionController>();
            await prescriptionController.initialize(userId);
          }
        }(),
      ]);

      // Initialize CartController last
      final cartController = Get.put(CartController());
      cartController.currentUserId = userId;
      await cartController.initializeCart(userId: userId);

      print('✓ All controllers initialized successfully');
    } catch (e) {
      print('Error initializing controllers: $e');
      throw Exception('Failed to initialize controllers: $e');
    }
  }

  Future<void> checkExistingLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getInt('user_id');
      final storedToken = prefs.getString('token');

      if (storedUserId != null && storedToken != null) {
        await initializeControllers(storedUserId);
      }
    } catch (e) {
      print('Error checking existing login: $e');
      // Clear stored data if check fails
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }
  }

  void resetState() {
    isOtpSent.value = false;
    isLoading.value = false;
    emailController.clear();
    otpController.clear();
    displayedOtp.value = '';
  }

  void resetPhoneState() {
    isPhoneOtpSent.value = false;
    isLoading.value = false;
    phoneController.clear();
    phoneOtpController.clear();
    _verificationId = null;
  }

  @override
  void onClose() {
    if (_isPluginInitialized) {
      try {
        SmsAutoFill().unregisterListener();
      } catch (e) {
        print('Error unregistering SMS listener: $e');
      }
    }
    _timer?.cancel();
    emailController.dispose();
    otpController.dispose();
    phoneController.dispose();
    phoneOtpController.dispose();
    super.onClose();
  }
}
