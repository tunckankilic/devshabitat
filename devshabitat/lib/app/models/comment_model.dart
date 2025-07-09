import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String feedItemId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String comment;
  final DateTime createdAt;
  final int likesCount;
  final bool isLiked;

  CommentModel({
    required this.id,
    required this.feedItemId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.comment,
    required this.createdAt,
    this.likesCount = 0,
    this.isLiked = false,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return CommentModel(
      id: id ?? map['id'] ?? '',
      feedItemId: map['feedItemId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Kullanıcı',
      userPhotoUrl: map['userPhotoUrl'],
      comment: map['comment'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likesCount: map['likesCount'] ?? 0,
      isLiked: map['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'feedItemId': feedItemId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'likesCount': likesCount,
      'isLiked': isLiked,
    };
  }

  CommentModel copyWith({
    String? id,
    String? feedItemId,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    String? comment,
    DateTime? createdAt,
    int? likesCount,
    bool? isLiked,
  }) {
    return CommentModel(
      id: id ?? this.id,
      feedItemId: feedItemId ?? this.feedItemId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
