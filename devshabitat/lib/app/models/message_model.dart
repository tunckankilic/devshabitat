import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

/// Mesaj türlerini tanımlayan enum
enum MessageType {
  text,
  image,
  document,
  link,
}

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
  final String type;
  final List<String>? attachments;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.type = 'text',
    this.attachments,
  });

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
      id: map['id'] as String,
      conversationId: map['conversationId'] as String,
      senderId: map['senderId'] as String,
      senderName: map['senderName'] as String,
      content: map['content'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] as bool? ?? false,
      type: map['type'] as String? ?? 'text',
      attachments: (map['attachments'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'type': type,
      'attachments': attachments,
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
    String? type,
    List<String>? attachments,
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
    );
  }
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
      url: json['url'] as String,
      name: json['name'] as String,
      size: json['size'] as String,
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

class Message {
  final String id;
  final String conversationId;
  final String content;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
  final MessageType type;
  final List<MessageAttachment> attachments;

  Message({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    required this.type,
    required this.attachments,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      conversationId: data['conversationId'] as String,
      content: data['content'] as String,
      senderId: data['senderId'] as String,
      senderName: data['senderName'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      type: MessageType.values.firstWhere(
        (t) => t.toString() == 'MessageType.${data['type']}',
        orElse: () => MessageType.text,
      ),
      attachments: (data['attachments'] as List<dynamic>)
          .map((e) => MessageAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      content: json['content'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.parse(json['timestamp'] as String),
      type: MessageType.values.firstWhere(
        (t) => t.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map(
                  (e) => MessageAttachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'content': content,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'attachments': attachments.map((e) => e.toJson()).toList(),
    };
  }
}
