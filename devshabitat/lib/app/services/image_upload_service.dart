import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageUploadService extends GetxService {
  static const String _baseUrl = 'https://api.devs-habitat.com/v1';
  static const String _uploadEndpoint = '/upload';

  // Resmi sunucuya yükle
  Future<String> uploadImage(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl$_uploadEndpoint'),
      );

      // Dosya adını ve uzantısını al
      final fileName = path.basename(imageFile.path);
      final fileExtension = path.extension(fileName);

      // Dosyayı request'e ekle
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType.parse(_getContentType(fileExtension)),
        ),
      );

      // İsteği gönder
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['url'] as String;
      } else {
        throw Exception('Resim yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Resim yüklenirken bir hata oluştu: $e');
    }
  }

  // Dosya uzantısına göre content type belirle
  String _getContentType(String fileExtension) {
    switch (fileExtension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  // Resmi sıkıştır
  Future<File> compressImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) throw Exception('Resim decode edilemedi');

      final compressed = img.encodeJpg(image, quality: 85);
      final tempDir = await getTemporaryDirectory();
      final compressedFile =
          File('${tempDir.path}/compressed_${path.basename(file.path)}');

      await compressedFile.writeAsBytes(compressed);
      return compressedFile;
    } catch (e) {
      throw Exception('Resim sıkıştırılırken hata oluştu: $e');
    }
  }

  // Resmi yeniden boyutlandır
  Future<File> resizeImage(File file,
      {int maxWidth = 1080, int maxHeight = 1080}) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) throw Exception('Resim decode edilemedi');

      final resized = img.copyResize(
        image,
        width: maxWidth,
        height: maxHeight,
        interpolation: img.Interpolation.linear,
      );

      final tempDir = await getTemporaryDirectory();
      final resizedFile =
          File('${tempDir.path}/resized_${path.basename(file.path)}');

      await resizedFile.writeAsBytes(img.encodeJpg(resized));
      return resizedFile;
    } catch (e) {
      throw Exception('Resim yeniden boyutlandırılırken hata oluştu: $e');
    }
  }
}
