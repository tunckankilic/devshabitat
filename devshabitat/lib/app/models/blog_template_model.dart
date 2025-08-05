import 'package:cloud_firestore/cloud_firestore.dart';

class BlogTemplateModel {
  final String id;
  final String name;
  final String description;
  final String content;
  final String category;
  final List<String> tags;
  final String creatorId;
  final DateTime createdAt;
  final bool isPublic;

  BlogTemplateModel({
    required this.id,
    required this.name,
    required this.description,
    required this.content,
    required this.category,
    required this.tags,
    required this.creatorId,
    required this.createdAt,
    this.isPublic = false,
  });

  factory BlogTemplateModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BlogTemplateModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      content: data['content'] ?? '',
      category: data['category'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      creatorId: data['creatorId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isPublic: data['isPublic'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'content': content,
      'category': category,
      'tags': tags,
      'creatorId': creatorId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isPublic': isPublic,
    };
  }
}
