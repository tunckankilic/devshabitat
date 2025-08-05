import 'dart:io';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:html/parser.dart' as htmlparser;
import 'package:markdown/markdown.dart' as md;

class BlogEditorService extends GetxService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Markdown'dan HTML'e dönüştürme
  String markdownToHtml(String markdown) {
    return md.markdownToHtml(markdown, extensionSet: md.ExtensionSet.gitHubWeb);
  }

  // HTML'den düz metin çıkarma (SEO için)
  String extractPlainText(String html) {
    final document = htmlparser.parse(html);
    return document.body?.text ?? '';
  }

  // Meta açıklaması oluşturma
  String generateMetaDescription(String content, {int maxLength = 160}) {
    final plainText = extractPlainText(content);
    if (plainText.length <= maxLength) return plainText;
    return '${plainText.substring(0, maxLength - 3)}...';
  }

  // Resim optimizasyonu ve yükleme
  Future<String> uploadOptimizedImage(File imageFile, String blogId) async {
    // Resmi yüklemeden önce optimize et
    final optimizedImage = await _optimizeImage(imageFile);

    // Optimize edilmiş resmi geçici bir dosyaya kaydet
    final tempPath = path.join(
      path.dirname(imageFile.path),
      'optimized_${path.basename(imageFile.path)}',
    );
    await File(tempPath).writeAsBytes(optimizedImage);

    // Firebase Storage'a yükle
    final ref = _storage.ref('blog_images/$blogId/${path.basename(tempPath)}');
    await ref.putFile(File(tempPath));

    // Geçici dosyayı sil
    await File(tempPath).delete();

    // Yüklenen resmin URL'ini döndür
    return await ref.getDownloadURL();
  }

  // Resim optimizasyonu
  Future<List<int>> _optimizeImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) throw Exception('Resim okunamadı');

    // Maksimum boyutlar
    const maxWidth = 1200;
    const maxHeight = 1200;

    // Boyut kontrolü ve yeniden boyutlandırma
    var optimized = image;
    if (image.width > maxWidth || image.height > maxHeight) {
      optimized = img.copyResize(
        image,
        width: image.width > maxWidth ? maxWidth : null,
        height: image.height > maxHeight ? maxHeight : null,
      );
    }

    // JPEG olarak kaydet ve sıkıştır
    return img.encodeJpg(optimized, quality: 85);
  }

  // SEO optimizasyonu için öneriler
  Map<String, dynamic> analyzeSEO(String title, String content) {
    final plainText = extractPlainText(content);
    final wordCount = plainText.split(RegExp(r'\s+')).length;
    final sentences = plainText.split(RegExp(r'[.!?]+\s')).length;

    return {
      'readability': {
        'wordCount': wordCount,
        'sentenceCount': sentences,
        'averageWordsPerSentence': wordCount / sentences,
      },
      'suggestions': _generateSEOSuggestions(title, plainText),
    };
  }

  List<String> _generateSEOSuggestions(String title, String content) {
    final suggestions = <String>[];

    if (title.length < 30 || title.length > 60) {
      suggestions.add(
        'Başlık uzunluğu 30-60 karakter arasında olmalıdır (şu an: ${title.length})',
      );
    }

    final wordCount = content.split(RegExp(r'\s+')).length;
    if (wordCount < 300) {
      suggestions.add('İçerik en az 300 kelime olmalıdır (şu an: $wordCount)');
    }

    // Anahtar kelime yoğunluğu kontrolü
    final keywords = _extractKeywords(content);
    for (final keyword in keywords.entries) {
      final density = keyword.value / wordCount * 100;
      if (density > 3) {
        suggestions.add(
          '"${keyword.key}" anahtar kelimesi çok sık kullanılmış (yoğunluk: ${density.toStringAsFixed(1)}%)',
        );
      }
    }

    return suggestions;
  }

  Map<String, int> _extractKeywords(String text) {
    final words = text.toLowerCase().split(RegExp(r'\s+'));
    final stopWords = {'ve', 'veya', 'ile', 'için', 'bu', 'bir', 'da', 'de'};

    final keywordCount = <String, int>{};
    for (final word in words) {
      if (word.length > 3 && !stopWords.contains(word)) {
        keywordCount[word] = (keywordCount[word] ?? 0) + 1;
      }
    }

    return keywordCount;
  }
}
