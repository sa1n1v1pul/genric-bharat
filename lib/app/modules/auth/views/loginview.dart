import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genric_bharat/app/modules/auth/controllers/login_controller.dart';
import 'package:genric_bharat/app/modules/cart/controller/cartcontroller.dart';
import 'package:genric_bharat/app/modules/cart/controller/cartservice.dart';
import 'package:genric_bharat/app/modules/onboarding/on_boarding_view.dart';
import 'package:genric_bharat/app/modules/profile/controller/profile_controller.dart';

import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(builder: (controller) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/login.jpg'),
              fit: BoxFit.cover,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.45,
                left: MediaQuery.of(context).size.width * 0.1,
                right: MediaQuery.of(context).size.width * 0.1,
                bottom: 0,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(
                      children: [
                        _buildLoginSection(),
                        const SizedBox(height: 20),
                        const Text(
                          'OR',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildGoogleSignInButton(),
                        const SizedBox(height: 30),
                        _buildSkipLoginButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // New method for Skip Login button
  Widget _buildSkipLoginButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 25),
        child: TextButton(
          onPressed: () async {
            try {
              if (Get.isRegistered<CartController>()) {
                await Get.delete<CartController>(force: true);
              }
              if (Get.isRegistered<ProfileController>()) {
                await Get.delete<ProfileController>(force: true);
              }

              if (!Get.isRegistered<CartApiService>()) {
                final cartService = Get.put(CartApiService());
                await cartService.initializeService();
              }

              Get.off(() => const OnBoardingView());
            } catch (e) {
              print('Error during skip: $e');
              Get.snackbar(
                'Error',
                'Something went wrong. Please try again.',
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Skip Login',
                style: TextStyle(
                  color: Color(0xffE15564),
                  fontFamily: 'WorkSansBold',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xffE15564),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.7),
            Colors.white.withOpacity(0.3),
          ],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Login',
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
                fontFamily: 'WorkSansBold',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Obx(() =>
              controller.isOtpSent.value || controller.isPhoneOtpSent.value
                  ? _buildOtpInput()
                  : _buildMergedInput()),
          const SizedBox(height: 12),

          // Combined OTP Status and Resend Button
          Obx(() {
            if (controller.isOtpSent.value || controller.isPhoneOtpSent.value) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildResendButton(),
              );
            }
            return const SizedBox.shrink();
          }),

          const SizedBox(height: 15),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildMergedInput() {
    return Center(
      child: Container(
        height: 45,
        width: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.8),
            ],
          ),
        ),
        child: TextField(
          controller: controller.mergedController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(color: Color(0xffE15564)),
            ),
            hintText: 'Enter Email or 10 Digits Phone no.',
            hintStyle: const TextStyle(fontSize: 13),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 20,
            ),
            errorStyle: const TextStyle(height: 0),
          ),
          cursorColor: const Color(0xffE15564),
          style: const TextStyle(color: Colors.black, fontSize: 15),
          keyboardType: TextInputType.text,
          onChanged: (value) => controller.handleInputChange(value),
        ),
      ),
    );
  }

  Widget _buildOtpInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: PinCodeTextField(
        appContext: Get.context!,
        length: 6,
        obscureText: false,
        animationType: AnimationType.fade,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(8),
          fieldHeight: 40,
          fieldWidth: 35,
          activeFillColor: Colors.white.withOpacity(0.9),
          inactiveFillColor: Colors.white.withOpacity(0.7),
          selectedFillColor: Colors.white,
          activeColor: const Color(0xffE15564),
          inactiveColor: Colors.grey.shade300,
          selectedColor: const Color(0xffE15564),
        ),
        animationDuration: const Duration(milliseconds: 300),
        enableActiveFill: true,
        controller: controller.isPhoneOtpSent.value
            ? controller.phoneOtpController
            : controller.otpController,
        onCompleted: (v) {
          if (controller.isPhoneOtpSent.value) {
            controller.phoneOtpController.text = v;
          } else {
            controller.otpController.text = v;
          }
        },
        onChanged: (value) {
          if (controller.isPhoneOtpSent.value) {
            controller.phoneOtpController.text = value;
          } else {
            controller.otpController.text = value;
          }
        },
        beforeTextPaste: (text) => true,
        keyboardType: TextInputType.number,
        // Add this for auto-fill support
        autoDismissKeyboard: true,
      ),
    );
  }

  Widget _buildResendButton() {
    return Obx(() => Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  controller.otpResendTimer.value == 0
                      ? const Color(0xffE15564).withOpacity(0.8)
                      : Colors.grey.withOpacity(0.5),
                  controller.otpResendTimer.value == 0
                      ? const Color(0xffE15564).withOpacity(0.6)
                      : Colors.grey.withOpacity(0.3),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: TextButton(
              onPressed: controller.otpResendTimer.value == 0
                  ? () {
                      if (controller.isPhoneOtpSent.value) {
                        controller.sendPhoneOtp();
                      } else {
                        controller.requestOtp();
                      }
                    }
                  : null,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                controller.otpResendTimer.value == 0
                    ? 'Resend OTP'
                    : 'Resend OTP in ${controller.otpResendTimer.value}s',
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'WorkSansBold',
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildActionButton() {
    return Center(
      child: Container(
        height: 40,
        width: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xffE15564), Color(0xffE13664)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xffE15564).withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Obx(
          () => controller.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : ElevatedButton(
                  onPressed: () {
                    if (controller.isOtpSent.value) {
                      controller.verifyOtp();
                    } else if (controller.isPhoneOtpSent.value) {
                      controller.verifyPhoneOtp();
                    } else {
                      controller.handleSubmit();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    _getButtonText(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'WorkSansBold',
                      fontSize: 15,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  String _getButtonText() {
    if (controller.isOtpSent.value || controller.isPhoneOtpSent.value) {
      return 'Verify';
    }
    return 'Send OTP';
  }

  Widget _buildGoogleSignInButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.7),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: controller.signInWithGoogle,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/googlelogo.png',
                    height: 24,
                    width: 24,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Sign in with Google',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
