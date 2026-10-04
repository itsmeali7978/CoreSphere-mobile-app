import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppToast {
  static void show(String message, {Color backgroundColor = Colors.redAccent}) {
    if (message.isEmpty) return;

    try {
      if (Get.context != null) {
        final scaffoldState = ScaffoldMessenger.maybeOf(Get.context!);
        if (scaffoldState != null) {
          scaffoldState.hideCurrentSnackBar();
          scaffoldState.showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: backgroundColor,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
          return;
        }
      }
    } catch (_) {}

    // Safe GetX fallback if ScaffoldMessenger is not in widget tree
    try {
      Get.rawSnackbar(
        message: message,
        backgroundColor: backgroundColor,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        borderRadius: 8,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      debugPrint("DEBUG: Failed to show snackbar: $e. Toast message: $message");
    }
  }
}
