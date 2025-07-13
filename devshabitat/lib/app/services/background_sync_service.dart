import 'dart:async';
import 'dart:math' as math;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/models/message_model.dart';
import 'package:devshabitat/app/services/image_upload_service.dart';
import 'package:logger/logger.dart';

class BackgroundSyncService extends GetxService {
  final _syncQueue = <MessageModel>[].obs;
  final _isSyncing = false.obs;
  final _networkStatus = Rx<ConnectivityResult>(ConnectivityResult.none);
  final _syncStatus = ''.obs;
  final _batteryOptimized = true.obs;
  final _logger = Logger();

  Timer? _cleanupTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final _retryAttempts = 3;
  final _baseRetryDelay = const Duration(seconds: 2);
  final _maxRetryDelay = const Duration(minutes: 5);

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _startNetworkMonitoring();
    _startPeriodicCleanup();
  }

  void _startPeriodicCleanup() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      _cleanupResources();
    });
  }

  void _cleanupResources() {
    // Önbellek temizleme
    _syncQueue.removeWhere((message) {
      final age = DateTime.now().difference(message.timestamp);
      return age > const Duration(hours: 24);
    });

    // Gereksiz kaynakları serbest bırak
    Get.find<ImageUploadService>().clearCache();
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      if (results.isNotEmpty) {
        _networkStatus.value = results.first;
      }
    } catch (e) {
      print('Bağlantı durumu kontrol edilemedi: $e');
    }
  }

  void _startNetworkMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      if (results.isNotEmpty) {
        _networkStatus.value = results.first;
        if (results.first != ConnectivityResult.none) {
          _processSyncQueue();
        }
      }
    });
  }

  Future<void> addToSyncQueue(MessageModel message) async {
    _syncQueue.add(message);
    _updateSyncStatus(
        'Senkronizasyon kuyruğuna eklendi: ${_syncQueue.length} öğe');

    if (_networkStatus.value != ConnectivityResult.none && !_isSyncing.value) {
      await _processSyncQueue();
    }
  }

  Future<void> _processSyncQueue() async {
    if (_syncQueue.isEmpty || _isSyncing.value) return;

    _isSyncing.value = true;
    _updateSyncStatus('Senkronizasyon başlatılıyor...');

    try {
      final messagesToProcess = List<MessageModel>.from(_syncQueue);
      for (var message in messagesToProcess) {
        if (await _syncWithRetry(message)) {
          _syncQueue.remove(message);
        }
      }
    } finally {
      _isSyncing.value = false;
      _updateSyncStatus('Senkronizasyon tamamlandı');
    }
  }

  Future<bool> _syncWithRetry(MessageModel message) async {
    int attempts = 0;
    DateTime? lastAttempt;

    while (attempts < _retryAttempts) {
      try {
        // Eğer bu ilk deneme değilse, exponential backoff uygula
        if (lastAttempt != null) {
          final backoffDuration = _calculateBackoffDuration(attempts);
          _updateSyncStatus('Bekleniyor: ${backoffDuration.inSeconds} saniye');
          await Future.delayed(backoffDuration);
        }

        await _syncMessage(message);
        return true;
      } catch (e) {
        attempts++;
        lastAttempt = DateTime.now();

        if (attempts >= _retryAttempts) {
          _logger.e('Maksimum deneme sayısına ulaşıldı: $e');
          _updateSyncStatus('Senkronizasyon başarısız: ${e.toString()}');
          return false;
        }

        _updateSyncStatus('Yeniden deneme $attempts/$_retryAttempts');
        _logger.w('Sync retry attempt $attempts: ${e.toString()}');
      }
    }
    return false;
  }

  Duration _calculateBackoffDuration(int attempt) {
    // 2^n formülü ile exponential backoff hesapla (2, 4, 8, 16, 32 saniye...)
    final backoffSeconds = math.min(
      math.pow(2, attempt) * _baseRetryDelay.inSeconds,
      _maxRetryDelay.inSeconds,
    );

    // Rastgele jitter ekle (±%25)
    final jitter = math.Random().nextDouble() * 0.5 - 0.25; // -0.25 to +0.25
    final finalSeconds = backoffSeconds * (1 + jitter);

    return Duration(seconds: finalSeconds.round());
  }

  Future<void> _syncMessage(MessageModel message) async {
    // Sunucu ile senkronizasyon mantığı burada uygulanacak
    await Future.delayed(
        const Duration(seconds: 1)); // Simüle edilmiş ağ gecikmesi
  }

  void _updateSyncStatus(String status) {
    _syncStatus.value = status;
  }

  void setBatteryOptimization(bool enabled) {
    _batteryOptimized.value = enabled;
    // Pil optimizasyonu ayarlarını uygula
  }

  String get syncStatus => _syncStatus.value;
  bool get isSyncing => _isSyncing.value;
  bool get hasPendingSync => _syncQueue.isNotEmpty;

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    _cleanupTimer?.cancel();
    _syncQueue.clear();
    super.onClose();
  }
}
