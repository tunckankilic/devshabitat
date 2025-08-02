import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../models/community/announcement_model.dart';
import '../../controllers/auth_controller.dart';

class AnnouncementService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth = Get.find<AuthController>();

  // Duyuru koleksiyonunu al
  CollectionReference<Map<String, dynamic>> _getAnnouncementsCollection(
    String communityId,
  ) {
    return _firestore
        .collection('communities')
        .doc(communityId)
        .collection('announcements');
  }

  // Duyuru oluştur
  Future<AnnouncementModel> createAnnouncement({
    required String communityId,
    required String title,
    required String content,
    required AnnouncementCategory category,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Kullanıcı girişi yapılmamış');

      final data = {
        'communityId': communityId,
        'title': title,
        'content': content,
        'createdBy': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'category': category.toString().split('.').last,
        'isActive': true,
      };

      final docRef = await _getAnnouncementsCollection(communityId).add(data);
      final doc = await docRef.get();

      return AnnouncementModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Duyuru oluşturulurken bir hata oluştu: $e');
    }
  }

  // Duyuruları getir
  Future<List<AnnouncementModel>> getAnnouncements(
    String communityId, {
    AnnouncementCategory? category,
    bool activeOnly = true,
    int limit = 20,
  }) async {
    try {
      var query = _getAnnouncementsCollection(
        communityId,
      ).orderBy('createdAt', descending: true);

      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }

      if (category != null) {
        query = query.where(
          'category',
          isEqualTo: category.toString().split('.').last,
        );
      }

      if (limit > 0) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => AnnouncementModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Duyurular getirilirken bir hata oluştu: $e');
    }
  }

  // Duyuru güncelle
  Future<void> updateAnnouncement(AnnouncementModel announcement) async {
    try {
      await _getAnnouncementsCollection(
        announcement.communityId,
      ).doc(announcement.id).update(announcement.toFirestore());
    } catch (e) {
      throw Exception('Duyuru güncellenirken bir hata oluştu: $e');
    }
  }

  // Duyuru sil (soft delete)
  Future<void> deleteAnnouncement(
    String communityId,
    String announcementId,
  ) async {
    try {
      await _getAnnouncementsCollection(
        communityId,
      ).doc(announcementId).update({'isActive': false});
    } catch (e) {
      throw Exception('Duyuru silinirken bir hata oluştu: $e');
    }
  }

  // Kategori listesini getir
  List<Map<String, String>> getCategories() {
    return AnnouncementCategory.values.map((category) {
      final name = category.toString().split('.').last;
      String displayName;

      switch (category) {
        case AnnouncementCategory.general:
          displayName = 'Genel';
          break;
        case AnnouncementCategory.urgent:
          displayName = 'Acil';
          break;
        case AnnouncementCategory.event:
          displayName = 'Etkinlik';
          break;
        case AnnouncementCategory.update:
          displayName = 'Güncelleme';
          break;
        case AnnouncementCategory.news:
          displayName = 'Haber';
          break;
      }

      return {'value': name, 'display': displayName};
    }).toList();
  }
}
