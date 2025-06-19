import '../models/attachment_model.dart';

class ThreadReply {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final List<MessageAttachment> attachments;

  const ThreadReply({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.attachments = const [],
  });

  ThreadReply copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? content,
    DateTime? createdAt,
    List<MessageAttachment>? attachments,
  }) {
    return ThreadReply(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      attachments: attachments ?? this.attachments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'attachments': attachments.map((a) => a.toJson()).toList(),
    };
  }

  factory ThreadReply.fromJson(Map<String, dynamic> json) {
    return ThreadReply(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      attachments: (json['attachments'] as List)
          .map((a) => MessageAttachment.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ThreadModel {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final List<MessageAttachment> attachments;
  final List<ThreadReply> replies;
  final bool isRead;

  const ThreadModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    required this.attachments,
    required this.replies,
    this.isRead = false,
  });

  ThreadModel copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? content,
    DateTime? createdAt,
    List<MessageAttachment>? attachments,
    List<ThreadReply>? replies,
    bool? isRead,
  }) {
    return ThreadModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      attachments: attachments ?? this.attachments,
      replies: replies ?? this.replies,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'replies': replies.map((r) => r.toJson()).toList(),
      'isRead': isRead,
    };
  }

  factory ThreadModel.fromJson(Map<String, dynamic> json) {
    return ThreadModel(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      attachments: (json['attachments'] as List)
          .map((a) => MessageAttachment.fromJson(a as Map<String, dynamic>))
          .toList(),
      replies: (json['replies'] as List)
          .map((r) => ThreadReply.fromJson(r as Map<String, dynamic>))
          .toList(),
      isRead: json['isRead'] as bool,
    );
  }
}
