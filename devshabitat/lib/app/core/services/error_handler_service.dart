import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class ErrorHandlerService extends GetxService {
  final _logger = Logger();

  void handleError(dynamic error) {
    _logger.e('Hata: $error');
    Get.snackbar(
      'Hata',
      error.toString(),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void handleSuccess(String message) {
    _logger.i('Başarılı: $message');
    Get.snackbar(
      'Başarılı',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void handleWarning(String message) {
    _logger.w('Uyarı: $message');
    Get.snackbar(
      'Uyarı',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void handleInfo(String message) {
    _logger.i('Bilgi: $message');
    Get.snackbar(
      'Bilgi',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void showErrorDialog(String title, String message) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void showSuccessDialog(String title, String message) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void showConfirmationDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = 'Evet',
    String cancelText = 'Hayır',
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
