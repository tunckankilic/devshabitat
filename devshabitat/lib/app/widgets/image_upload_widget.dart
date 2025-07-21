// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageUploadWidget extends StatelessWidget {
  final Function(String) onImageSelected;
  final String? imageUrl;
  final double aspectRatio;
  final int maxWidth;
  final int maxHeight;
  final String label;

  const ImageUploadWidget({
    super.key,
    required this.onImageSelected,
    this.imageUrl,
    this.aspectRatio = 1.0,
    this.maxWidth = 1024,
    this.maxHeight = 1024,
    required this.label,
  });

  Future<void> _pickImage(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // Resmi yükle ve optimize et
        final optimizedImagePath = await _optimizeImage(
          File(pickedFile.path),
          maxWidth,
          maxHeight,
        );

        onImageSelected(optimizedImagePath);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resim seçilirken bir hata oluştu: $e'),
        ),
      );
    }
  }

  Future<String> _optimizeImage(
      File imageFile, int maxWidth, int maxHeight) async {
    // Resmi yükle
    final bytes = await imageFile.readAsBytes();
    var image = img.decodeImage(bytes);

    if (image == null) throw Exception('Resim yüklenemedi');

    // En boy oranını koru
    double ratio = image.width / image.height;
    int targetWidth = maxWidth;
    int targetHeight = (targetWidth / ratio).round();

    if (targetHeight > maxHeight) {
      targetHeight = maxHeight;
      targetWidth = (targetHeight * ratio).round();
    }

    // Resmi yeniden boyutlandır
    final resized = img.copyResize(
      image,
      width: targetWidth,
      height: targetHeight,
    );

    // Optimize edilmiş resmi geçici dizine kaydet
    final tempDir = await getTemporaryDirectory();
    final tempPath =
        '${tempDir.path}/optimized_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final optimizedFile = File(tempPath);

    // JPEG olarak kaydet (kalite: 85)
    await optimizedFile.writeAsBytes(img.encodeJpg(resized, quality: 85));

    return tempPath;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[400]!,
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: () => _pickImage(context),
              child: imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder(context);
                        },
                      ),
                    )
                  : _buildPlaceholder(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate,
          size: 48,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.selectImage,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
