import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/image_upload_controller.dart';
import 'adaptive_progress_indicator.dart';

class ResponsiveImagePicker extends StatelessWidget {
  final ImageUploadController imageUploadController;
  final double size;

  const ResponsiveImagePicker({
    super.key,
    required this.imageUploadController,
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedImage = imageUploadController.selectedImage;
      final isUploading = imageUploadController.isUploading;
      final uploadProgress = imageUploadController.uploadProgress;

      return Stack(
        children: [
          // Profil Resmi
          CircleAvatar(
            radius: size / 2,
            backgroundImage:
                selectedImage != null ? FileImage(selectedImage) : null,
            child: selectedImage == null
                ? Icon(Icons.person, size: size / 2)
                : null,
          ),

          // Yükleme İndikatörü
          if (isUploading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AdaptiveProgressIndicator(
                    progress: uploadProgress,
                    size: size / 2,
                  ),
                ),
              ),
            ),

          // Resim Seçme Butonu
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                onPressed: () => _showImageSourceDialog(context),
              ),
            ),
          ),
        ],
      );
    });
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.selectProfileImage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppStrings.selectFromGallery),
              onTap: () {
                Navigator.pop(context);
                imageUploadController.pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(AppStrings.takePhoto),
              onTap: () {
                Navigator.pop(context);
                imageUploadController.takeImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }
}
