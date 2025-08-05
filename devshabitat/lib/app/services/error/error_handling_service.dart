import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/error/registration_error.dart';
import 'package:logger/logger.dart';

class ErrorHandlingService extends GetxService {
  final Logger _logger;

  ErrorHandlingService({Logger? logger}) : _logger = logger ?? Logger();

  void handleRegistrationError(RegistrationException error) {
    // Hata loglaması (hassas veriler hariç)
    _logger.e(
      'Registration Error',
      error: error.toMap()..remove('details'),
      stackTrace: StackTrace.current,
    );

    // Kullanıcı geri bildirimi
    if (error.type.requiresUserAction) {
      _showErrorDialog(error);
    } else if (error.type.isNetworkError) {
      Get.snackbar(
        'Bağlantı Hatası',
        error.toString(),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: () => Get.back(),
          child: const Text('Tamam', style: TextStyle(color: Colors.white)),
        ),
      );
    } else {
      Get.snackbar(
        'Hata',
        error.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _showErrorDialog(RegistrationException error) {
    Get.dialog(
      AlertDialog(
        title: const Text('İşlem Gerekiyor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error.toString()),
            if (error.type == RegistrationErrorType.locationPermissionDenied)
              const Text(
                'Konum servislerini etkinleştirmek için ayarları açın.',
                style: TextStyle(fontSize: 12),
              ),
            if (error.type == RegistrationErrorType.noInternetConnection)
              const Text(
                'İnternet bağlantınızı kontrol edin ve tekrar deneyin.',
                style: TextStyle(fontSize: 12),
              ),
          ],
        ),
        actions: [
          if (error.type.isRecoverable)
            TextButton(
              onPressed: () {
                Get.back();
                // Özel kurtarma aksiyonları burada tetiklenebilir
              },
              child: const Text('Tekrar Dene'),
            ),
          TextButton(onPressed: () => Get.back(), child: const Text('Tamam')),
        ],
      ),
    );
  }

  void logSecurityEvent(String event, {Map<String, dynamic>? metadata}) {
    // Güvenlik olaylarını ayrı bir log kanalına gönder
    _logger.w(
      'Security Event: $event',
      error: metadata?..remove('sensitiveData'),
    );
  }

  // Debug modunda hassas veri loglamasını engelle
  void debugLog(String message, {dynamic data}) {
    assert(() {
      if (data != null && _containsSensitiveData(data)) {
        _logger.w('Attempted to log sensitive data in debug mode');
        return true;
      }
      _logger.d(message, error: data);
      return true;
    }());
  }

  bool _containsSensitiveData(dynamic data) {
    final String dataStr = data.toString().toLowerCase();
    return [
      'password',
      'token',
      'secret',
      'key',
      'auth',
      'credential',
    ].any((term) => dataStr.contains(term));
  }
}
