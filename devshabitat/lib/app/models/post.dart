import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String content;
  final List<String> images;
  final List<String> likes;
  final List<String> comments;
  final DateTime createdAt;
  final String? githubRepoUrl;
  final Map<String, dynamic>? metadata;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    this.images = const [],
    this.likes = const [],
    this.comments = const [],
    required this.createdAt,
    this.githubRepoUrl,
    this.metadata,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      images: List<String>.from(json['images'] ?? []),
      likes: List<String>.from(json['likes'] ?? []),
      comments: List<String>.from(json['comments'] ?? []),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      githubRepoUrl: json['githubRepoUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'images': images,
      'likes': likes,
      'comments': comments,
      'createdAt': Timestamp.fromDate(createdAt),
      'githubRepoUrl': githubRepoUrl,
      'metadata': metadata,
    };
  }

  Post copyWith({
    String? id,
    String? userId,
    String? content,
    List<String>? images,
    List<String>? likes,
    List<String>? comments,
    DateTime? createdAt,
    String? githubRepoUrl,
    Map<String, dynamic>? metadata,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      images: images ?? this.images,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      githubRepoUrl: githubRepoUrl ?? this.githubRepoUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}
