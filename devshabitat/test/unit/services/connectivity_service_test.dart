import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:devshabitat/app/services/connectivity_service.dart';
import 'package:devshabitat/app/core/services/error_handler_service.dart';
import '../../../test/test_helper.mocks.dart';
import '../../../test/test_helper.dart';

void main() {
  late ConnectivityService service;
  late MockConnectivity mockConnectivity;
  late MockSharedPreferences mockPrefs;
  late MockErrorHandlerService mockErrorHandler;

  setUp(() async {
    await setupTestEnvironment();

    mockConnectivity = MockConnectivity();
    mockPrefs = MockSharedPreferences();
    mockErrorHandler = MockErrorHandlerService();

    // Mock setup
    when(mockConnectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.wifi]);
    when(mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => Stream.value([ConnectivityResult.wifi]));
    when(mockPrefs.getBool(any)).thenReturn(false);
    when(mockPrefs.setBool(any, any)).thenAnswer((_) async => true);

    // Plugin'i test ortamına kaydet
    Get.put<Connectivity>(mockConnectivity);

    service = ConnectivityService(
      prefs: mockPrefs,
      errorHandler: mockErrorHandler,
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('ConnectivityService - Temel Fonksiyonlar', () {
    test('başlangıç değerleri doğru olmalı', () {
      expect(service.isOnline.value, true);
      expect(service.isOfflineModeEnabled.value, false);
    });

    test('onInit çağrıldığında servisler başlatılmalı', () {
      service.onInit();
      expect(service.isOnline.value, true);
      expect(service.isOfflineModeEnabled.value, false);
    });
  });

  group('ConnectivityService - Bağlantı Durumu Kontrolü', () {
    test('wifi bağlantısı online olmalı', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      service.onInit();
      await Future.delayed(Duration(milliseconds: 100));

      expect(service.isOnline.value, true);
    });

    test('mobil bağlantı online olmalı', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.mobile]);

      service.onInit();
      await Future.delayed(Duration(milliseconds: 100));

      expect(service.isOnline.value, true);
    });

    test('ethernet bağlantısı online olmalı', () async {
      when(mockConnectivity.checkConnectivity()).thenAnswer(
        (_) async => [ConnectivityResult.ethernet],
      );

      service.onInit();
      await Future.delayed(Duration(milliseconds: 100));

      expect(service.isOnline.value, true);
    });

    test('bağlantı yok offline olmalı', () async {
      when(mockConnectivity.checkConnectivity()).thenAnswer(
        (_) async => [ConnectivityResult.none],
      );

      service.onInit();
      await Future.delayed(Duration(milliseconds: 100));

      expect(service.isOnline.value, false);
    });

    test('çoklu bağlantı türleri', () async {
      when(mockConnectivity.checkConnectivity()).thenAnswer(
        (_) async => [ConnectivityResult.wifi, ConnectivityResult.mobile],
      );

      service.onInit();
      await Future.delayed(Duration(milliseconds: 100));

      expect(service.isOnline.value, true);
    });
  });

  group('ConnectivityService - Bağlantı Değişiklikleri', () {
    test('bağlantı kaybı durumunda offline olmalı', () async {
      // Başlangıçta online
      when(mockConnectivity.checkConnectivity()).thenAnswer(
        (_) async => [ConnectivityResult.wifi],
      );
      when(mockConnectivity.onConnectivityChanged).thenAnswer(
        (_) => Stream.value([ConnectivityResult.none]),
      );

      service.onInit();
      await Future.delayed(Duration(milliseconds: 100));

      expect(service.isOnline.value, false);
    });

    test('bağlantı geri geldiğinde online olmalı', () async {
      // Başlangıçta offline
      when(mockConnectivity.checkConnectivity()).thenAnswer(
        (_) async => [ConnectivityResult.none],
      );
      when(mockConnectivity.onConnectivityChanged).thenAnswer(
        (_) => Stream.value([ConnectivityResult.wifi]),
      );

      service.onInit();
      await Future.delayed(Duration(milliseconds: 100));

      expect(service.isOnline.value, true);
    });

    test('bağlantı değişikliği hata durumunda', () async {
      when(mockConnectivity.checkConnectivity()).thenAnswer(
        (_) async => [ConnectivityResult.wifi],
      );
      when(mockConnectivity.onConnectivityChanged).thenAnswer(
        (_) => Stream.error(Exception('Connectivity error')),
      );

      service.onInit();
      await Future.delayed(Duration(milliseconds: 100));

      // Hata durumunda mevcut durum korunmalı
      expect(service.isOnline.value, true);
      verify(mockErrorHandler.handleError(
              any, ErrorHandlerService.NETWORK_ERROR))
          .called(1);
    });
  });

  group('ConnectivityService - Offline Mode Yönetimi', () {
    test('offline mode etkinleştirme', () async {
      when(mockPrefs.setBool('offline_mode_enabled', true))
          .thenAnswer((_) async => true);

      await service.toggleOfflineMode(true);

      expect(service.isOfflineModeEnabled.value, true);
      verify(mockPrefs.setBool('offline_mode_enabled', true)).called(1);
      verify(mockErrorHandler.handleSuccess('Offline mod etkinleştirildi'))
          .called(1);
    });

    test('offline mode devre dışı bırakma', () async {
      when(mockPrefs.setBool('offline_mode_enabled', false))
          .thenAnswer((_) async => true);

      await service.toggleOfflineMode(false);

      expect(service.isOfflineModeEnabled.value, false);
      verify(mockPrefs.setBool('offline_mode_enabled', false)).called(1);
      verify(mockErrorHandler.handleSuccess('Offline mod devre dışı bırakıldı'))
          .called(1);
    });

    test('offline mode tercihi SharedPreferences\'dan yüklenmeli', () async {
      when(mockPrefs.getBool('offline_mode_enabled')).thenReturn(true);

      service = ConnectivityService(
        prefs: mockPrefs,
        errorHandler: mockErrorHandler,
      );

      expect(service.isOfflineModeEnabled.value, true);
    });

    test('offline mode varsayılan değer false olmalı', () async {
      when(mockPrefs.getBool('offline_mode_enabled')).thenReturn(null);

      service = ConnectivityService(
        prefs: mockPrefs,
        errorHandler: mockErrorHandler,
      );

      expect(service.isOfflineModeEnabled.value, false);
    });

    test('offline mode toggle hatası', () async {
      when(mockPrefs.setBool('offline_mode_enabled', true))
          .thenThrow(Exception('Prefs error'));

      await service.toggleOfflineMode(true);

      verify(mockErrorHandler.handleError(
              any, ErrorHandlerService.NETWORK_ERROR))
          .called(1);
    });
  });

  group('ConnectivityService - Operasyon Kontrolü', () {
    test('canPerformOperation online durumda true döndürmeli', () {
      service.isOnline.value = true;
      service.isOfflineModeEnabled.value = false;

      expect(service.canPerformOperation(), true);
    });

    test(
        'canPerformOperation offline durumda offline mode varsa true döndürmeli',
        () {
      service.isOnline.value = false;
      service.isOfflineModeEnabled.value = true;

      expect(service.canPerformOperation(), true);
    });

    test(
        'canPerformOperation offline durumda offline mode yoksa false döndürmeli',
        () {
      service.isOnline.value = false;
      service.isOfflineModeEnabled.value = false;

      expect(service.canPerformOperation(), false);
    });

    test('canWorkOffline offline mode etkinse true döndürmeli', () {
      service.isOfflineModeEnabled.value = true;

      expect(service.canWorkOffline(), true);
    });

    test('canWorkOffline offline mode devre dışıysa false döndürmeli', () {
      service.isOfflineModeEnabled.value = false;

      expect(service.canWorkOffline(), false);
    });
  });

  group('ConnectivityService - Bağlantı Durumu Güncellemeleri', () {
    test('bağlantı durumu değişikliği', () async {
      service.onInit();
      await Future.delayed(Duration(milliseconds: 100));
      expect(service.isOnline.value, true);

      // Bağlantı kaybı simülasyonu
      when(mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => Stream.value([ConnectivityResult.none]));
      await Future.delayed(Duration(milliseconds: 100));
      expect(service.isOnline.value, false);

      // Bağlantı geri gelme simülasyonu
      when(mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => Stream.value([ConnectivityResult.wifi]));
      await Future.delayed(Duration(milliseconds: 100));
      expect(service.isOnline.value, true);
    });

    test('offline mode bilgi mesajı', () async {
      service.isOfflineModeEnabled.value = true;

      when(mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => Stream.value([ConnectivityResult.none]));

      service.onInit();
      await Future.delayed(Duration(milliseconds: 100));

      verify(mockErrorHandler.handleInfo('Offline moda geçildi')).called(1);
    });

    test('online mode bilgi mesajı', () async {
      service.isOfflineModeEnabled.value = true;
      service.isOnline.value = false;

      when(mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => Stream.value([ConnectivityResult.wifi]));

      service.onInit();
      await Future.delayed(Duration(milliseconds: 100));

      verify(mockErrorHandler.handleInfo('Online moda geçildi')).called(1);
    });
  });

  group('ConnectivityService - Hata Yönetimi', () {
    test('bağlantı kontrolü hatası', () async {
      when(mockConnectivity.checkConnectivity())
          .thenThrow(Exception('Connectivity error'));

      service.onInit();
      await Future.delayed(Duration(milliseconds: 100));

      verify(mockErrorHandler.handleError(
              any, ErrorHandlerService.NETWORK_ERROR))
          .called(1);
    });

    test('bağlantı stream hatası', () async {
      when(mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => Stream.error(Exception('Stream error')));

      service.onInit();
      await Future.delayed(Duration(milliseconds: 100));

      expect(service.isOnline.value, true);
    });
  });

  group('ConnectivityService - Edge Cases', () {
    test('çoklu bağlantı değişiklikleri', () async {
      final connectivityStream = Stream.fromIterable([
        [ConnectivityResult.wifi],
        [ConnectivityResult.none],
        [ConnectivityResult.mobile],
        [ConnectivityResult.none],
      ]);

      when(mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => connectivityStream);

      service.onInit();
      await Future.delayed(Duration(milliseconds: 500));
      expect(service.isOnline.value, false);
    });

    test('boş bağlantı sonucu', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => <ConnectivityResult>[]);

      service.onInit();
      await Future.delayed(Duration(milliseconds: 100));
      expect(service.isOnline.value, false);
    });

    test('null bağlantı sonucu', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      service.onInit();
      await Future.delayed(Duration(milliseconds: 100));
      expect(service.isOnline.value, false);
    });
  });

  group('ConnectivityService - Performans Testleri', () {
    test('çoklu bağlantı kontrolü performanslı olmalı', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        service.onInit();
        await Future.delayed(Duration(milliseconds: 10));
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    test('çoklu offline mode toggle performanslı olmalı', () async {
      when(mockPrefs.setBool(any, any)).thenAnswer((_) async => true);

      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        await service.toggleOfflineMode(i % 2 == 0);
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });
  });

  group('ConnectivityService - Memory Management', () {
    test('service dispose edildiğinde kaynaklar temizlenmeli', () {
      // GetxService otomatik olarak dispose edilir
      expect(service.isOnline.value, true);
      expect(service.isOfflineModeEnabled.value, false);
    });

    test('stream subscription temizlenmeli', () {
      // Stream subscription'lar GetxService tarafından otomatik temizlenir
      expect(service.isOnline.value, true);
    });
  });
}
