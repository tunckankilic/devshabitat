import 'package:cloud_firestore/cloud_firestore.dart';

class CodeSnippetModel {
  final String id;
  final String title;
  final String code;
  final String language;
  final String description;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final List<dynamic> comments;
  final List<dynamic> solutions;
  final Map<String, dynamic>? metadata;

  CodeSnippetModel({
    required this.id,
    required this.title,
    required this.code,
    required this.language,
    required this.description,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.comments = const [],
    this.solutions = const [],
    this.metadata,
  });

  factory CodeSnippetModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CodeSnippetModel(
      id: doc.id,
      title: data['title'] ?? '',
      code: data['code'] ?? '',
      language: data['language'] ?? '',
      description: data['description'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      comments: data['comments'] ?? [],
      solutions: data['solutions'] ?? [],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'code': code,
      'language': language,
      'description': description,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': Timestamp.fromDate(createdAt),
      'comments': comments,
      'solutions': solutions,
      'metadata': metadata,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'code': code,
      'language': language,
      'description': description,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt.toIso8601String(),
      'comments': comments,
      'solutions': solutions,
      'metadata': metadata,
    };
  }

  factory CodeSnippetModel.fromJson(Map<String, dynamic> json) {
    return CodeSnippetModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      code: json['code'] ?? '',
      language: json['language'] ?? '',
      description: json['description'] ?? '',
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      comments: json['comments'] ?? [],
      solutions: json['solutions'] ?? [],
      metadata: json['metadata'],
    );
  }

  CodeSnippetModel copyWith({
    String? id,
    String? title,
    String? code,
    String? language,
    String? description,
    String? authorId,
    String? authorName,
    DateTime? createdAt,
    List<dynamic>? comments,
    List<dynamic>? solutions,
    Map<String, dynamic>? metadata,
  }) {
    return CodeSnippetModel(
      id: id ?? this.id,
      title: title ?? this.title,
      code: code ?? this.code,
      language: language ?? this.language,
      description: description ?? this.description,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      comments: comments ?? this.comments,
      solutions: solutions ?? this.solutions,
      metadata: metadata ?? this.metadata,
    );
  }
}
