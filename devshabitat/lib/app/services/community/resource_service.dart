import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../models/community/resource_model.dart';
import '../../models/community/role_model.dart';
import '../../services/community/role_service.dart';

class ResourceService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RoleService _roleService = Get.find<RoleService>();

  // Kaynak koleksiyonunu al
  CollectionReference<Map<String, dynamic>> _getResourcesCollection(
      String communityId) {
    return _firestore
        .collection('communities')
        .doc(communityId)
        .collection('resources');
  }

  // Yeni kaynak oluştur
  Future<ResourceModel> createResource(ResourceModel resource) async {
    final doc = await _getResourcesCollection(resource.communityId).add(
      resource.toFirestore(),
    );

    return resource.copyWith(id: doc.id);
  }

  // Kaynağı güncelle
  Future<void> updateResource(ResourceModel resource) async {
    await _getResourcesCollection(resource.communityId)
        .doc(resource.id)
        .update(resource.toFirestore());
  }

  // Kaynağı sil
  Future<void> deleteResource(String communityId, String resourceId) async {
    await _getResourcesCollection(communityId).doc(resourceId).delete();
  }

  // Tüm kaynakları getir
  Future<List<ResourceModel>> getResources(
    String communityId, {
    ResourceType? type,
    ResourceCategory? category,
    ResourceDifficulty? difficulty,
    String? tag,
    bool onlyApproved = true,
    String? sortBy,
    bool descending = true,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _getResourcesCollection(communityId);

    if (onlyApproved) {
      query = query.where('isApproved', isEqualTo: true);
    }

    if (type != null) {
      query = query.where('type', isEqualTo: type.toString());
    }

    if (category != null) {
      query = query.where('category', isEqualTo: category.toString());
    }

    if (difficulty != null) {
      query = query.where('difficulty', isEqualTo: difficulty.toString());
    }

    if (tag != null) {
      query = query.where('tags', arrayContains: tag);
    }

    if (sortBy != null) {
      query = query.orderBy(sortBy, descending: descending);
    } else {
      query = query.orderBy('createdAt', descending: true);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    query = query.limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ResourceModel.fromFirestore(doc))
        .toList();
  }

  // Öne çıkan kaynakları getir
  Future<List<ResourceModel>> getFeaturedResources(String communityId) async {
    final snapshot = await _getResourcesCollection(communityId)
        .where('isFeatured', isEqualTo: true)
        .where('isApproved', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();

    return snapshot.docs
        .map((doc) => ResourceModel.fromFirestore(doc))
        .toList();
  }

  // Popüler kaynakları getir
  Future<List<ResourceModel>> getPopularResources(String communityId) async {
    final snapshot = await _getResourcesCollection(communityId)
        .where('isApproved', isEqualTo: true)
        .orderBy('views', descending: true)
        .orderBy('upvotes', descending: true)
        .limit(10)
        .get();

    return snapshot.docs
        .map((doc) => ResourceModel.fromFirestore(doc))
        .toList();
  }

  // Trend olan kaynakları getir
  Future<List<ResourceModel>> getTrendingResources(String communityId) async {
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));

    final snapshot = await _getResourcesCollection(communityId)
        .where('isApproved', isEqualTo: true)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(lastWeek))
        .orderBy('createdAt', descending: true)
        .orderBy('views', descending: true)
        .limit(10)
        .get();

    return snapshot.docs
        .map((doc) => ResourceModel.fromFirestore(doc))
        .toList();
  }

  // Kullanıcının kaynaklarını getir
  Future<List<ResourceModel>> getUserResources(
    String communityId,
    String userId,
  ) async {
    final snapshot = await _getResourcesCollection(communityId)
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ResourceModel.fromFirestore(doc))
        .toList();
  }

  // Kaynağı oyla
  Future<void> voteResource({
    required String communityId,
    required String resourceId,
    required String userId,
    required bool isUpvote,
  }) async {
    final resourceRef = _getResourcesCollection(communityId).doc(resourceId);
    final votesRef = resourceRef.collection('votes').doc(userId);

    final vote = await votesRef.get();
    final batch = _firestore.batch();

    if (vote.exists) {
      final currentVote = vote.data()?['isUpvote'] as bool;
      if (currentVote == isUpvote) {
        // Oylamayı kaldır
        batch.delete(votesRef);
        batch.update(resourceRef, {
          isUpvote ? 'upvotes' : 'downvotes': FieldValue.increment(-1),
        });
      } else {
        // Oylamayı değiştir
        batch.update(votesRef, {'isUpvote': isUpvote});
        batch.update(resourceRef, {
          'upvotes': FieldValue.increment(isUpvote ? 1 : -1),
          'downvotes': FieldValue.increment(isUpvote ? -1 : 1),
        });
      }
    } else {
      // Yeni oylama
      batch.set(votesRef, {'isUpvote': isUpvote});
      batch.update(resourceRef, {
        isUpvote ? 'upvotes' : 'downvotes': FieldValue.increment(1),
      });
    }

    await batch.commit();
  }

  // Görüntülenme sayısını artır
  Future<void> incrementViews(String communityId, String resourceId) async {
    await _getResourcesCollection(communityId).doc(resourceId).update({
      'views': FieldValue.increment(1),
    });
  }

  // Kaynağı öne çıkar
  Future<void> toggleFeatured(String communityId, String resourceId) async {
    final doc =
        await _getResourcesCollection(communityId).doc(resourceId).get();
    final isFeatured = doc.data()?['isFeatured'] as bool? ?? false;

    await doc.reference.update({
      'isFeatured': !isFeatured,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Kaynağı sabitle
  Future<void> togglePinned(String communityId, String resourceId) async {
    final doc =
        await _getResourcesCollection(communityId).doc(resourceId).get();
    final isPinned = doc.data()?['isPinned'] as bool? ?? false;

    await doc.reference.update({
      'isPinned': !isPinned,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Kaynağı onayla
  Future<void> approveResource(String communityId, String resourceId) async {
    await _getResourcesCollection(communityId).doc(resourceId).update({
      'isApproved': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Kaynak onayını kaldır
  Future<void> unapproveResource(String communityId, String resourceId) async {
    await _getResourcesCollection(communityId).doc(resourceId).update({
      'isApproved': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Kaynak yönetimi yetkisini kontrol et
  Future<bool> canManageResources(String communityId, String userId) async {
    return await _roleService.hasPermission(
      communityId,
      userId,
      RolePermission.manageResources,
    );
  }

  // Kaynak oluşturma yetkisini kontrol et
  Future<bool> canCreateResources(String communityId, String userId) async {
    return await _roleService.hasPermission(
      communityId,
      userId,
      RolePermission.createContent,
    );
  }

  // Kaynak düzenleme yetkisini kontrol et
  Future<bool> canEditResource(
    String communityId,
    String userId,
    String resourceId,
  ) async {
    final resource = await _getResourcesCollection(communityId)
        .doc(resourceId)
        .get()
        .then((doc) => ResourceModel.fromFirestore(doc));

    // Kaynak sahibi veya moderatör ise düzenleyebilir
    return resource.authorId == userId ||
        await _roleService.hasPermission(
          communityId,
          userId,
          RolePermission.moderateContent,
        );
  }

  // Kaynak silme yetkisini kontrol et
  Future<bool> canDeleteResource(
    String communityId,
    String userId,
    String resourceId,
  ) async {
    final resource = await _getResourcesCollection(communityId)
        .doc(resourceId)
        .get()
        .then((doc) => ResourceModel.fromFirestore(doc));

    // Kaynak sahibi veya moderatör ise silebilir
    return resource.authorId == userId ||
        await _roleService.hasPermission(
          communityId,
          userId,
          RolePermission.moderateContent,
        );
  }
}
