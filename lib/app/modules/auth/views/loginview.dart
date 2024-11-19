import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart'; // Add this import

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
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
                  child: itemsLogin(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column itemsLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Login',
            style: TextStyle(
                fontSize: 19,
                color: Colors.black,
                fontFamily: 'WorkSansBold',
                fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() =>
        controller.isOtpSent.value ? _buildOtpInput() : _buildPhoneInput()),
        const SizedBox(height: 8),
        Obx(() => controller.isOtpSent.value
            ? Center(
          child: Text(
            'OTP sent to your mobile number: ${controller.displayedOtp.value}',
            style: const TextStyle(
                color: Colors.black, fontFamily: 'WorkSansBold'),
          ),
        )
            : const SizedBox.shrink()),
        const SizedBox(height: 15),
        Center(
          child: SizedBox(
            height: 35,
            width: 110,
            child: Obx(() => controller.isLoading.value
                ? const CircularProgressIndicator(color: Colors.blue)
                : DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xffE15564),
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextButton(
                onPressed: controller.isOtpSent.value
                    ? controller.verifyOtp
                    : controller.requestOtp,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  minimumSize: const Size.fromHeight(35),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  controller.isOtpSent.value ? 'Submit' : 'Send OTP',
                  style: const TextStyle(
                      color: Colors.white, fontFamily: 'WorkSansBold'),
                ),
              ),
            )),
          ),
        )
      ],
    );
  }

  Widget _buildPhoneInput() {
    return Center(
      child: SizedBox(
        height: 34,
        width: 250,
        child: TextField(
          controller: controller.phoneController,
          decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(50)),
              borderSide: BorderSide(
                color: Color(0xffE15564),
              ),
            ),
            prefix: Container(
              width: 40,
              alignment: Alignment.center,
              child: const Text(
                '+91',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            errorStyle: const TextStyle(height: 0),
          ),
          cursorColor: const Color(0xffE15564),
          style: const TextStyle(color: Colors.black, fontSize: 14),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            LengthLimitingTextInputFormatter(10),
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]*')),
          ],
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
          borderRadius: BorderRadius.circular(5),
          fieldHeight: 30,
          fieldWidth: 30,
          activeFillColor: Colors.white,
          inactiveFillColor: Colors.white,
          selectedFillColor: Colors.white,
          activeColor: Color(0xffE15564),
          inactiveColor: Color(0xffE15564),
          selectedColor: Color(0xffE15564),
        ),
        animationDuration: const Duration(milliseconds: 300),
        enableActiveFill: true,
        controller: TextEditingController(),
        onCompleted: (v) {
          controller.otpController.text = v;
        },
        onChanged: (value) {
          controller.otpController.text = value;
        },
        beforeTextPaste: (text) {
          return true; // Enable paste
        },
        keyboardType: TextInputType.number,
      ),
    );
  }
}