import 'package:cloud_firestore/cloud_firestore.dart';

class FeedItem {
  final String id;
  final String userId;
  final String content;
  final String? imageUrl;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final DateTime createdAt;
  final bool isLiked;

  FeedItem({
    required this.id,
    required this.userId,
    required this.content,
    this.imageUrl,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.createdAt,
    required this.isLiked,
  });

  factory FeedItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeedItem(
      id: doc.id,
      userId: data['userId'] as String,
      content: data['content'] as String,
      imageUrl: data['imageUrl'] as String?,
      likesCount: data['likesCount'] as int,
      commentsCount: data['commentsCount'] as int,
      sharesCount: data['sharesCount'] as int,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isLiked: data['isLiked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'content': content,
      'imageUrl': imageUrl,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'isLiked': isLiked,
    };
  }

  FeedItem copyWith({
    String? id,
    String? userId,
    String? content,
    String? imageUrl,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    DateTime? createdAt,
    bool? isLiked,
  }) {
    return FeedItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      createdAt: createdAt ?? this.createdAt,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
