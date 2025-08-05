import 'package:cloud_firestore/cloud_firestore.dart';

enum ContentType { blogPost, githubProject, event, resource, achievement }

enum ContentStatus { pending, approved, rejected }

class CommunityContentModel {
  final String id;
  final String communityId;
  final String authorId;
  final String title;
  final String content;
  final ContentType type;
  final String? url;
  final String? githubRepo;
  final DateTime createdAt;
  final ContentStatus status;
  final List<String> likedBy;
  final int reportCount;
  final String? rejectionReason;
  final DateTime? moderatedAt;

  CommunityContentModel({
    required this.id,
    required this.communityId,
    required this.authorId,
    required this.title,
    required this.content,
    required this.type,
    this.url,
    this.githubRepo,
    required this.createdAt,
    required this.status,
    this.likedBy = const [],
    this.reportCount = 0,
    this.rejectionReason,
    this.moderatedAt,
  });

  factory CommunityContentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityContentModel(
      id: doc.id,
      communityId: data['communityId'] as String,
      authorId: data['authorId'] as String,
      title: data['title'] as String,
      content: data['content'] as String,
      type: ContentType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ContentType.blogPost,
      ),
      url: data['url'] as String?,
      githubRepo: data['githubRepo'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: ContentStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ContentStatus.pending,
      ),
      likedBy: List<String>.from(data['likedBy'] ?? []),
      reportCount: data['reportCount'] as int? ?? 0,
      rejectionReason: data['rejectionReason'] as String?,
      moderatedAt: data['moderatedAt'] != null
          ? (data['moderatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'communityId': communityId,
      'authorId': authorId,
      'title': title,
      'content': content,
      'type': type.name,
      'url': url,
      'githubRepo': githubRepo,
      'createdAt': createdAt,
      'status': status.name,
      'likedBy': likedBy,
      'reportCount': reportCount,
      'rejectionReason': rejectionReason,
      'moderatedAt': moderatedAt,
    };
  }

  CommunityContentModel copyWith({
    String? id,
    String? communityId,
    String? authorId,
    String? title,
    String? content,
    ContentType? type,
    String? url,
    String? githubRepo,
    DateTime? createdAt,
    ContentStatus? status,
    List<String>? likedBy,
    int? reportCount,
    String? rejectionReason,
    DateTime? moderatedAt,
  }) {
    return CommunityContentModel(
      id: id ?? this.id,
      communityId: communityId ?? this.communityId,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      url: url ?? this.url,
      githubRepo: githubRepo ?? this.githubRepo,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      likedBy: likedBy ?? this.likedBy,
      reportCount: reportCount ?? this.reportCount,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      moderatedAt: moderatedAt ?? this.moderatedAt,
    );
  }
}
