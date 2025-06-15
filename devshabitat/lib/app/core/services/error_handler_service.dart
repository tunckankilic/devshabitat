import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ErrorHandlerService extends GetxService {
  static ErrorHandlerService get to => Get.find();

  void handleError(dynamic error, {String? customMessage}) {
    String message;

    if (error is FirebaseAuthException) {
      message = _handleFirebaseAuthError(error);
    } else if (error is Exception) {
      message = error.toString();
    } else {
      message = customMessage ?? 'Beklenmeyen bir hata oluştu';
    }

    Get.snackbar(
      'Hata',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      borderRadius: 8,
    );
  }

  String _handleFirebaseAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return 'Kullanıcı bulunamadı';
      case 'wrong-password':
        return 'Hatalı şifre';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda';
      case 'weak-password':
        return 'Şifre çok zayıf';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi';
      case 'operation-not-allowed':
        return 'Bu işlem şu anda kullanılamıyor';
      case 'account-exists-with-different-credential':
        return 'Bu e-posta adresi farklı bir giriş yöntemi ile kullanılıyor';
      case 'network-request-failed':
        return 'İnternet bağlantısı hatası';
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış';
      case 'invalid-verification-code':
        return 'Geçersiz doğrulama kodu';
      case 'invalid-verification-id':
        return 'Geçersiz doğrulama kimliği';
      case 'credential-already-in-use':
        return 'Bu kimlik bilgisi zaten kullanımda';
      case 'requires-recent-login':
        return 'Bu işlem için son zamanlarda giriş yapmanız gerekiyor';
      default:
        return 'Kimlik doğrulama hatası: ${error.message}';
    }
  }

  void handleSuccess(String message) {
    Get.snackbar(
      'Başarılı',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      borderRadius: 8,
    );
  }
}
