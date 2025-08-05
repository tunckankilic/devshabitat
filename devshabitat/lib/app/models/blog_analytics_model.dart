import 'package:cloud_firestore/cloud_firestore.dart';

class BlogAnalyticsModel {
  final String blogId;
  final int viewCount;
  final int uniqueViewCount;
  final int likeCount;
  final int shareCount;
  final int commentCount;
  final double averageReadTime;
  final Map<String, int> viewsByCountry;
  final Map<String, int> viewsByDevice;
  final Map<String, int> viewsByReferrer;
  final DateTime lastUpdated;

  BlogAnalyticsModel({
    required this.blogId,
    this.viewCount = 0,
    this.uniqueViewCount = 0,
    this.likeCount = 0,
    this.shareCount = 0,
    this.commentCount = 0,
    this.averageReadTime = 0,
    required this.viewsByCountry,
    required this.viewsByDevice,
    required this.viewsByReferrer,
    required this.lastUpdated,
  });

  factory BlogAnalyticsModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BlogAnalyticsModel(
      blogId: doc.id,
      viewCount: data['viewCount'] ?? 0,
      uniqueViewCount: data['uniqueViewCount'] ?? 0,
      likeCount: data['likeCount'] ?? 0,
      shareCount: data['shareCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      averageReadTime: (data['averageReadTime'] ?? 0).toDouble(),
      viewsByCountry: Map<String, int>.from(data['viewsByCountry'] ?? {}),
      viewsByDevice: Map<String, int>.from(data['viewsByDevice'] ?? {}),
      viewsByReferrer: Map<String, int>.from(data['viewsByReferrer'] ?? {}),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'viewCount': viewCount,
      'uniqueViewCount': uniqueViewCount,
      'likeCount': likeCount,
      'shareCount': shareCount,
      'commentCount': commentCount,
      'averageReadTime': averageReadTime,
      'viewsByCountry': viewsByCountry,
      'viewsByDevice': viewsByDevice,
      'viewsByReferrer': viewsByReferrer,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}
