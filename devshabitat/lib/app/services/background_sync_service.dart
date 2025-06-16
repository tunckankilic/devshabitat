import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/models/message_model.dart';

class BackgroundSyncService extends GetxService {
  final _syncQueue = <Message>[].obs;
  final _isSyncing = false.obs;
  final _networkStatus = Rx<ConnectivityResult>(ConnectivityResult.none);
  final _syncStatus = ''.obs;
  final _batteryOptimized = true.obs;

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final _retryAttempts = 3;
  final _retryDelay = const Duration(seconds: 5);

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _startNetworkMonitoring();
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

  Future<void> addToSyncQueue(Message message) async {
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
      for (var message in _syncQueue) {
        bool synced = false;
        int attempts = 0;

        while (!synced && attempts < _retryAttempts) {
          try {
            await _syncMessage(message);
            synced = true;
            _syncQueue.remove(message);
          } catch (e) {
            attempts++;
            if (attempts < _retryAttempts) {
              _updateSyncStatus('Yeniden deneme $attempts/$_retryAttempts');
              await Future.delayed(_retryDelay);
            }
          }
        }
      }
    } finally {
      _isSyncing.value = false;
      _updateSyncStatus('Senkronizasyon tamamlandı');
    }
  }

  Future<void> _syncMessage(Message message) async {
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
    _connectivitySubscription.cancel();
    super.onClose();
  }
}
