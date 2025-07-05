import 'dart:async';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:get_storage/get_storage.dart';
import '../interfaces/disposable.dart';

class ApiOptimizationService extends GetxService {
  static ApiOptimizationService get to => Get.find();

  final Logger _logger = Logger();
  final GetStorage _storage = GetStorage();

  // API çağrıları için rate limiting
  final Map<String, DateTime> _lastCallTimes = {};
  final Map<String, int> _callCounts = {};

  // Önbellek ayarları
  static const Duration defaultCacheDuration = Duration(minutes: 5);
  static const Duration minCallInterval = Duration(milliseconds: 500);
  static const int maxCallsPerMinute = 60;

  // API çağrısını optimize et
  Future<T> optimizeApiCall<T>({
    required Future<T> Function() apiCall,
    required String cacheKey,
    Duration? cacheDuration,
    bool forceRefresh = false,
    bool useRateLimit = true,
  }) async {
    try {
      // Rate limiting kontrolü
      if (useRateLimit) {
        await _checkRateLimit(cacheKey);
      }

      // Önbellekten veri kontrolü
      if (!forceRefresh) {
        final cachedData = await _getCachedData<T>(cacheKey);
        if (cachedData != null) {
          return cachedData;
        }
      }

      // API çağrısını yap
      final result = await apiCall();

      // Sonucu önbelleğe al
      await _cacheData(
        cacheKey,
        result,
        cacheDuration ?? defaultCacheDuration,
      );

      return result;
    } catch (e) {
      _logger.e('Error in optimized API call: $e');
      rethrow;
    }
  }

  // Rate limiting kontrolü
  Future<void> _checkRateLimit(String key) async {
    final now = DateTime.now();

    // Son çağrı zamanını kontrol et
    final lastCallTime = _lastCallTimes[key];
    if (lastCallTime != null) {
      final timeSinceLastCall = now.difference(lastCallTime);
      if (timeSinceLastCall < minCallInterval) {
        final waitTime = minCallInterval - timeSinceLastCall;
        await Future.delayed(waitTime);
      }
    }

    // Dakikalık çağrı sayısını kontrol et
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
    _callCounts[key] = (_callCounts[key] ?? 0) + 1;

    // Eski çağrıları temizle
    _lastCallTimes.removeWhere(
      (k, v) => now.difference(v) > const Duration(minutes: 1),
    );

    if ((_callCounts[key] ?? 0) > maxCallsPerMinute) {
      throw Exception('Rate limit exceeded for $key');
    }

    _lastCallTimes[key] = now;
  }

  // Önbellekten veri al
  Future<T?> _getCachedData<T>(String key) async {
    try {
      final cacheData = await _storage.read('api_cache_$key');
      if (cacheData != null) {
        final expiryTime = DateTime.parse(cacheData['expiry']);
        if (DateTime.now().isBefore(expiryTime)) {
          return cacheData['data'] as T;
        }
      }
      return null;
    } catch (e) {
      _logger.e('Error reading from cache: $e');
      return null;
    }
  }

  // Veriyi önbelleğe al
  Future<void> _cacheData<T>(
    String key,
    T data,
    Duration duration,
  ) async {
    try {
      final expiryTime = DateTime.now().add(duration);
      await _storage.write('api_cache_$key', {
        'data': data,
        'expiry': expiryTime.toIso8601String(),
      });
    } catch (e) {
      _logger.e('Error writing to cache: $e');
    }
  }

  // Önbelleği temizle
  Future<void> clearCache([String? key]) async {
    try {
      if (key != null) {
        await _storage.remove('api_cache_$key');
      } else {
        final keys = _storage.getKeys();
        for (var k in keys) {
          if (k.startsWith('api_cache_')) {
            await _storage.remove(k);
          }
        }
      }
    } catch (e) {
      _logger.e('Error clearing cache: $e');
    }
  }

  // Rate limit sayaçlarını sıfırla
  void resetRateLimits([String? key]) {
    if (key != null) {
      _lastCallTimes.remove(key);
      _callCounts.remove(key);
    } else {
      _lastCallTimes.clear();
      _callCounts.clear();
    }
  }

  // API çağrılarını grupla
  Future<Map<String, T>> batchApiCalls<T>({
    required Map<String, Future<T> Function()> calls,
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) async {
    final results = <String, T>{};
    final errors = <String, dynamic>{};

    await Future.wait(
      calls.entries.map((entry) async {
        try {
          results[entry.key] = await optimizeApiCall(
            apiCall: entry.value,
            cacheKey: entry.key,
            cacheDuration: cacheDuration,
            forceRefresh: forceRefresh,
          );
        } catch (e) {
          errors[entry.key] = e;
          _logger.e('Error in batch API call ${entry.key}: $e');
        }
      }),
    );

    if (errors.isNotEmpty) {
      throw BatchApiException(results, errors);
    }

    return results;
  }

  // API çağrılarını sırala
  Future<List<T>> sequentialApiCalls<T>({
    required List<Future<T> Function()> calls,
    Duration? delayBetweenCalls,
  }) async {
    final results = <T>[];

    for (var call in calls) {
      try {
        final result = await call();
        results.add(result);

        if (delayBetweenCalls != null) {
          await Future.delayed(delayBetweenCalls);
        }
      } catch (e) {
        _logger.e('Error in sequential API call: $e');
        rethrow;
      }
    }

    return results;
  }

  // Retry mekanizması
  Future<T> retryApiCall<T>({
    required Future<T> Function() apiCall,
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    Duration maxDelay = const Duration(seconds: 10),
  }) async {
    Duration delay = initialDelay;
    int attempts = 0;

    while (true) {
      try {
        attempts++;
        return await apiCall();
      } catch (e) {
        if (attempts >= maxAttempts) {
          _logger.e('Max retry attempts reached: $e');
          rethrow;
        }

        _logger.w('Retry attempt $attempts failed: $e');
        await Future.delayed(delay);

        // Exponential backoff
        delay *= 2;
        if (delay > maxDelay) {
          delay = maxDelay;
        }
      }
    }
  }

  @override
  void onClose() {
    resetRateLimits();
    super.onClose();
  }
}

class BatchApiException implements Exception {
  final Map<String, dynamic> successfulResults;
  final Map<String, dynamic> errors;

  BatchApiException(this.successfulResults, this.errors);

  @override
  String toString() {
    return 'BatchApiException: ${errors.length} errors occurred. '
        'Successful results: ${successfulResults.length}';
  }
}
