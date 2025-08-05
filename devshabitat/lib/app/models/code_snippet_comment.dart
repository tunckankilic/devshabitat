import 'package:cloud_firestore/cloud_firestore.dart';

class CodeSnippetComment {
  final String id;
  final String snippetId;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String content;
  final DateTime createdAt;
  final List<String> likes;
  final List<CodeSnippetComment> replies;
  final String? codeReference; // Referans verilen kod satırları
  final Map<String, dynamic>? metadata;

  CodeSnippetComment({
    required this.id,
    required this.snippetId,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.content,
    required this.createdAt,
    this.likes = const [],
    this.replies = const [],
    this.codeReference,
    this.metadata,
  });

  factory CodeSnippetComment.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CodeSnippetComment(
      id: doc.id,
      snippetId: data['snippetId'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorPhotoUrl: data['authorPhotoUrl'],
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      likes: List<String>.from(data['likes'] ?? []),
      replies:
          (data['replies'] as List<dynamic>?)
              ?.map((reply) => CodeSnippetComment.fromMap(reply))
              .toList() ??
          [],
      codeReference: data['codeReference'],
      metadata: data['metadata'],
    );
  }

  factory CodeSnippetComment.fromMap(Map<String, dynamic> data) {
    return CodeSnippetComment(
      id: data['id'] ?? '',
      snippetId: data['snippetId'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorPhotoUrl: data['authorPhotoUrl'],
      content: data['content'] ?? '',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.parse(data['createdAt']),
      likes: List<String>.from(data['likes'] ?? []),
      replies:
          (data['replies'] as List<dynamic>?)
              ?.map((reply) => CodeSnippetComment.fromMap(reply))
              .toList() ??
          [],
      codeReference: data['codeReference'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'snippetId': snippetId,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
      'replies': replies.map((reply) => reply.toMap()).toList(),
      'codeReference': codeReference,
      'metadata': metadata,
    };
  }
}
