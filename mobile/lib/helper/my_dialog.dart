import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widget/custom_loading.dart';

/// A utility class for displaying various types of dialogs and notifications.
///
/// This class provides methods for showing **snackbars** (info, success, error)
/// and a **loading dialog** using `GetX`.
class MyDialog {
  /// Displays an **informational snackbar** with a blue background.
  ///
  /// - [msg]: The message to be displayed.
  static void info(String msg) {
    _showSnackbar('Info', msg, Colors.blue);
  }

  /// Displays a **success snackbar** with a green background.
  ///
  /// - [msg]: The message to be displayed.
  static void success(String msg) {
    _showSnackbar('Success', msg, Colors.green);
  }

  /// Displays an **error snackbar** with a red background.
  ///
  /// - [msg]: The message to be displayed.
  static void error(String msg) {
    _showSnackbar('Error', msg, Colors.redAccent);
  }

  /// Displays a **loading dialog** with a custom loading animation.
  ///
  /// - This dialog will persist until manually dismissed using `Get.back()`.
  static void showLoadingDialog() {
    if (Get.isDialogOpen ?? false) {
      return; // Prevent multiple dialogs from stacking
    }
    Get.dialog(
      const Center(child: CustomLoading()),
      barrierDismissible: false, // Prevent closing the dialog accidentally
    );
  }

  /// Private method to display a snackbar with a given title, message, and background color.
  static void _showSnackbar(String title, String message, Color color) {
    Get.snackbar(
      title,
      message,
      backgroundColor: color.withOpacity(0.7),
      colorText: Colors.white,
      snackPosition:
          SnackPosition.BOTTOM, // Position at the bottom for better visibility
      margin: const EdgeInsets.all(10),
      duration: const Duration(seconds: 3),
    );
  }
}
