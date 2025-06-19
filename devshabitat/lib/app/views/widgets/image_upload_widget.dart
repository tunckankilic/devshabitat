import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/image_upload_controller.dart';

class ImageUploadWidget extends StatelessWidget {
  final controller = Get.find<ImageUploadController>();

  ImageUploadWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isUploading) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              value: controller.uploadProgress,
            ),
            const SizedBox(height: 16),
            Text('${(controller.uploadProgress * 100).toInt()}%'),
          ],
        );
      }

      if (controller.error.isNotEmpty) {
        return Center(
          child: Text(controller.error),
        );
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: controller.pickImageFromGallery,
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: controller.takeImageFromCamera,
          ),
        ],
      );
    });
  }
}
