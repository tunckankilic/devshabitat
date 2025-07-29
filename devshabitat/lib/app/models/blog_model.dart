import 'package:cloud_firestore/cloud_firestore.dart';
import 'code_snippet_model.dart';

class BlogModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> tags;
  final String content;
  final String authorId;
  final String authorName;
  final String authorEmail;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;
  final String status; // 'draft', 'published'
  final bool isPublished;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final List<CodeSnippetModel> codeSnippets;

  BlogModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.tags,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorEmail,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
    required this.status,
    required this.isPublished,
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.codeSnippets = const [],
  });

  // Create BlogModel from Firestore document
  factory BlogModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return BlogModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'Genel',
      tags: List<String>.from(data['tags'] ?? []),
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorEmail: data['authorEmail'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      publishedAt: (data['publishedAt'] as Timestamp?)?.toDate(),
      status: data['status'] ?? 'draft',
      isPublished: data['isPublished'] ?? false,
      viewCount: data['viewCount'] ?? 0,
      likeCount: data['likeCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      codeSnippets: (data['codeSnippets'] as List<dynamic>?)
              ?.map((snippetData) => CodeSnippetModel.fromJson(snippetData))
              .toList() ??
          [],
    );
  }

  // Create BlogModel from Map
  factory BlogModel.fromMap(Map<String, dynamic> data) {
    return BlogModel(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'Genel',
      tags: List<String>.from(data['tags'] ?? []),
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorEmail: data['authorEmail'] ?? '',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      publishedAt: data['publishedAt'] is Timestamp
          ? (data['publishedAt'] as Timestamp).toDate()
          : null,
      status: data['status'] ?? 'draft',
      isPublished: data['isPublished'] ?? false,
      viewCount: data['viewCount'] ?? 0,
      likeCount: data['likeCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      codeSnippets: (data['codeSnippets'] as List<dynamic>?)
              ?.map((snippetData) => CodeSnippetModel.fromJson(snippetData))
              .toList() ??
          [],
    );
  }

  // Convert BlogModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'tags': tags,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorEmail': authorEmail,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'publishedAt':
          publishedAt != null ? Timestamp.fromDate(publishedAt!) : null,
      'status': status,
      'isPublished': isPublished,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'codeSnippets': codeSnippets.map((snippet) => snippet.toJson()).toList(),
    };
  }

  // Convert BlogModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'tags': tags,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorEmail': authorEmail,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'publishedAt': publishedAt?.toIso8601String(),
      'status': status,
      'isPublished': isPublished,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'codeSnippets': codeSnippets.map((snippet) => snippet.toJson()).toList(),
    };
  }

  // Copy with method for updating blog data
  BlogModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    List<String>? tags,
    String? content,
    String? authorId,
    String? authorName,
    String? authorEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
    String? status,
    bool? isPublished,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    List<CodeSnippetModel>? codeSnippets,
  }) {
    return BlogModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorEmail: authorEmail ?? this.authorEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
      status: status ?? this.status,
      isPublished: isPublished ?? this.isPublished,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      codeSnippets: codeSnippets ?? this.codeSnippets,
    );
  }

  // Get estimated reading time
  String get estimatedReadingTime {
    final words = content.trim().split(RegExp(r'\s+')).length;
    final minutes =
        (words / 200).ceil(); // Average reading speed: 200 words/minute
    return minutes <= 1 ? '1 dk okuma' : '$minutes dk okuma';
  }

  // Get word count
  int get wordCount {
    if (content.trim().isEmpty) return 0;
    return content.trim().split(RegExp(r'\s+')).length;
  }

  @override
  String toString() {
    return 'BlogModel(id: $id, title: $title, status: $status, codeSnippets: ${codeSnippets.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BlogModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
