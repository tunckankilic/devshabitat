import 'package:cloud_firestore/cloud_firestore.dart';

class CodeSnippetVersion {
  final String id;
  final String snippetId;
  final String code;
  final String authorId;
  final DateTime createdAt;
  final String description;
  final Map<String, dynamic>? metadata;

  CodeSnippetVersion({
    required this.id,
    required this.snippetId,
    required this.code,
    required this.authorId,
    required this.createdAt,
    required this.description,
    this.metadata,
  });

  factory CodeSnippetVersion.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CodeSnippetVersion(
      id: doc.id,
      snippetId: data['snippetId'] ?? '',
      code: data['code'] ?? '',
      authorId: data['authorId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      description: data['description'] ?? '',
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'snippetId': snippetId,
      'code': code,
      'authorId': authorId,
      'createdAt': Timestamp.fromDate(createdAt),
      'description': description,
      'metadata': metadata,
    };
  }
}
