import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../models/message_model.dart';

/// Message Operations Service - Mesaj işlemleri için ortak servis
/// Dosya yükleme, medya işleme, link çıkarma gibi işlemleri yönetir
class MessageOperations {
  static final ImagePicker _imagePicker = ImagePicker();
  static final FilePicker _filePicker = FilePicker.platform;

  /// Resim seçme ve yükleme
  static Future<String?> pickAndUploadImage({
    required ImageSource source,
    required Function(String) onUpload,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        // Upload to server
        final downloadUrl = await onUpload(image.path);
        return downloadUrl;
      }
    } catch (e) {
      print('Image pick error: $e');
    }
    return null;
  }

  /// Dosya seçme ve yükleme
  static Future<String?> pickAndUploadFile({
    required Function(String) onUpload,
    List<String>? allowedExtensions,
  }) async {
    try {
      final result = await _filePicker.pickFiles(
        type: FileType.any,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final filePath = file.path!;

        // Upload to server
        final downloadUrl = await onUpload(filePath);
        return downloadUrl;
      }
    } catch (e) {
      print('File pick error: $e');
    }
    return null;
  }

  /// Metinden link çıkarma
  static List<String> extractLinks(String text) {
    final urlPattern = RegExp(
      r'https?://(?:[-\w.])+(?:[:\d]+)?(?:/(?:[\w/_.])*(?:\?(?:[\w&=%.])*)?(?:#(?:[\w.])*)?)?',
      caseSensitive: false,
    );

    return urlPattern.allMatches(text).map((match) => match.group(0)!).toList();
  }

  /// Mesaj içeriğini analiz etme
  static MessageType analyzeMessageType(
      String content, List<MessageAttachment> attachments) {
    if (attachments.isNotEmpty) {
      final attachment = attachments.first;
      switch (attachment.type) {
        case MessageType.image:
          return MessageType.image;
        case MessageType.video:
          return MessageType.video;
        case MessageType.document:
          return MessageType.document;
        default:
          return MessageType.text;
      }
    }

    final links = extractLinks(content);
    if (links.isNotEmpty) {
      return MessageType.link;
    }

    return MessageType.text;
  }

  /// Mesaj içeriğini formatlama
  static String formatMessageContent(String content) {
    // Trim whitespace
    content = content.trim();

    // Remove extra spaces
    content = content.replaceAll(RegExp(r'\s+'), ' ');

    return content;
  }

  /// Dosya boyutunu formatlama
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Dosya uzantısından message type belirleme
  static MessageType getMessageTypeFromFileName(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return MessageType.image;

      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
      case 'flv':
        return MessageType.video;

      case 'pdf':
      case 'doc':
      case 'docx':
      case 'txt':
      case 'rtf':
        return MessageType.document;

      case 'mp3':
      case 'wav':
      case 'aac':
      case 'ogg':
        return MessageType.audio;

      default:
        return MessageType.text;
    }
  }

  /// Mesaj önizleme oluşturma
  static String createMessagePreview(String content, MessageType type) {
    switch (type) {
      case MessageType.image:
        return content.isNotEmpty ? content : '📷 Image';
      case MessageType.video:
        return content.isNotEmpty ? content : '🎥 Video';
      case MessageType.audio:
        return content.isNotEmpty ? content : '🎵 Audio';
      case MessageType.document:
        return content.isNotEmpty ? content : '📄 Document';
      case MessageType.link:
        return content.isNotEmpty ? content : '🔗 Link';
      default:
        return content;
    }
  }

  /// Mesaj geçerliliğini kontrol etme
  static bool isValidMessage(
      String content, List<MessageAttachment> attachments) {
    // En az bir içerik olmalı
    if (content.trim().isEmpty && attachments.isEmpty) {
      return false;
    }

    // İçerik çok uzun olmamalı
    if (content.length > 1000) {
      return false;
    }

    // Çok fazla dosya olmamalı
    if (attachments.length > 5) {
      return false;
    }

    return true;
  }

  /// Mesaj şablonları
  static Map<String, String> getMessageTemplates() {
    return {
      'greeting': 'Merhaba! Nasılsın?',
      'thanks': 'Teşekkürler!',
      'goodbye': 'Görüşürüz!',
      'busy': 'Şu anda meşgulüm, daha sonra dönerim.',
      'meeting': 'Toplantı zamanı geldi.',
      'code_review': 'Kod incelemesi yapalım mı?',
      'collaboration': 'Birlikte çalışalım mı?',
    };
  }

  /// Emoji kategorileri
  static Map<String, List<String>> getEmojiCategories() {
    return {
      'Smileys': ['😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣', '😊', '😇'],
      'Gestures': ['👍', '👎', '👌', '✌️', '🤞', '🤟', '🤘', '👊', '👋', '👏'],
      'Objects': ['💻', '📱', '⌚', '📷', '🎮', '🎵', '📚', '✏️', '📝', '🔧'],
      'Nature': ['🌱', '🌲', '🌳', '🌴', '🌵', '🌾', '🌿', '☘️', '🍀', '🍁'],
      'Food': ['🍎', '🍐', '🍊', '🍋', '🍌', '🍉', '🍇', '🍓', '🍈', '🍒'],
    };
  }
}
