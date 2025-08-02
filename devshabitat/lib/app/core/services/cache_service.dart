import 'dart:async';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'memory_manager_service.dart';

class CacheEntry<T> {
  final T data;
  final DateTime expiresAt;

  CacheEntry(this.data, this.expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class CacheService extends GetxService {
  final Logger _logger = Logger();
  final MemoryManagerService _memoryManager = Get.find();

  final Map<String, CacheEntry<dynamic>> _cache = {};
  final Duration _defaultExpiration = const Duration(minutes: 30);
  Timer? _cleanupTimer;

  @override
  void onInit() {
    super.onInit();
    _startCleanupTimer();
  }

  @override
  void onClose() {
    _cleanupTimer?.cancel();
    super.onClose();
  }

  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _cleanExpiredEntries(),
    );
  }

  void _cleanExpiredEntries() {
    final now = DateTime.now();
    final expiredKeys = _cache.keys
        .where(
          (key) => _cache[key]?.isExpired ?? false,
        )
        .toList();

    for (final key in expiredKeys) {
      _cache.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      _logger.i('Cleaned ${expiredKeys.length} expired cache entries');
      _memoryManager.optimizeMemory();
    }
  }

  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    return entry.data as T;
  }

  void set<T>(
    String key,
    T value, {
    Duration? expiration,
  }) {
    final expiresAt = DateTime.now().add(expiration ?? _defaultExpiration);
    _cache[key] = CacheEntry<T>(value, expiresAt);
  }

  Future<T> getOrFetch<T>(
    String key,
    Future<T> Function() fetchData, {
    Duration? expiration,
  }) async {
    final cachedValue = get<T>(key);
    if (cachedValue != null) {
      return cachedValue;
    }

    final value = await fetchData();
    set<T>(key, value, expiration: expiration);
    return value;
  }

  void remove(String key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
    _memoryManager.optimizeMemory();
  }

  bool containsKey(String key) => _cache.containsKey(key);

  int get size => _cache.length;

  List<String> get keys => _cache.keys.toList();

  void setMultiple<T>(Map<String, T> entries, {Duration? expiration}) {
    entries.forEach((key, value) {
      set<T>(key, value, expiration: expiration);
    });
  }

  Map<String, T> getMultiple<T>(List<String> keys) {
    return Map.fromEntries(
      keys.map((key) {
        final value = get<T>(key);
        return value != null ? MapEntry(key, value) : null;
      }).whereType<MapEntry<String, T>>(),
    );
  }

  void removeMultiple(List<String> keys) {
    keys.forEach(remove);
  }

  Duration? getTimeToExpiration(String key) {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) return null;

    return entry.expiresAt.difference(DateTime.now());
  }

  void updateExpiration(String key, Duration newExpiration) {
    final entry = _cache[key];
    if (entry == null) return;

    final newExpiresAt = DateTime.now().add(newExpiration);
    _cache[key] = CacheEntry(entry.data, newExpiresAt);
  }

  Map<String, dynamic> getStats() {
    final now = DateTime.now();
    final totalEntries = _cache.length;
    final expiredEntries =
        _cache.values.where((entry) => entry.isExpired).length;
    final avgTimeToExpiration = _cache.isEmpty
        ? 0.0
        : _cache.values
                .map((entry) => entry.expiresAt.difference(now).inSeconds)
                .reduce((a, b) => a + b) /
            totalEntries;

    return {
      'totalEntries': totalEntries,
      'expiredEntries': expiredEntries,
      'activeEntries': totalEntries - expiredEntries,
      'avgTimeToExpirationSeconds': avgTimeToExpiration,
    };
  }
}
