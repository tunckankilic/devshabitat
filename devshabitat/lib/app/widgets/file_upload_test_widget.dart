import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'advanced_file_upload.dart';
import '../controllers/file_upload_controller.dart';
import '../repositories/auth_repository.dart';

class FileUploadTestWidget extends StatelessWidget {
  const FileUploadTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Upload Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'File Upload Sistemi Test',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Bu sayfa file upload sistemini test etmek için oluşturulmuştur.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Basic File Upload
            const Text(
              'Temel Dosya Yükleme',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            AdvancedFileUpload(
              userId:
                  Get.find<AuthRepository>().currentUser?.uid ?? 'test_user',
              conversationId: 'test_conversation',
              onFilesSelected: (files) {
                print('Seçilen dosyalar: ${files.length}');
                Get.snackbar(
                  'Dosya Seçildi',
                  '${files.length} dosya seçildi',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              onFileUploaded: (attachment) {
                print('Yüklenen dosya: ${attachment.name}');
                Get.snackbar(
                  'Dosya Yüklendi',
                  '${attachment.name} başarıyla yüklendi',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
              onUploadCancelled: (messageId) {
                print('İptal edilen yükleme: $messageId');
                Get.snackbar(
                  'Yükleme İptal',
                  'Dosya yükleme iptal edildi',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              },
              customTitle: 'Test Dosyası Yükle',
              customSubtitle: 'Dosya yükleme sistemini test edin',
            ),

            const SizedBox(height: 30),

            // Image Only Upload
            const Text(
              'Sadece Resim Yükleme',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            AdvancedFileUpload(
              userId:
                  Get.find<AuthRepository>().currentUser?.uid ?? 'test_user',
              conversationId: 'test_images',
              onFilesSelected: (files) {
                print('Seçilen resimler: ${files.length}');
              },
              onFileUploaded: (attachment) {
                print('Yüklenen resim: ${attachment.name}');
              },
              onUploadCancelled: (messageId) {
                print('İptal edilen resim yükleme: $messageId');
              },
              customTitle: 'Resim Yükle',
              customSubtitle: 'Sadece resim dosyaları kabul edilir',
              allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
              maxFileSizeMB: 2,
            ),

            const SizedBox(height: 30),

            // Document Only Upload
            const Text(
              'Sadece Belge Yükleme',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            AdvancedFileUpload(
              userId:
                  Get.find<AuthRepository>().currentUser?.uid ?? 'test_user',
              conversationId: 'test_documents',
              onFilesSelected: (files) {
                print('Seçilen belgeler: ${files.length}');
              },
              onFileUploaded: (attachment) {
                print('Yüklenen belge: ${attachment.name}');
              },
              onUploadCancelled: (messageId) {
                print('İptal edilen belge yükleme: $messageId');
              },
              customTitle: 'Belge Yükle',
              customSubtitle: 'PDF, DOC, DOCX dosyaları kabul edilir',
              allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
              maxFileSizeMB: 10,
            ),

            const SizedBox(height: 30),

            // Progress Tracking Test
            const Text(
              'Yükleme İlerlemesi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() {
              final controller = Get.find<FileUploadController>();
              return Column(
                children: [
                  if (controller.isUploading.value)
                    const LinearProgressIndicator(),
                  if (controller.uploadProgress.isNotEmpty)
                    ...controller.uploadProgress.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Yükleniyor: ${entry.key}'),
                            LinearProgressIndicator(value: entry.value),
                            Text('${(entry.value * 100).toInt()}%'),
                          ],
                        ),
                      );
                    }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
