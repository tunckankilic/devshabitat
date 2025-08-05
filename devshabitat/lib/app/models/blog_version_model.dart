import 'package:cloud_firestore/cloud_firestore.dart';

class BlogVersionModel {
  final String id;
  final String blogId;
  final String content;
  final String editorId;
  final String editorName;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  BlogVersionModel({
    required this.id,
    required this.blogId,
    required this.content,
    required this.editorId,
    required this.editorName,
    required this.createdAt,
    this.metadata,
  });

  factory BlogVersionModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BlogVersionModel(
      id: doc.id,
      blogId: data['blogId'] ?? '',
      content: data['content'] ?? '',
      editorId: data['editorId'] ?? '',
      editorName: data['editorName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'blogId': blogId,
      'content': content,
      'editorId': editorId,
      'editorName': editorName,
      'createdAt': Timestamp.fromDate(createdAt),
      'metadata': metadata,
    };
  }
}
