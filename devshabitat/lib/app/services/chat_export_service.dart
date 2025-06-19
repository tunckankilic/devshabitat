import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:devshabitat/app/models/message_model.dart';

class ChatExportService extends GetxService {
  final _exportProgress = 0.0.obs;
  final _isExporting = false.obs;

  double get exportProgress => _exportProgress.value;
  bool get isExporting => _isExporting.value;

  Future<void> exportToJson({
    required String conversationId,
    required List<Message> messages,
    String? title,
  }) async {
    _isExporting.value = true;
    _exportProgress.value = 0.0;

    try {
      // JSON formatında veri hazırlama
      final exportData = {
        'conversationId': conversationId,
        'title': title ?? 'Sohbet Dışa Aktarımı',
        'exportDate': DateTime.now().toIso8601String(),
        'messageCount': messages.length,
        'messages': messages.map((message) => message.toJson()).toList(),
      };

      _exportProgress.value = 0.5;

      // Dosya oluşturma
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      final file = await _createExportFile(
        'sohbet_${conversationId}_${DateTime.now().millisecondsSinceEpoch}.json',
        jsonString,
      );

      _exportProgress.value = 1.0;

      // Dosyayı paylaşma
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Sohbet Dışa Aktarımı',
      );

      Get.snackbar(
        'Başarılı',
        'Sohbet JSON formatında dışa aktarıldı',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Dışa aktarma sırasında hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isExporting.value = false;
      _exportProgress.value = 0.0;
    }
  }

  Future<void> exportToCsv({
    required String conversationId,
    required List<Message> messages,
    String? title,
  }) async {
    _isExporting.value = true;
    _exportProgress.value = 0.0;

    try {
      // CSV formatında veri hazırlama
      final csvLines = <String>[];
      csvLines.add('Tarih,Gönderen,Mesaj,Tip');

      for (int i = 0; i < messages.length; i++) {
        final message = messages[i];
        final csvLine = [
          message.timestamp.toIso8601String(),
          _escapeCsvValue(message.senderName),
          _escapeCsvValue(message.content),
          message.type.toString().split('.').last,
        ].join(',');
        csvLines.add(csvLine);

        _exportProgress.value = (i / messages.length) * 0.8;
      }

      final csvContent = csvLines.join('\n');
      final file = await _createExportFile(
        'sohbet_${conversationId}_${DateTime.now().millisecondsSinceEpoch}.csv',
        csvContent,
      );

      _exportProgress.value = 1.0;

      // Dosyayı paylaşma
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Sohbet Dışa Aktarımı (CSV)',
      );

      Get.snackbar(
        'Başarılı',
        'Sohbet CSV formatında dışa aktarıldı',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Dışa aktarma sırasında hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isExporting.value = false;
      _exportProgress.value = 0.0;
    }
  }

  Future<File> _createExportFile(String fileName, String content) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content);
    return file;
  }

  String _escapeCsvValue(String value) {
    // CSV için özel karakterleri escape etme
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  Future<List<File>> getExportedFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory
          .listSync()
          .whereType<File>()
          .cast<File>()
          .where((file) => file.path.contains('sohbet_'))
          .toList();
      return files;
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteExportedFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Dosya silinirken hata: $e');
    }
  }
}
