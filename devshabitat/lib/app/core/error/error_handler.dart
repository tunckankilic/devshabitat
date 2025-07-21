// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../services/snackbar_service.dart';

class AppError implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppError(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppError: $message (Code: $code)';
}

class ErrorHandler {
  static final Logger _logger = Logger();
  static final SnackbarService _snackbarService = Get.find<SnackbarService>();

  // Hata tipleri
  static const String NETWORK_ERROR = 'NETWORK_ERROR';
  static const String AUTH_ERROR = 'AUTH_ERROR';
  static const String VALIDATION_ERROR = 'VALIDATION_ERROR';
  static const String SERVER_ERROR = 'SERVER_ERROR';
  static const String UNKNOWN_ERROR = 'UNKNOWN_ERROR';

  // Hata mesajları
  static const Map<String, String> errorMessages = {
    NETWORK_ERROR: 'İnternet bağlantınızı kontrol edin',
    AUTH_ERROR: 'Oturum süreniz doldu, lütfen tekrar giriş yapın',
    VALIDATION_ERROR: 'Lütfen girdiğiniz bilgileri kontrol edin',
    SERVER_ERROR: 'Sunucu hatası, lütfen daha sonra tekrar deneyin',
    UNKNOWN_ERROR: 'Beklenmeyen bir hata oluştu',
  };

  // Ana hata yakalama metodu
  static Future<T> handleError<T>(
    Future<T> Function() action, {
    String? errorTitle,
    bool showSnackbar = true,
    bool reportToCrashlytics = true,
  }) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      final appError = _processError(error, stackTrace);

      // Hata logla
      _logError(appError);

      // Crashlytics'e raporla
      if (reportToCrashlytics && !kDebugMode) {
        _reportToCrashlytics(appError);
      }

      // Kullanıcıya bildir
      if (showSnackbar) {
        _showErrorSnackbar(appError, errorTitle);
      }

      throw appError;
    }
  }

  // Stream için hata yakalama
  static Stream<T> handleStreamError<T>(
    Stream<T> stream, {
    String? errorTitle,
    bool showSnackbar = true,
    bool reportToCrashlytics = true,
  }) {
    return stream.handleError((error, stackTrace) {
      final appError = _processError(error, stackTrace);

      _logError(appError);

      if (reportToCrashlytics && !kDebugMode) {
        _reportToCrashlytics(appError);
      }

      if (showSnackbar) {
        _showErrorSnackbar(appError, errorTitle);
      }

      throw appError;
    });
  }

  // Hata işleme
  static AppError _processError(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppError) return error;

    String code = UNKNOWN_ERROR;
    String message = errorMessages[UNKNOWN_ERROR]!;

    if (error is SocketException || error is TimeoutException) {
      code = NETWORK_ERROR;
      message = errorMessages[NETWORK_ERROR]!;
    } else if (error is FirebaseException) {
      code = error.code;
      message = error.message ?? errorMessages[AUTH_ERROR]!;
    } else if (error is FormatException) {
      code = VALIDATION_ERROR;
      message = errorMessages[VALIDATION_ERROR]!;
    } else if (error is HttpException) {
      code = SERVER_ERROR;
      message = errorMessages[SERVER_ERROR]!;
    }

    return AppError(
      message,
      code: code,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  // Hata loglama
  static void _logError(AppError error) {
    _logger.e(
      'Error: ${error.message}',
      error: error.originalError,
      stackTrace: error.stackTrace,
    );
  }

  // Crashlytics'e raporlama
  static void _reportToCrashlytics(AppError error) {
    FirebaseCrashlytics.instance.recordError(
      error.originalError ?? error,
      error.stackTrace,
      reason: error.message,
    );
  }

  // Snackbar gösterme
  static void _showErrorSnackbar(AppError error, [String? title]) {
    _snackbarService.showErrorMessage(
      title ?? 'Hata',
      error.message,
    );
  }

  // Özel hata fırlatma yardımcısı
  static Never throwError(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    throw AppError(
      message,
      code: code,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }
}
