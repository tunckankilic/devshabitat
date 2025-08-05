import 'package:cloud_firestore/cloud_firestore.dart';

class BlogModel {
  final String id;
  final String title;
  final String content;
  final String summary;
  final String description;
  final String publishDate;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final List<String> tags;
  final String? thumbnailUrl;
  final bool isPublished;
  final String authorId;
  final String authorName;
  final String? authorEmail;
  final String? authorPhotoUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? publishedAt;
  final String status;
  final String estimatedReadingTime;
  final List<dynamic> codeSnippets;
  final String category;

  BlogModel({
    required this.id,
    required this.title,
    required this.content,
    required this.summary,
    required this.description,
    required this.publishDate,
    required this.viewCount,
    this.likeCount = 0,
    this.commentCount = 0,
    required this.tags,
    this.thumbnailUrl,
    required this.isPublished,
    required this.authorId,
    required this.authorName,
    this.authorEmail,
    this.authorPhotoUrl,
    required this.createdAt,
    this.updatedAt,
    this.publishedAt,
    required this.status,
    required this.estimatedReadingTime,
    this.codeSnippets = const [],
    required this.category,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'summary': summary,
    'description': description,
    'publishDate': publishDate,
    'viewCount': viewCount,
    'likeCount': likeCount,
    'commentCount': commentCount,
    'tags': tags,
    'thumbnailUrl': thumbnailUrl,
    'isPublished': isPublished,
    'authorId': authorId,
    'authorName': authorName,
    'authorEmail': authorEmail,
    'authorPhotoUrl': authorPhotoUrl,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'publishedAt': publishedAt?.toIso8601String(),
    'status': status,
    'estimatedReadingTime': estimatedReadingTime,
    'codeSnippets': codeSnippets,
    'category': category,
  };

  factory BlogModel.fromMap(Map<String, dynamic> map) => BlogModel(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    content: map['content'] ?? '',
    summary: map['summary'] ?? '',
    description: map['description'] ?? '',
    publishDate: map['publishDate'] ?? '',
    viewCount: map['viewCount'] ?? 0,
    likeCount: map['likeCount'] ?? 0,
    commentCount: map['commentCount'] ?? 0,
    tags: List<String>.from(map['tags'] ?? []),
    thumbnailUrl: map['thumbnailUrl'],
    isPublished: map['isPublished'] ?? false,
    authorId: map['authorId'] ?? '',
    authorName: map['authorName'] ?? '',
    authorEmail: map['authorEmail'],
    authorPhotoUrl: map['authorPhotoUrl'],
    createdAt: DateTime.parse(map['createdAt']),
    updatedAt: map['updatedAt'] != null
        ? DateTime.parse(map['updatedAt'])
        : null,
    publishedAt: map['publishedAt'] != null
        ? DateTime.parse(map['publishedAt'])
        : null,
    status: map['status'] ?? 'draft',
    estimatedReadingTime: map['estimatedReadingTime'] ?? '',
    codeSnippets: map['codeSnippets'] ?? [],
    category: map['category'] ?? 'Genel',
  );

  factory BlogModel.fromDocument(DocumentSnapshot doc) =>
      BlogModel.fromMap({'id': doc.id, ...doc.data() as Map<String, dynamic>});

  BlogModel copyWith({
    String? id,
    String? title,
    String? content,
    String? summary,
    String? description,
    String? publishDate,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    List<String>? tags,
    String? thumbnailUrl,
    bool? isPublished,
    String? authorId,
    String? authorName,
    String? authorEmail,
    String? authorPhotoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
    String? status,
    String? estimatedReadingTime,
    List<dynamic>? codeSnippets,
    String? category,
  }) => BlogModel(
    id: id ?? this.id,
    title: title ?? this.title,
    content: content ?? this.content,
    summary: summary ?? this.summary,
    description: description ?? this.description,
    publishDate: publishDate ?? this.publishDate,
    viewCount: viewCount ?? this.viewCount,
    likeCount: likeCount ?? this.likeCount,
    commentCount: commentCount ?? this.commentCount,
    tags: tags ?? this.tags,
    thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    isPublished: isPublished ?? this.isPublished,
    authorId: authorId ?? this.authorId,
    authorName: authorName ?? this.authorName,
    authorEmail: authorEmail ?? this.authorEmail,
    authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    publishedAt: publishedAt ?? this.publishedAt,
    status: status ?? this.status,
    estimatedReadingTime: estimatedReadingTime ?? this.estimatedReadingTime,
    codeSnippets: codeSnippets ?? this.codeSnippets,
    category: category ?? this.category,
  );

  Map<String, dynamic> toJson() => toMap();
}
