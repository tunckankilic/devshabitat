// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';

class ErrorHandlerService extends GetxService {
  final Logger _logger = Logger();

  // Hata tipleri
  static const String VALIDATION_ERROR = 'VALIDATION_ERROR';
  static const String NETWORK_ERROR = 'NETWORK_ERROR';
  static const String AUTH_ERROR = 'AUTH_ERROR';
  static const String FILE_ERROR = 'FILE_ERROR';
  static const String SERVER_ERROR = 'SERVER_ERROR';
  static const String DISCUSSION_ERROR = 'DISCUSSION_ERROR';
  static const String PORTFOLIO_ERROR = 'PORTFOLIO_ERROR';
  static const String MATCHING_ERROR = 'MATCHING_ERROR';
  static const String MESSAGE_ERROR = 'MESSAGE_ERROR';

  void handleSuccess(String message) {
    _logger.i('Success: $message');
    showSuccess(message);
  }

  Future<void> handleError(
    dynamic error, [
    String? context,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  ]) async {
    final errorMessage = _getErrorMessage(error);
    _logger.e('Error${context != null ? ' in $context' : ''}: $error');

    Get.snackbar(
      'Error',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void handleInfo(String message) {
    _logger.i('Info: $message');
    showInfo(message);
  }

  String? validateFile(String fileName, int fileSize) {
    // Dosya boyutu kontrolü (max 10MB)
    final maxSize = 10 * 1024 * 1024;
    if (fileSize > maxSize) {
      return 'Dosya boyutu 10MB\'dan büyük olamaz';
    }

    // Dosya uzantısı kontrolü
    final extension = fileName.split('.').last.toLowerCase();
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];
    if (!allowedExtensions.contains(extension)) {
      return 'Geçersiz dosya uzantısı. İzin verilen uzantılar: ${allowedExtensions.join(", ")}';
    }

    return null;
  }

  void handleWarning(String message) {
    _logger.w('Warning: $message');
    showWarning(message);
  }

  String _getErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    }

    if (error is Map) {
      return error['message'] ?? error.toString();
    }

    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }

    return 'An unexpected error occurred';
  }

  void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void showWarning(String message) {
    Get.snackbar(
      'Warning',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void showInfo(String message) {
    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void logError(String message, [String? context]) {
    _logger.e('Error${context != null ? ' in $context' : ''}: $message');
  }
}
