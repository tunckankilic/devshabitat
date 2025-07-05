class CodeSnippetModel {
  final String id;
  final String code;
  final String language;
  final String title;
  final String? description;
  final String authorId;
  final DateTime createdAt;
  final List<CodeComment> comments;
  final List<CodeSolution> solutions;

  CodeSnippetModel({
    required this.id,
    required this.code,
    required this.language,
    required this.title,
    this.description,
    required this.authorId,
    required this.createdAt,
    this.comments = const [],
    this.solutions = const [],
  });

  factory CodeSnippetModel.fromJson(Map<String, dynamic> json) {
    return CodeSnippetModel(
      id: json['id'] as String,
      code: json['code'] as String,
      language: json['language'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      authorId: json['authorId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      comments: (json['comments'] as List?)
              ?.map((e) => CodeComment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      solutions: (json['solutions'] as List?)
              ?.map((e) => CodeSolution.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'language': language,
      'title': title,
      'description': description,
      'authorId': authorId,
      'createdAt': createdAt.toIso8601String(),
      'comments': comments.map((e) => e.toJson()).toList(),
      'solutions': solutions.map((e) => e.toJson()).toList(),
    };
  }
}

class CodeComment {
  final String id;
  final String comment;
  final String authorId;
  final String? lineNumber;
  final DateTime createdAt;

  CodeComment({
    required this.id,
    required this.comment,
    required this.authorId,
    this.lineNumber,
    required this.createdAt,
  });

  factory CodeComment.fromJson(Map<String, dynamic> json) {
    return CodeComment(
      id: json['id'] as String,
      comment: json['comment'] as String,
      authorId: json['authorId'] as String,
      lineNumber: json['lineNumber'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'comment': comment,
      'authorId': authorId,
      'lineNumber': lineNumber,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class CodeSolution {
  final String id;
  final String code;
  final String explanation;
  final String authorId;
  final DateTime createdAt;
  final int votes;

  CodeSolution({
    required this.id,
    required this.code,
    required this.explanation,
    required this.authorId,
    required this.createdAt,
    this.votes = 0,
  });

  factory CodeSolution.fromJson(Map<String, dynamic> json) {
    return CodeSolution(
      id: json['id'] as String,
      code: json['code'] as String,
      explanation: json['explanation'] as String,
      authorId: json['authorId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      votes: json['votes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'explanation': explanation,
      'authorId': authorId,
      'createdAt': createdAt.toIso8601String(),
      'votes': votes,
    };
  }
}
