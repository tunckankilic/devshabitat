import 'dart:io';
import 'dart:async';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:devshabitat/app/models/message_model.dart';
import 'package:devshabitat/app/services/background_sync_service.dart';

class ChatManagementController extends GetxController {
  final BackgroundSyncService _syncService = Get.find<BackgroundSyncService>();
  final _storage = FirebaseStorage.instance;
  final _memoryUsage = 0.0.obs;
  final _isProcessing = false.obs;
  Timer? _memoryMonitorTimer;

  bool get isProcessing => _isProcessing.value;
  double get memoryUsage => _memoryUsage.value;

  @override
  void onInit() {
    super.onInit();
    _startMemoryMonitoring();
  }

  @override
  void onClose() {
    _memoryMonitorTimer?.cancel();
    super.onClose();
  }

  void _startMemoryMonitoring() {
    _memoryMonitorTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _updateMemoryUsage();
    });
  }

  Future<void> archiveChat(String chatId) async {
    if (_isProcessing.value) return;
    _isProcessing.value = true;

    try {
      // Sohbet verilerini yerel olarak arşivle
      final archiveDir = await _getArchiveDirectory();
      final archiveFile = File('${archiveDir.path}/$chatId.archive');

      // Arşiv işlemi tamamlanana kadar senkronizasyonu bekle
      while (_syncService.hasPendingSync) {
        await Future.delayed(const Duration(seconds: 1));
      }

      // Firebase Storage'a yedekle
      final storageRef = _storage.ref('archives/$chatId.archive');
      await storageRef.putFile(archiveFile);

      // Arşiv durumunu güncelle
      // TODO: Veritabanında arşiv durumunu güncelle
    } catch (e) {
      print('Sohbet arşivleme hatası: $e');
      rethrow;
    } finally {
      _isProcessing.value = false;
    }
  }

  Future<void> exportChat(String chatId, {String format = 'json'}) async {
    if (_isProcessing.value) return;
    _isProcessing.value = true;

    try {
      final exportDir = await getTemporaryDirectory();
      final exportFile = File('${exportDir.path}/$chatId.$format');

      // Sohbet verilerini dışa aktar
      // TODO: Sohbet verilerini seçilen formatta dışa aktar

      // Dışa aktarılan dosyayı kullanıcıya sun
      // TODO: Share plugin ile dosyayı paylaş
    } catch (e) {
      print('Sohbet dışa aktarma hatası: $e');
      rethrow;
    } finally {
      _isProcessing.value = false;
    }
  }

  Future<void> deleteChat(String chatId) async {
    if (_isProcessing.value) return;
    _isProcessing.value = true;

    try {
      // Senkronizasyon tamamlanana kadar bekle
      while (_syncService.hasPendingSync) {
        await Future.delayed(const Duration(seconds: 1));
      }

      // Firebase Storage'dan arşivi sil
      final storageRef = _storage.ref('archives/$chatId.archive');
      await storageRef.delete();

      // Yerel verileri temizle
      await _cleanupLocalData(chatId);

      // Bellek kullanımını güncelle
      await _updateMemoryUsage();
    } catch (e) {
      print('Sohbet silme hatası: $e');
      rethrow;
    } finally {
      _isProcessing.value = false;
    }
  }

  Future<void> _cleanupLocalData(String chatId) async {
    final archiveDir = await _getArchiveDirectory();
    final archiveFile = File('${archiveDir.path}/$chatId.archive');

    if (await archiveFile.exists()) {
      await archiveFile.delete();
    }

    // Önbellek temizliği
    // TODO: Medya dosyalarını ve önbelleği temizle
  }

  Future<Directory> _getArchiveDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final archiveDir = Directory('${appDir.path}/archives');

    if (!await archiveDir.exists()) {
      await archiveDir.create(recursive: true);
    }

    return archiveDir;
  }

  Future<void> _updateMemoryUsage() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      int totalSize = 0;

      await for (var entity in appDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      _memoryUsage.value = totalSize / (1024 * 1024); // MB cinsinden
    } catch (e) {
      print('Bellek kullanımı hesaplama hatası: $e');
    }
  }
}
