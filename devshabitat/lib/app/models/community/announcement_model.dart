import 'package:cloud_firestore/cloud_firestore.dart';

enum AnnouncementCategory {
  general, // Genel duyurular
  urgent, // Acil duyurular
  event, // Etkinlik duyuruları
  update, // Güncelleme duyuruları
  news, // Haberler
}

class AnnouncementModel {
  final String id;
  final String communityId;
  final String title;
  final String content;
  final String createdBy;
  final DateTime createdAt;
  final AnnouncementCategory category;
  final bool isActive;

  AnnouncementModel({
    required this.id,
    required this.communityId,
    required this.title,
    required this.content,
    required this.createdBy,
    required this.createdAt,
    required this.category,
    this.isActive = true,
  });

  factory AnnouncementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnnouncementModel(
      id: doc.id,
      communityId: data['communityId'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      category: AnnouncementCategory.values.firstWhere(
        (e) => e.toString() == 'AnnouncementCategory.${data['category']}',
        orElse: () => AnnouncementCategory.general,
      ),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'communityId': communityId,
      'title': title,
      'content': content,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'category': category.toString().split('.').last,
      'isActive': isActive,
    };
  }
}
