import 'dart:io';
import 'package:get/get.dart';
import 'package:html/parser.dart' show parse;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;
import '../../core/config/validation_config.dart';
import '../../core/error/validation_error.dart';

class ValidationService extends GetxService {
  String _unescapeHtml(String text) {
    final document = parse(text);
    return document.body?.text ?? text;
  }

  final _urlPattern = RegExp(
    r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
  );
  final _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Metin validasyonları
  String? validateText(
    String? value, {
    String? fieldName,
    int minLength = 1,
    int maxLength = 500,
    bool isRequired = true,
    bool allowHtml = false,
  }) {
    if (value == null || value.isEmpty) {
      return isRequired ? '${fieldName ?? 'Bu alan'} zorunludur' : null;
    }

    if (value.length < minLength) {
      return '${fieldName ?? 'Bu alan'} en az $minLength karakter olmalıdır';
    }

    if (value.length > maxLength) {
      return '${fieldName ?? 'Bu alan'} en fazla $maxLength karakter olabilir';
    }

    if (!allowHtml && value.contains(RegExp(r'<[^>]*>'))) {
      return '${fieldName ?? 'Bu alan'} HTML etiketleri içeremez';
    }

    return null;
  }

  // URL validasyonu
  String? validateUrl(String? value, {bool isRequired = true}) {
    if (value == null || value.isEmpty) {
      return isRequired ? 'URL zorunludur' : null;
    }

    if (!_urlPattern.hasMatch(value)) {
      return 'Geçerli bir URL giriniz';
    }

    return null;
  }

  // Email validasyonu
  String? validateEmail(String? value, {bool isRequired = true}) {
    if (value == null || value.isEmpty) {
      return isRequired ? 'E-posta adresi zorunludur' : null;
    }

    if (!_emailPattern.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi giriniz';
    }

    return null;
  }

  // Dosya validasyonu
  Future<String?> validateFile(
    File file, {
    required List<String> allowedExtensions,
    required int maxSizeInMB,
    bool isImage = false,
  }) async {
    // Dosya uzantısı kontrolü
    final extension = file.path.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      return 'Desteklenmeyen dosya türü. İzin verilen türler: ${allowedExtensions.join(', ')}';
    }

    // Dosya boyutu kontrolü
    final sizeInBytes = await file.length();
    final sizeInMB = sizeInBytes / (1024 * 1024);
    if (sizeInMB > maxSizeInMB) {
      return 'Dosya boyutu $maxSizeInMB MB\'dan büyük olamaz';
    }

    // Resim dosyası kontrolleri
    if (isImage) {
      try {
        final bytes = await file.readAsBytes();
        final image = img.decodeImage(bytes);
        if (image == null) {
          return 'Geçersiz resim dosyası';
        }

        // Resim boyutu kontrolü
        if (image.width > ValidationConfig.maxImageWidth ||
            image.height > ValidationConfig.maxImageHeight) {
          return 'Resim boyutları çok büyük (Maks: ${ValidationConfig.maxImageWidth}x${ValidationConfig.maxImageHeight})';
        }
      } catch (e) {
        return 'Resim dosyası okunamadı: $e';
      }
    }

    return null;
  }

  // Metin sanitizasyonu
  String sanitizeText(String text, {bool allowHtml = false}) {
    var sanitized = text.trim();

    if (!allowHtml) {
      // HTML etiketlerini temizle
      sanitized = sanitized.replaceAll(RegExp(r'<[^>]*>'), '');
    }

    // HTML karakterlerini decode et
    sanitized = _unescapeHtml(sanitized);

    // Tehlikeli karakterleri escape et
    sanitized = sanitized
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');

    return sanitized;
  }

  // Resim sıkıştırma
  Future<File> compressImage(
    File file, {
    int maxWidth = ValidationConfig.maxImageWidth,
    int maxHeight = ValidationConfig.maxImageHeight,
    int quality = 85,
  }) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw ValidationError('Resim dosyası okunamadı');
    }

    // Resim boyutlarını kontrol et ve gerekirse yeniden boyutlandır
    var processedImage = image;
    if (image.width > maxWidth || image.height > maxHeight) {
      processedImage = img.copyResize(
        image,
        width: image.width > maxWidth ? maxWidth : image.width,
        height: image.height > maxHeight ? maxHeight : image.height,
      );
    }

    // Resmi sıkıştır
    final compressedBytes = img.encodeJpg(processedImage, quality: quality);

    // Geçici dosya oluştur
    final tempDir = await Directory.systemTemp.createTemp();
    final tempFile = File(
      '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    // Sıkıştırılmış veriyi yaz
    await tempFile.writeAsBytes(compressedBytes);

    return tempFile;
  }

  // Kategori seçimi validasyonu
  String? validateCategories(
    List<String> categories, {
    int minCategories = 1,
    int maxCategories = 5,
  }) {
    if (categories.isEmpty || categories.length < minCategories) {
      return 'En az $minCategories kategori seçmelisiniz';
    }

    if (categories.length > maxCategories) {
      return 'En fazla $maxCategories kategori seçebilirsiniz';
    }

    return null;
  }

  // Topluluk adı benzersizlik kontrolü
  Future<String?> validateCommunityNameUniqueness(String name) async {
    try {
      // Firestore'da aynı isimde topluluk var mı kontrol et
      final querySnapshot = await Get.find<FirebaseFirestore>()
          .collection('communities')
          .where('name', isEqualTo: name)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return 'Bu isimde bir topluluk zaten var';
      }

      return null;
    } catch (e) {
      return 'Topluluk adı kontrolü yapılamadı: $e';
    }
  }
}
