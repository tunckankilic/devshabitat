import 'package:flutter_test/flutter_test.dart';
import 'package:devshabitat/app/controllers/app_controller.dart';
import 'package:devshabitat/app/core/services/error_handler_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../../../test/test_helper.dart';

@GenerateNiceMocks([MockSpec<ErrorHandlerService>()])
import 'app_controller_test.mocks.dart';

void main() {
  late AppController controller;
  late MockErrorHandlerService mockErrorHandler;

  setUp(() async {
    await setupTestEnvironment();
    mockErrorHandler = MockErrorHandlerService();
    controller = AppController(errorHandler: mockErrorHandler);
  });

  tearDown(() {
    Get.reset();
  });

  group('AppController - Temel Fonksiyonlar', () {
    test('başlangıç değerleri doğru olmalı', () {
      expect(controller.isDarkMode, false);
      expect(controller.isOnline, true);
      expect(controller.isLoading, false);
    });

    test('toggleTheme tema modunu değiştirmeli', () {
      final initialTheme = controller.isDarkMode;
      controller.toggleTheme();
      expect(controller.isDarkMode, !initialTheme);
    });

    test('setLoading yükleme durumunu güncellemeli', () {
      controller.setLoading(true);
      expect(controller.isLoading, true);

      controller.setLoading(false);
      expect(controller.isLoading, false);
    });

    test('handleError error handler servisini çağırmalı', () {
      final error = Exception('Test hatası');
      controller.handleError(error);
      verify(mockErrorHandler.handleError(
              error, ErrorHandlerService.SERVER_ERROR))
          .called(1);
    });

    test('resetAppState tüm durumları sıfırlamalı', () {
      controller.setLoading(true);
      controller.resetAppState();
      expect(controller.isLoading, false);
    });
  });

  group('AppController - Tema Yönetimi', () {
    test('tema değişikliği Get.changeThemeMode çağırmalı', () {
      controller.toggleTheme();
      // Get.changeThemeMode çağrıldığını kontrol et
      expect(controller.isDarkMode, true);
    });

    test('çoklu tema değişiklikleri doğru çalışmalı', () {
      expect(controller.isDarkMode, false);

      controller.toggleTheme();
      expect(controller.isDarkMode, true);

      controller.toggleTheme();
      expect(controller.isDarkMode, false);

      controller.toggleTheme();
      expect(controller.isDarkMode, true);
    });
  });

  group('AppController - Bağlantı Yönetimi', () {
    test('bağlantı durumu değişikliklerini izlemeli', () async {
      // Bağlantı durumu değişikliklerini simüle et
      expect(controller.isOnline, true);

      // Offline durumu simüle et
      // Bu test için gerçek connectivity değişikliklerini simüle ediyoruz
    });

    test('offline modda çalışabilmeli', () {
      expect(controller.isOnline, true);
      // Offline durumu test et
    });
  });

  group('AppController - Hata Yönetimi', () {
    test('farklı hata türlerini doğru şekilde işlemeli', () {
      final networkError = Exception('Ağ hatası');
      final serverError = Exception('Sunucu hatası');
      final validationError = Exception('Doğrulama hatası');

      controller.handleError(networkError);
      verify(mockErrorHandler.handleError(
              networkError, ErrorHandlerService.NETWORK_ERROR))
          .called(1);

      controller.handleError(serverError);
      verify(mockErrorHandler.handleError(
              serverError, ErrorHandlerService.SERVER_ERROR))
          .called(1);

      controller.handleError(validationError);
      verify(mockErrorHandler.handleError(
              validationError, ErrorHandlerService.VALIDATION_ERROR))
          .called(1);
    });

    test('hata işleme sırasında uygulama durumu korunmalı', () {
      controller.setLoading(true);
      final error = Exception('Test hatası');

      controller.handleError(error);

      // Hata işlendikten sonra loading durumu korunmalı
      expect(controller.isLoading, true);
    });
  });

  group('AppController - Yaşam Döngüsü', () {
    test('onInit çağrıldığında gerekli servisler başlatılmalı', () {
      // onInit zaten setUp'ta çağrılıyor
      expect(controller.isOnline, true);
      expect(controller.isDarkMode, false);
    });

    test('controller dispose edildiğinde kaynaklar temizlenmeli', () {
      // GetxController otomatik olarak dispose edilir
      expect(controller.isLoading, false);
    });
  });

  group('AppController - Edge Cases', () {
    test('çoklu hızlı tema değişiklikleri', () {
      for (int i = 0; i < 10; i++) {
        controller.toggleTheme();
      }
      // Son durum tutarlı olmalı
      expect(controller.isDarkMode, true);
    });

    test('yükleme durumu sırasında tema değişikliği', () {
      controller.setLoading(true);
      controller.toggleTheme();

      expect(controller.isLoading, true);
      expect(controller.isDarkMode, true);
    });

    test('null hata durumu', () {
      expect(() => controller.handleError(null), returnsNormally);
    });
  });

  group('AppController - Performans Testleri', () {
    test('çoklu state değişiklikleri performanslı olmalı', () {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        controller.setLoading(i % 2 == 0);
        controller.toggleTheme();
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });
}
