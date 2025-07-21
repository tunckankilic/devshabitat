import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarService extends GetxService {
  static SnackbarService get to => Get.find();

  // Başarı mesajı göster
  void showSuccessMessage(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  // Hata mesajı göster
  void showErrorMessage(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  // Uyarı mesajı göster
  void showWarningMessage(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      icon: const Icon(Icons.warning, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  // Bilgi mesajı göster
  void showInfoMessage(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      icon: const Icon(Icons.info, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  // Özel snackbar göster
  void showCustomSnackbar({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    Icon? icon,
    Duration? duration,
    SnackPosition? position,
    void Function(GetSnackBar)? onTap,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position ?? SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: textColor,
      icon: icon,
      duration: duration ?? const Duration(seconds: 3),
      onTap: onTap,
    );
  }

  // Progress snackbar göster
  void showProgressSnackbar(String message) {
    Get.snackbar(
      'Processing',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      icon: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
      duration: const Duration(seconds: 30),
      isDismissible: false,
    );
  }

  // Progress snackbar'ı kapat
  void dismissProgressSnackbar() {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
  }

  // Snackbar'ı güncelle
  void updateSnackbarMessage(String message) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
      Get.snackbar(
        'Info',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        icon: const Icon(Icons.info, color: Colors.white),
        duration: const Duration(seconds: 3),
      );
    }
  }
}
