class CodeComment {
  final String id;
  final String comment;
  final String authorId;
  final DateTime createdAt;
  final int? lineNumber;

  CodeComment({
    required this.id,
    required this.comment,
    required this.authorId,
    required this.createdAt,
    this.lineNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'comment': comment,
      'authorId': authorId,
      'createdAt': createdAt,
      'lineNumber': lineNumber,
    };
  }
}

class CodeSolution {
  final String id;
  final String code;
  final String explanation;
  final String authorId;
  final int votes;
  final DateTime createdAt;

  CodeSolution({
    required this.id,
    required this.code,
    required this.explanation,
    required this.authorId,
    required this.votes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'explanation': explanation,
      'authorId': authorId,
      'votes': votes,
      'createdAt': createdAt,
    };
  }
}
