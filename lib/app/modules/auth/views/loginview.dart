import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash_bg.jpg'),
            fit: BoxFit.fill,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).size.height * 0.27,
              left: MediaQuery.of(context).size.width * 0.1,
              right: MediaQuery.of(context).size.width * 0.1,
              child: Image.asset(
                'assets/images/app_logo.png',
                height: 240,
                width: 230,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.52,
              left: MediaQuery.of(context).size.width * 0.1,
              right: MediaQuery.of(context).size.width * 0.1,
              bottom: 0,
              child: SingleChildScrollView(
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
                fontSize: 19, color: Colors.white, fontFamily: 'WorkSansBold'),
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
                  style: TextStyle(
                      color: Colors.yellow, fontFamily: 'WorkSansBold'),
                ),
              )
            : SizedBox.shrink()),
        const SizedBox(height: 15),
        Center(
          child: SizedBox(
            height: 35,
            width: 120,
            child: Obx(() => controller.isLoading.value
                ? CircularProgressIndicator(color: Colors.white)
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
    return SizedBox(
      height: 34,
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
    );
  }

  Widget _buildOtpInput() {
    return CustomOtpInput(
      length: 6,
      onChanged: (value) => controller.otpController.text = value,
    );
  }
}

class CustomOtpInput extends StatefulWidget {
  final int length;
  final Function(String) onChanged;

  const CustomOtpInput({required this.length, required this.onChanged});

  @override
  _CustomOtpInputState createState() => _CustomOtpInputState();
}

class _CustomOtpInputState extends State<CustomOtpInput> {
  List<TextEditingController> controllers = [];
  List<FocusNode> focusNodes = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.length; i++) {
      controllers.add(TextEditingController());
      focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    controllers.forEach((controller) => controller.dispose());
    focusNodes.forEach((node) => node.dispose());
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < widget.length - 1) {
      focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
    String otp = controllers.map((c) => c.text).join();
    widget.onChanged(otp);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.length,
        (index) => Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          child: TextField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            decoration: InputDecoration(
              counterText: "",
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xffE15564),
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xffE15564), width: 2),
                borderRadius: BorderRadius.circular(5),
              ),
              contentPadding: EdgeInsets.zero,
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) => _onChanged(value, index),
          ),
        ),
      ),
    );
  }
}
