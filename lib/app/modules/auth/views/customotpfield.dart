import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms_autofill/sms_autofill.dart';

class OtpInputField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final Function(String)? onCompleted;
  final bool isPhone;

  const OtpInputField({
    Key? key,
    required this.controller,
    required this.onChanged,
    this.onCompleted,
    this.isPhone = false,
  }) : super(key: key);

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> with CodeAutoFill {
  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  List<TextEditingController> controllers =
      List.generate(6, (index) => TextEditingController());

  @override
  void codeUpdated() {
    if (code != null) {
      // Update all fields with the received code
      for (int i = 0; i < code!.length && i < 6; i++) {
        controllers[i].text = code![i];
      }
      widget.controller.text = code!;
      if (widget.onCompleted != null) {
        widget.onCompleted!(code!);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.isPhone) {
      listenForCode();
    }
  }

  @override
  void dispose() {
    cancel();
    for (var node in focusNodes) {
      node.dispose();
    }
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    String currentText = controllers.map((e) => e.text).join();
    widget.controller.text = currentText;
    widget.onChanged(currentText);

    if (value.length == 1 && index < 5) {
      focusNodes[index + 1].requestFocus();
    }

    if (currentText.length == 6 && widget.onCompleted != null) {
      widget.onCompleted!(currentText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          6,
          (index) => Container(
            width: 40,
            height: 45,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: TextField(
              controller: controllers[index],
              focusNode: focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: const TextStyle(fontSize: 20),
              decoration: InputDecoration(
                counterText: "",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xffE15564)),
                ),
              ),
              onChanged: (value) {
                if (value.length == 1 && index < 5) {
                  focusNodes[index + 1].requestFocus();
                } else if (value.isEmpty && index > 0) {
                  focusNodes[index - 1].requestFocus();
                }
                _onChanged(value, index);
              },
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
