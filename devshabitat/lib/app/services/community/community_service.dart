import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devshabitat/app/models/community/community_model.dart';
import 'package:devshabitat/app/models/community/community_settings_model.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'communities';

  // Topluluk kategorileri
  final List<String> _categories = [
    'Yazılım Geliştirme',
    'Mobil Uygulama',
    'Web Geliştirme',
    'Veri Bilimi',
    'Yapay Zeka',
    'Siber Güvenlik',
    'DevOps',
    'UI/UX Tasarım',
    'Oyun Geliştirme',
    'Blockchain',
  ];

  List<String> getCategories() => _categories;

  // Topluluk oluşturma
  Future<CommunityModel> createCommunity(CommunityModel community) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            community.toFirestore(),
          );

      // Create default settings
      final settings = CommunitySettingsModel(communityId: docRef.id);
      await _firestore
          .collection(_collection)
          .doc(docRef.id)
          .collection('settings')
          .doc('default')
          .set(settings.toJson());

      return community.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Topluluk oluşturulurken bir hata oluştu: $e');
    }
  }

  // Topluluk güncelleme
  Future<void> updateCommunity(CommunityModel community) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(community.id)
          .update(community.toFirestore());
    } catch (e) {
      throw Exception('Topluluk güncellenirken bir hata oluştu: $e');
    }
  }

  // Topluluk silme
  Future<void> deleteCommunity(String communityId) async {
    try {
      await _firestore.collection(_collection).doc(communityId).delete();
    } catch (e) {
      throw Exception('Topluluk silinirken bir hata oluştu: $e');
    }
  }

  // Topluluk detayı getirme
  Future<CommunityModel> getCommunity(String communityId) async {
    try {
      final doc =
          await _firestore.collection(_collection).doc(communityId).get();
      if (!doc.exists) {
        throw Exception('Topluluk bulunamadı');
      }
      return CommunityModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Topluluk bilgileri alınırken bir hata oluştu: $e');
    }
  }

  // Topluluk keşfi
  Future<List<CommunityModel>> discoverCommunities({
    String? query,
    List<String>? categories,
    String? sortBy,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query communityQuery = _firestore.collection(_collection);

      // Arama filtresi
      if (query != null && query.isNotEmpty) {
        communityQuery = communityQuery.where(
          'searchKeywords',
          arrayContains: query.toLowerCase(),
        );
      }

      // Kategori filtresi
      if (categories != null && categories.isNotEmpty) {
        communityQuery = communityQuery.where(
          'categories',
          arrayContainsAny: categories,
        );
      }

      // Sıralama
      switch (sortBy) {
        case 'popular':
          communityQuery =
              communityQuery.orderBy('memberCount', descending: true);
          break;
        case 'active':
          communityQuery =
              communityQuery.orderBy('lastActivityAt', descending: true);
          break;
        case 'newest':
        default:
          communityQuery =
              communityQuery.orderBy('createdAt', descending: true);
      }

      // Sayfalama
      if (startAfter != null) {
        communityQuery = communityQuery.startAfterDocument(startAfter);
      }
      communityQuery = communityQuery.limit(limit);

      final querySnapshot = await communityQuery.get();
      return querySnapshot.docs
          .map((doc) => CommunityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Topluluklar listelenirken bir hata oluştu: $e');
    }
  }

  // Kullanıcının toplulukları
  Future<List<CommunityModel>> getUserCommunities(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('memberIds', arrayContains: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => CommunityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception(
          'Kullanıcının toplulukları alınırken bir hata oluştu: $e');
    }
  }

  // Kullanıcının yönettiği topluluklar
  Future<List<CommunityModel>> getManagedCommunities(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('moderatorIds', arrayContains: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => CommunityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Yönetilen topluluklar alınırken bir hata oluştu: $e');
    }
  }

  // Topluluk istatistiklerini güncelleme
  Future<void> updateCommunityStats(
    String communityId, {
    int? memberCountDelta,
    int? eventCountDelta,
    int? postCountDelta,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (memberCountDelta != null) {
        updates['memberCount'] = FieldValue.increment(memberCountDelta);
      }
      if (eventCountDelta != null) {
        updates['eventCount'] = FieldValue.increment(eventCountDelta);
      }
      if (postCountDelta != null) {
        updates['postCount'] = FieldValue.increment(postCountDelta);
      }

      if (updates.isNotEmpty) {
        await _firestore
            .collection(_collection)
            .doc(communityId)
            .update(updates);
      }
    } catch (e) {
      throw Exception(
          'Topluluk istatistikleri güncellenirken bir hata oluştu: $e');
    }
  }

  // Get all communities (with pagination)
  Future<List<CommunityModel>> getCommunities({
    int limit = 20,
    DocumentSnapshot? startAfter,
    CommunityType? type,
    CommunityCategory? category,
  }) async {
    Query query = _firestore.collection(_collection);

    if (type != null) {
      query = query.where('type', isEqualTo: type.toString());
    }

    if (category != null) {
      query = query.where('category', isEqualTo: category.toString());
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.limit(limit).get();
    return snapshot.docs
        .map((doc) => CommunityModel.fromFirestore(doc))
        .toList();
  }

  // Search communities by name
  Future<List<CommunityModel>> searchCommunities(String searchTerm) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('name', isGreaterThanOrEqualTo: searchTerm)
        .where('name', isLessThanOrEqualTo: searchTerm + '\uf8ff')
        .get();

    return snapshot.docs
        .map((doc) => CommunityModel.fromFirestore(doc))
        .toList();
  }

  // Get community settings
  Future<CommunitySettingsModel> getCommunitySettings(
      String communityId) async {
    final doc = await _firestore
        .collection(_collection)
        .doc(communityId)
        .collection('settings')
        .doc('default')
        .get();

    return CommunitySettingsModel.fromFirestore(doc);
  }

  // Update community settings
  Future<void> updateCommunitySettings(CommunitySettingsModel settings) async {
    await _firestore
        .collection(_collection)
        .doc(settings.communityId)
        .collection('settings')
        .doc('default')
        .update(settings.toJson());
  }

  // Get trending communities
  Future<List<CommunityModel>> getTrendingCommunities({int limit = 10}) async {
    final snapshot = await _firestore
        .collection(_collection)
        .orderBy('memberCount', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => CommunityModel.fromFirestore(doc))
        .toList();
  }
}
