import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackBar {
  static void show({
    required String title,
    required String message,
    SnackPosition? snackPosition,
    Color? backgroundColor,
    Duration? duration,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: snackPosition ?? SnackPosition.BOTTOM,
      backgroundColor: backgroundColor ?? Colors.black87,
      colorText: Colors.white,
      duration: duration ?? const Duration(seconds: 3),
    );
  }
}
