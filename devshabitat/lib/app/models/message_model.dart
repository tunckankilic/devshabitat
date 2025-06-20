import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

/// Mesaj türlerini tanımlayan enum
enum MessageType { text, image, document, link, audio, video }

/// Mesaj durumlarını tanımlayan enum
enum MessageStatus { sent, delivered, read, failed }

/// Mesaj modeli sınıfı
/// Bu sınıf, uygulama içindeki mesajların yapısını temsil eder
class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final MessageType type;
  final List<MessageAttachment> attachments;
  final String? replyToId;
  final bool isEdited;
  final String? mediaUrl;
  final String? documentUrl;
  final List<String> links;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.type = MessageType.text,
    this.attachments = const [],
    this.replyToId,
    this.isEdited = false,
    this.mediaUrl,
    this.documentUrl,
    this.links = const [],
  });

  bool get hasMedia => mediaUrl != null;
  bool get hasDocument => documentUrl != null;
  bool get hasLinks => links.isNotEmpty;

  /// Mesajı şifrelemek için kullanılan yardımcı metod
  static String _encryptContent(String content, String key) {
    final encrypter =
        encrypt.Encrypter(encrypt.AES(encrypt.Key.fromUtf8(key.padRight(32))));
    final iv = encrypt.IV.fromLength(16);
    return encrypter.encrypt(content, iv: iv).base64;
  }

  /// Mesajı çözmek için kullanılan yardımcı metod
  static String _decryptContent(String encryptedContent, String key) {
    try {
      final encrypter = encrypt.Encrypter(
          encrypt.AES(encrypt.Key.fromUtf8(key.padRight(32))));
      final iv = encrypt.IV.fromLength(16);
      return encrypter.decrypt64(encryptedContent, iv: iv);
    } catch (e) {
      return encryptedContent; // Çözülemezse orijinal içeriği döndür
    }
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      conversationId: map['conversationId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      content: map['content'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == (map['type'] ?? 'text'),
        orElse: () => MessageType.text,
      ),
      attachments: (map['attachments'] as List<dynamic>?)
              ?.map(
                  (e) => MessageAttachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      replyToId: map['replyToId'] as String?,
      isEdited: map['isEdited'] ?? false,
      mediaUrl: map['mediaUrl'],
      documentUrl: map['documentUrl'],
      links: List<String>.from(map['links'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp,
      'isRead': isRead,
      'type': type.toString().split('.').last,
      'attachments': attachments.map((e) => e.toJson()).toList(),
      'replyToId': replyToId,
      'isEdited': isEdited,
      'mediaUrl': mediaUrl,
      'documentUrl': documentUrl,
      'links': links,
    };
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    MessageType? type,
    List<MessageAttachment>? attachments,
    String? replyToId,
    bool? isEdited,
    String? mediaUrl,
    String? documentUrl,
    List<String>? links,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      attachments: attachments ?? this.attachments,
      replyToId: replyToId ?? this.replyToId,
      isEdited: isEdited ?? this.isEdited,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      documentUrl: documentUrl ?? this.documentUrl,
      links: links ?? this.links,
    );
  }

  Map<String, dynamic> toJson() => toMap();
}

enum AttachmentType {
  image,
  video,
  audio,
  file,
}

class AttachmentData {
  final AttachmentType type;
  final String url;
  final String name;
  final int size;

  AttachmentData({
    required this.type,
    required this.url,
    required this.name,
    required this.size,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'url': url,
      'name': name,
      'size': size,
    };
  }

  factory AttachmentData.fromJson(Map<String, dynamic> json) {
    return AttachmentData(
      type: AttachmentType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => AttachmentType.file,
      ),
      url: json['url'] as String,
      name: json['name'] as String,
      size: json['size'] as int,
    );
  }
}

class MessageAttachment {
  final String url;
  final String name;
  final String size;
  final MessageType type;

  MessageAttachment({
    required this.url,
    required this.name,
    required this.size,
    required this.type,
  });

  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      url: json['url'] ?? '',
      name: json['name'] ?? '',
      size: json['size'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'name': name,
      'size': size,
      'type': type.toString().split('.').last,
    };
  }
}
