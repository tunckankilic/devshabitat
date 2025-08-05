import 'package:cloud_firestore/cloud_firestore.dart';

class BlogInteractionModel {
  final String id;
  final String blogId;
  final String userId;
  final String type; // 'like', 'dislike', 'bookmark'
  final DateTime createdAt;

  BlogInteractionModel({
    required this.id,
    required this.blogId,
    required this.userId,
    required this.type,
    required this.createdAt,
  });

  factory BlogInteractionModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BlogInteractionModel(
      id: doc.id,
      blogId: data['blogId'] ?? '',
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'blogId': blogId,
      'userId': userId,
      'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class BlogCommentModel {
  final String id;
  final String blogId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String content;
  final String? parentCommentId;
  final DateTime createdAt;
  final DateTime? editedAt;
  final int likeCount;
  final List<String> replies;
  final bool isEdited;

  BlogCommentModel({
    required this.id,
    required this.blogId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.content,
    this.parentCommentId,
    required this.createdAt,
    this.editedAt,
    this.likeCount = 0,
    this.replies = const [],
    this.isEdited = false,
  });

  factory BlogCommentModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BlogCommentModel(
      id: doc.id,
      blogId: data['blogId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'],
      content: data['content'] ?? '',
      parentCommentId: data['parentCommentId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      editedAt: (data['editedAt'] as Timestamp?)?.toDate(),
      likeCount: data['likeCount'] ?? 0,
      replies: List<String>.from(data['replies'] ?? []),
      isEdited: data['isEdited'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'blogId': blogId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'parentCommentId': parentCommentId,
      'createdAt': Timestamp.fromDate(createdAt),
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'likeCount': likeCount,
      'replies': replies,
      'isEdited': isEdited,
    };
  }
}

class BlogSeriesModel {
  final String id;
  final String title;
  final String description;
  final String authorId;
  final List<String> blogIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFeatured;
  final String coverImageUrl;
  final int readCount;

  BlogSeriesModel({
    required this.id,
    required this.title,
    required this.description,
    required this.authorId,
    required this.blogIds,
    required this.createdAt,
    required this.updatedAt,
    this.isFeatured = false,
    required this.coverImageUrl,
    this.readCount = 0,
  });

  factory BlogSeriesModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BlogSeriesModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      authorId: data['authorId'] ?? '',
      blogIds: List<String>.from(data['blogIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isFeatured: data['isFeatured'] ?? false,
      coverImageUrl: data['coverImageUrl'] ?? '',
      readCount: data['readCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'authorId': authorId,
      'blogIds': blogIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isFeatured': isFeatured,
      'coverImageUrl': coverImageUrl,
      'readCount': readCount,
    };
  }
}

class UserReadingListModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final List<String> blogIds;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserReadingListModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.blogIds,
    this.isPublic = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserReadingListModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserReadingListModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      blogIds: List<String>.from(data['blogIds'] ?? []),
      isPublic: data['isPublic'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'blogIds': blogIds,
      'isPublic': isPublic,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
