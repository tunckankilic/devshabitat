// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../config/app_config.dart';

class ErrorHandlerService extends GetxService {
  static ErrorHandlerService get to => Get.find();

  final Logger _logger = Logger();
  final AppConfig? _config =
      Get.isRegistered<AppConfig>() ? Get.find<AppConfig>() : null;

  // Constructor'da AppConfig'i zorunlu olarak alma

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

  Future<void> handleError(
    dynamic error,
    String errorType, {
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) async {
    // Hata detaylarını logla
    _logger.e(
      'Error: $errorType',
      error: error,
      stackTrace: stackTrace,
    );

    // Crashlytics'e raporla
    await FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: errorType,
      information: [
        if (metadata != null)
          ...metadata.entries.map((e) => '${e.key}: ${e.value}'),
      ],
    );

    // Kullanıcıya uygun mesajı göster
    _showErrorMessage(errorType, error);
  }

  void _showErrorMessage(String errorType, dynamic error) {
    String message;

    // Startup sırasında Firebase index hatalarını gösterme
    if (error.toString().contains('failed-precondition') ||
        error.toString().contains('requires an index')) {
      return; // Sessizce geç
    }

    // GitHub kullanıcı bulunamadı hatası da gösterme
    if (error.toString().contains('GitHub kullanıcısı bulunamadı')) {
      return; // Sessizce geç
    }

    switch (errorType) {
      case VALIDATION_ERROR:
        message = 'Lütfen girdiğiniz bilgileri kontrol edin';
        break;
      case NETWORK_ERROR:
        message = 'İnternet bağlantınızı kontrol edin';
        break;
      case AUTH_ERROR:
        message = 'Oturumunuz sona ermiş olabilir. Lütfen tekrar giriş yapın';
        break;
      case FILE_ERROR:
        message =
            'Dosya işlemi başarısız oldu. Lütfen daha sonra tekrar deneyin';
        break;
      case SERVER_ERROR:
        message = 'Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin';
        break;
      case DISCUSSION_ERROR:
        message = 'Sohbet hatası oluştu. Lütfen daha sonra tekrar deneyin';
        break;
      case PORTFOLIO_ERROR:
        message = 'Portföy hatası oluştu. Lütfen daha sonra tekrar deneyin';
        break;
      case MATCHING_ERROR:
        message = 'Eşleştirme hatası oluştu. Lütfen daha sonra tekrar deneyin';
        break;
      default:
        // Startup hatalarını gösterme
        if (_isStartupError(error)) {
          return;
        }
        message = 'Beklenmedik bir hata oluştu. Lütfen tekrar deneyin';
    }

    Get.snackbar(
      'Hata',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  bool _isStartupError(dynamic error) {
    final errorStr = error.toString();
    return errorStr.contains('failed-precondition') ||
        errorStr.contains('requires an index') ||
        errorStr.contains('index is currently building') ||
        errorStr.contains('GitHub kullanıcısı bulunamadı');
  }

  // Input validation
  String? validateInput(String input, {bool sanitize = true}) {
    if (input.isEmpty) {
      return 'This field cannot be left blank';
    }

    if (sanitize) {
      input = _config?.sanitizeInput(input) ?? input;
    }

    if (input.length < 3) {
      return 'Please enter at least 3 characters';
    }

    return null;
  }

  String? validateEmail(String email) {
    if (_config == null || !_config.isValidEmail(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String password) {
    if (_config == null || !_config.isValidPassword(password)) {
      return 'Password must be at least 8 characters long and contain uppercase/lowercase letters, numbers, and special characters';
    }
    return null;
  }

  // Dosya validation
  String? validateFile(String fileName, int fileSize) {
    if (_config == null || !_config.isValidFileType(fileName)) {
      return 'This file type is not supported';
    }

    if (!_config.isValidFileSize(fileSize)) {
      return 'File size is too large (max: ${AppConfig.maxFileSize ~/ (1024 * 1024)}MB)';
    }

    return null;
  }

  // API Error handling
  Future<T> handleApiError<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } catch (e, stackTrace) {
      if (e.toString().contains('network')) {
        await handleError(e, NETWORK_ERROR, stackTrace: stackTrace);
      } else if (e.toString().contains('unauthorized')) {
        await handleError(e, AUTH_ERROR, stackTrace: stackTrace);
      } else {
        await handleError(e, SERVER_ERROR, stackTrace: stackTrace);
      }
      rethrow;
    }
  }

  void handleSuccess(String message,
      {SnackPosition position = SnackPosition.BOTTOM}) {
    _logger.i('Success: $message');
    Get.snackbar(
      'Success',
      message,
      snackPosition: position,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    );
  }

  void handleWarning(String message,
      {SnackPosition position = SnackPosition.BOTTOM}) {
    _logger.w('Warning: $message');
    Get.snackbar(
      'Warning',
      message,
      snackPosition: position,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
    );
  }

  void handleInfo(String message,
      {SnackPosition position = SnackPosition.BOTTOM}) {
    _logger.i('Info: $message');
    Get.snackbar(
      'Info',
      message,
      snackPosition: position,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.info_outline, color: Colors.white),
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
            child: const Text('OK'),
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
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void showConfirmationDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = 'Yes',
    String cancelText = 'No',
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

  void logError(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  void logInfo(String message) {
    _logger.i(message);
  }

  void logWarning(String message) {
    _logger.w(message);
  }
}
