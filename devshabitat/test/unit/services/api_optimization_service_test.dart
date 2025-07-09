import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:devshabitat/app/core/services/api_optimization_service.dart';

void main() {
  group('ApiOptimizationService Tests', () {
    late ApiOptimizationService apiOptimizer;

    setUpAll(() async {
      await GetStorage.init();
    });

    setUp(() {
      Get.reset();
      apiOptimizer = ApiOptimizationService();
      Get.put(apiOptimizer);
    });

    tearDown(() async {
      await apiOptimizer.clearCache();
      apiOptimizer.resetRateLimits();
    });

    group('optimizeApiCall', () {
      test('should return cached data when available', () async {
        // Arrange
        const cacheKey = 'test_cache_key';
        const expectedData = {'test': 'data'};

        // İlk çağrı - cache'e yaz
        final result1 = await apiOptimizer.optimizeApiCall(
          apiCall: () async => expectedData,
          cacheKey: cacheKey,
          cacheDuration: const Duration(minutes: 5),
        );

        // Act - İkinci çağrı - cache'den oku
        final result2 = await apiOptimizer.optimizeApiCall(
          apiCall: () async => {'different': 'data'},
          cacheKey: cacheKey,
          cacheDuration: const Duration(minutes: 5),
        );

        // Assert
        expect(result1, equals(expectedData));
        expect(result2, equals(expectedData)); // Cache'den gelmeli
      });

      test('should make new API call when cache is expired', () async {
        // Arrange
        const cacheKey = 'test_expired_cache';
        const expectedData = {'fresh': 'data'};

        // İlk çağrı - kısa cache süresi
        await apiOptimizer.optimizeApiCall(
          apiCall: () async => {'old': 'data'},
          cacheKey: cacheKey,
          cacheDuration: const Duration(milliseconds: 1),
        );

        // Cache'in süresi dolması için bekle
        await Future.delayed(const Duration(milliseconds: 10));

        // Act - Yeni çağrı
        final result = await apiOptimizer.optimizeApiCall(
          apiCall: () async => expectedData,
          cacheKey: cacheKey,
          cacheDuration: const Duration(minutes: 5),
        );

        // Assert
        expect(result, equals(expectedData));
      });

      test('should force refresh when forceRefresh is true', () async {
        // Arrange
        const cacheKey = 'test_force_refresh';
        const freshData = {'fresh': 'data'};

        // İlk çağrı
        await apiOptimizer.optimizeApiCall(
          apiCall: () async => {'old': 'data'},
          cacheKey: cacheKey,
          cacheDuration: const Duration(minutes: 5),
        );

        // Act - Force refresh ile çağrı
        final result = await apiOptimizer.optimizeApiCall(
          apiCall: () async => freshData,
          cacheKey: cacheKey,
          forceRefresh: true,
        );

        // Assert
        expect(result, equals(freshData));
      });
    });

    group('batchApiCalls', () {
      test('should execute multiple API calls in parallel', () async {
        // Arrange
        final calls = {
          'data1': () async => {'key1': 'value1'},
          'data2': () async => {'key2': 'value2'},
          'data3': () async => {'key3': 'value3'},
        };

        // Act
        final results = await apiOptimizer.batchApiCalls(
          calls: calls,
          cacheDuration: const Duration(minutes: 5),
        );

        // Assert
        expect(results.length, equals(3));
        expect(results['data1'], equals({'key1': 'value1'}));
        expect(results['data2'], equals({'key2': 'value2'}));
        expect(results['data3'], equals({'key3': 'value3'}));
      });

      test('should handle errors in batch calls', () async {
        // Arrange
        final calls = {
          'success': () async => {'success': true},
          'error': () async => throw Exception('Test error'),
        };

        // Act & Assert
        expect(
          () => apiOptimizer.batchApiCalls(calls: calls),
          throwsA(isA<BatchApiException>()),
        );
      });
    });

    group('retryApiCall', () {
      test('should retry failed API calls', () async {
        // Arrange
        int attemptCount = 0;
        const maxAttempts = 3;

        // Act
        final result = await apiOptimizer.retryApiCall(
          apiCall: () async {
            attemptCount++;
            if (attemptCount < maxAttempts) {
              throw Exception('Temporary error');
            }
            return {'success': true};
          },
          maxAttempts: maxAttempts,
        );

        // Assert
        expect(result, equals({'success': true}));
        expect(attemptCount, equals(maxAttempts));
      });

      test('should throw after max attempts', () async {
        // Arrange
        const maxAttempts = 2;

        // Act & Assert
        expect(
          () => apiOptimizer.retryApiCall(
            apiCall: () async => throw Exception('Persistent error'),
            maxAttempts: maxAttempts,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('rate limiting', () {
      test('should respect rate limits', () async {
        // Arrange
        const cacheKey = 'rate_limit_test';
        final stopwatch = Stopwatch()..start();

        // Act - Hızlı ardışık çağrılar
        await Future.wait([
          apiOptimizer.optimizeApiCall(
            apiCall: () async => {'data': 1},
            cacheKey: cacheKey,
            useRateLimit: true,
          ),
          apiOptimizer.optimizeApiCall(
            apiCall: () async => {'data': 2},
            cacheKey: cacheKey,
            useRateLimit: true,
          ),
        ]);

        stopwatch.stop();

        // Assert - Rate limiting nedeniyle minimum süre geçmeli
        expect(stopwatch.elapsed.inMilliseconds, greaterThan(500));
      });
    });

    group('cache management', () {
      test('should clear specific cache key', () async {
        // Arrange
        const cacheKey = 'test_clear_specific';
        await apiOptimizer.optimizeApiCall(
          apiCall: () async => {'data': 'test'},
          cacheKey: cacheKey,
        );

        // Act
        await apiOptimizer.clearCache(cacheKey);

        // Assert - Cache temizlendi, yeni çağrı yapılmalı
        final result = await apiOptimizer.optimizeApiCall(
          apiCall: () async => {'data': 'fresh'},
          cacheKey: cacheKey,
        );

        expect(result, equals({'data': 'fresh'}));
      });

      test('should clear all cache', () async {
        // Arrange
        await apiOptimizer.optimizeApiCall(
          apiCall: () async => {'data1': 'test1'},
          cacheKey: 'key1',
        );
        await apiOptimizer.optimizeApiCall(
          apiCall: () async => {'data2': 'test2'},
          cacheKey: 'key2',
        );

        // Act
        await apiOptimizer.clearCache();

        // Assert - Tüm cache temizlendi
        final result1 = await apiOptimizer.optimizeApiCall(
          apiCall: () async => {'data1': 'fresh1'},
          cacheKey: 'key1',
        );
        final result2 = await apiOptimizer.optimizeApiCall(
          apiCall: () async => {'data2': 'fresh2'},
          cacheKey: 'key2',
        );

        expect(result1, equals({'data1': 'fresh1'}));
        expect(result2, equals({'data2': 'fresh2'}));
      });
    });
  });
}
