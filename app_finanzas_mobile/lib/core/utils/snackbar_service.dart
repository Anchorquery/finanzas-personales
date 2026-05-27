import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_finanzas_mobile/core/theme/app_theme.dart';

class SnackbarService {
  static void showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppTheme.accentRed,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      icon: const Icon(Icons.error_outline, color: Colors.white, size: 28),
      shouldIconPulse: true,
      barBlur: 20,
      isDismissible: true,
      duration: const Duration(seconds: 4),
    );
  }

  static void showSuccess(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppTheme.accentGreen,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      icon: const Icon(
        Icons.check_circle_outline,
        color: Colors.white,
        size: 28,
      ),
      shouldIconPulse: true,
      barBlur: 20,
      isDismissible: true,
      duration: const Duration(seconds: 3),
    );
  }

  static void showWarning(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppTheme.accentWarning,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: Colors.white,
        size: 28,
      ),
      shouldIconPulse: true,
      barBlur: 20,
      isDismissible: true,
      duration: const Duration(seconds: 4),
    );
  }

  static void showAI(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppTheme.accentAI,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
      shouldIconPulse: true,
      barBlur: 20,
      isDismissible: true,
      duration: const Duration(seconds: 5),
    );
  }
}
