import 'dart:async';
import 'dart:math' as math;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/models/message_model.dart';
import 'package:devshabitat/app/services/image_upload_service.dart';
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

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

  // Enhanced sync capabilities
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  bool _isLowEndDevice = false;
  int _syncBatchSize = 10;
  Duration _syncInterval = const Duration(minutes: 5);

  // Performance tracking
  int _successfulSyncs = 0;
  int _failedSyncs = 0;
  DateTime _lastSyncAttempt = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _startNetworkMonitoring();
    _startPeriodicCleanup();
    _initializeDeviceOptimizations();
  }

  Future<void> _initializeDeviceOptimizations() async {
    try {
      await _analyzeDeviceCapabilities();
      if (_batteryOptimized.value) {
        await _applyBatteryOptimizations();
      }
      _logger.i('Device optimizations initialized');
    } catch (e) {
      _logger.e('Error initializing device optimizations: $e');
    }
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
    try {
      _lastSyncAttempt = DateTime.now();

      // Network connectivity check
      if (!await _isNetworkAvailable()) {
        throw Exception('No network connection available');
      }

      // Battery optimization - skip sync if device is critical
      if (_batteryOptimized.value && await _isBatteryCritical()) {
        _logger.w('Skipping sync due to critical battery level');
        return;
      }

      // Prepare message data for Firestore
      final messageData = {
        'id': message.id,
        'content': message.content,
        'senderId': message.senderId,
        'senderName': message.senderName,
        'conversationId': message.conversationId,
        'timestamp': FieldValue.serverTimestamp(),
        'messageType': message.type.toString(),
        'isRead': message.isRead,
        'isEdited': message.isEdited,
        'localTimestamp': message.timestamp.millisecondsSinceEpoch,
        'syncStatus': 'synced',
        'syncedAt': FieldValue.serverTimestamp(),
      };

      // Add optional fields
      if (message.replyToId != null) {
        messageData['replyToId'] = message.replyToId!;
      }
      if (message.mediaUrl != null) {
        messageData['mediaUrl'] = message.mediaUrl!;
      }
      if (message.documentUrl != null) {
        messageData['documentUrl'] = message.documentUrl!;
      }
      if (message.links.isNotEmpty) {
        messageData['links'] = message.links;
      }

      // Handle attachments if present
      if (message.attachments.isNotEmpty) {
        final attachmentData = message.attachments
            .map((attachment) => {
                  'url': attachment.url,
                  'name': attachment.name,
                  'size': attachment.size,
                  'type': attachment.type.toString(),
                })
            .toList();
        messageData['attachments'] = attachmentData;
      }

      // Sync to Firestore with retry logic
      await _syncToFirestore(message.id, messageData);

      _successfulSyncs++;
      _logger.i('Message synced successfully: ${message.id}');
    } catch (e) {
      _failedSyncs++;
      _logger.e('Failed to sync message ${message.id}: $e');
      rethrow;
    }
  }

  Future<void> _syncToFirestore(
      String messageId, Map<String, dynamic> data) async {
    final batch = _firestore.batch();

    // Add to messages collection
    final messageRef = _firestore.collection('messages').doc(messageId);
    batch.set(messageRef, data, SetOptions(merge: true));

    // Update conversation last message
    if (data['conversationId'] != null) {
      final conversationRef =
          _firestore.collection('conversations').doc(data['conversationId']);
      batch.set(
          conversationRef,
          {
            'lastMessage': data['content'],
            'lastMessageTimestamp': data['timestamp'],
            'lastMessageSenderId': data['senderId'],
            'lastMessageSenderName': data['senderName'],
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
    }

    // Commit batch
    await batch.commit();
  }

  Future<bool> _isNetworkAvailable() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result.first != ConnectivityResult.none;
    } catch (e) {
      _logger.w('Network check failed: $e');
      return false;
    }
  }

  Future<bool> _isBatteryCritical() async {
    try {
      // Simple heuristic: if we've had many failed syncs recently, assume battery issues
      if (_failedSyncs > _successfulSyncs && _failedSyncs > 5) {
        return true;
      }

      // Check device performance as a battery indicator
      if (_isLowEndDevice) {
        final now = DateTime.now();
        final lastSync = _lastSyncAttempt;
        final timeSinceLastSync = now.difference(lastSync).inMinutes;

        // If it's been a while since last sync on low-end device, assume battery conservation
        return timeSinceLastSync > 30;
      }

      return false;
    } catch (e) {
      _logger.w('Battery check failed: $e');
      return false;
    }
  }

  void _updateSyncStatus(String status) {
    _syncStatus.value = status;
  }

  Future<void> setBatteryOptimization(bool enabled) async {
    try {
      _batteryOptimized.value = enabled;

      if (enabled) {
        await _applyBatteryOptimizations();
        _logger.i('Battery optimization enabled');
      } else {
        await _disableBatteryOptimizations();
        _logger.i('Battery optimization disabled');
      }
    } catch (e) {
      _logger.e('Error setting battery optimization: $e');
    }
  }

  Future<void> _applyBatteryOptimizations() async {
    // Analyze device capabilities
    await _analyzeDeviceCapabilities();

    if (_isLowEndDevice) {
      // Aggressive optimization for low-end devices
      _syncBatchSize = 5; // Smaller batches
      _syncInterval = const Duration(minutes: 10); // Less frequent sync
      _logger.i('Applied aggressive battery optimization for low-end device');
    } else {
      // Moderate optimization for higher-end devices
      _syncBatchSize = 8;
      _syncInterval = const Duration(minutes: 7);
      _logger.i('Applied moderate battery optimization');
    }

    // Restart cleanup timer with new interval
    _restartCleanupTimer();
  }

  Future<void> _disableBatteryOptimizations() async {
    // Reset to default high-performance settings
    _syncBatchSize = 10;
    _syncInterval = const Duration(minutes: 5);

    // Restart cleanup timer with default interval
    _restartCleanupTimer();
  }

  Future<void> _analyzeDeviceCapabilities() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        // Consider device as low-end based on Android version and features
        _isLowEndDevice = sdkInt < 28 || // Android 9.0
            !androidInfo.systemFeatures
                .contains('android.hardware.vulkan.level') ||
            !androidInfo.systemFeatures.contains('android.hardware.ram.normal');

        _logger.i(
            'Android device analysis: SDK $sdkInt, isLowEnd: $_isLowEndDevice');
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        final model = iosInfo.model.toLowerCase();

        // Consider older iOS devices as low-end
        _isLowEndDevice = model.contains('iphone 6') ||
            model.contains('iphone 7') ||
            model.contains('iphone se') ||
            iosInfo.systemVersion.startsWith('13') ||
            iosInfo.systemVersion.startsWith('14');

        _logger.i(
            'iOS device analysis: ${iosInfo.model}, isLowEnd: $_isLowEndDevice');
      }
    } catch (e) {
      _logger.w('Device analysis failed, assuming mid-range device: $e');
      _isLowEndDevice = false;
    }
  }

  void _restartCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(_syncInterval, (_) {
      _cleanupResources();
    });
  }

  // Performance monitoring getters
  Map<String, dynamic> get syncStats => {
        'successfulSyncs': _successfulSyncs,
        'failedSyncs': _failedSyncs,
        'syncBatchSize': _syncBatchSize,
        'syncInterval': _syncInterval.inMinutes,
        'isLowEndDevice': _isLowEndDevice,
        'batteryOptimized': _batteryOptimized.value,
        'lastSyncAttempt': _lastSyncAttempt.toIso8601String(),
        'pendingMessages': _syncQueue.length,
      };

  bool get isLowEndDevice => _isLowEndDevice;
  Duration get currentSyncInterval => _syncInterval;

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
