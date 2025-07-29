import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/community/resource_model.dart';

class ResourceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kaynakları getir
  Future<List<ResourceModel>> getResources(
    String communityId, {
    ResourceType? type,
    ResourceCategory? category,
    ResourceDifficulty? difficulty,
    String? tag,
  }) async {
    try {
      Query query = _firestore
          .collection('communities')
          .doc(communityId)
          .collection('resources')
          .where('isApproved', isEqualTo: true)
          .orderBy('createdAt', descending: true);

      if (type != null) {
        query = query.where('type', isEqualTo: type.toString());
      }

      if (category != null) {
        query = query.where('category', isEqualTo: category.toString());
      }

      if (difficulty != null) {
        query = query.where('difficulty', isEqualTo: difficulty.toString());
      }

      final querySnapshot = await query.get();
      final resources = querySnapshot.docs
          .map((doc) => ResourceModel.fromFirestore(doc))
          .toList();

      // Tag filtrelemesi client-side yapılır
      if (tag != null && tag.isNotEmpty) {
        resources.removeWhere((resource) => !resource.tags.contains(tag));
      }

      return resources;
    } catch (e) {
      throw 'Kaynaklar yüklenirken bir hata oluştu: $e';
    }
  }

  // Öne çıkan kaynakları getir
  Future<List<ResourceModel>> getFeaturedResources(String communityId) async {
    try {
      final querySnapshot = await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('resources')
          .where('isFeatured', isEqualTo: true)
          .where('isApproved', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      return querySnapshot.docs
          .map((doc) => ResourceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Öne çıkan kaynaklar yüklenirken bir hata oluştu: $e';
    }
  }

  // Popüler kaynakları getir
  Future<List<ResourceModel>> getPopularResources(String communityId) async {
    try {
      final querySnapshot = await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('resources')
          .where('isApproved', isEqualTo: true)
          .orderBy('views', descending: true)
          .orderBy('upvotes', descending: true)
          .limit(10)
          .get();

      return querySnapshot.docs
          .map((doc) => ResourceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Popüler kaynaklar yüklenirken bir hata oluştu: $e';
    }
  }

  // Trend olan kaynakları getir
  Future<List<ResourceModel>> getTrendingResources(String communityId) async {
    try {
      final querySnapshot = await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('resources')
          .where('isApproved', isEqualTo: true)
          .orderBy('upvotes', descending: true)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      return querySnapshot.docs
          .map((doc) => ResourceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Trend kaynaklar yüklenirken bir hata oluştu: $e';
    }
  }

  // Yeni kaynak oluştur
  Future<void> createResource(ResourceModel resource) async {
    try {
      final docRef = _firestore
          .collection('communities')
          .doc(resource.communityId)
          .collection('resources')
          .doc();

      final newResource = resource.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(newResource.toFirestore());
    } catch (e) {
      throw 'Kaynak oluşturulurken bir hata oluştu: $e';
    }
  }

  // Kaynağı güncelle
  Future<void> updateResource(ResourceModel resource) async {
    try {
      await _firestore
          .collection('communities')
          .doc(resource.communityId)
          .collection('resources')
          .doc(resource.id)
          .update(resource.copyWith(updatedAt: DateTime.now()).toFirestore());
    } catch (e) {
      throw 'Kaynak güncellenirken bir hata oluştu: $e';
    }
  }

  // Kaynağı sil
  Future<void> deleteResource(String communityId, String resourceId) async {
    try {
      await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('resources')
          .doc(resourceId)
          .delete();
    } catch (e) {
      throw 'Kaynak silinirken bir hata oluştu: $e';
    }
  }

  // Kaynağı oyla
  Future<void> voteResource({
    required String communityId,
    required String resourceId,
    required String userId,
    required bool isUpvote,
  }) async {
    try {
      final docRef = _firestore
          .collection('communities')
          .doc(communityId)
          .collection('resources')
          .doc(resourceId);

      final voteRef = _firestore
          .collection('communities')
          .doc(communityId)
          .collection('resources')
          .doc(resourceId)
          .collection('votes')
          .doc(userId);

      await _firestore.runTransaction((transaction) async {
        final resourceDoc = await transaction.get(docRef);
        final voteDoc = await transaction.get(voteRef);

        if (!resourceDoc.exists) {
          throw 'Kaynak bulunamadı';
        }

        final currentUpvotes = resourceDoc.data()?['upvotes'] ?? 0;
        final currentDownvotes = resourceDoc.data()?['downvotes'] ?? 0;
        int newUpvotes = currentUpvotes;
        int newDownvotes = currentDownvotes;

        if (voteDoc.exists) {
          final previousVote = voteDoc.data()?['isUpvote'] as bool?;
          if (previousVote == isUpvote) {
            // Aynı oy tekrar verilmiş, oyu kaldır
            if (isUpvote) {
              newUpvotes--;
            } else {
              newDownvotes--;
            }
            transaction.delete(voteRef);
          } else {
            // Farklı oy verilmiş, oyu değiştir
            if (isUpvote) {
              newUpvotes++;
              newDownvotes--;
            } else {
              newDownvotes++;
              newUpvotes--;
            }
            transaction.set(voteRef, {
              'userId': userId,
              'isUpvote': isUpvote,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        } else {
          // İlk oy
          if (isUpvote) {
            newUpvotes++;
          } else {
            newDownvotes++;
          }
          transaction.set(voteRef, {
            'userId': userId,
            'isUpvote': isUpvote,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        transaction.update(docRef, {
          'upvotes': newUpvotes,
          'downvotes': newDownvotes,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw 'Oylama yapılırken bir hata oluştu: $e';
    }
  }

  // Görüntülenme sayısını artır
  Future<void> incrementViews(String communityId, String resourceId) async {
    try {
      await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('resources')
          .doc(resourceId)
          .update({
        'views': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Görüntülenme sayısı artırılırken bir hata oluştu: $e');
    }
  }

  // Kaynağı öne çıkar
  Future<void> toggleFeatured(String communityId, String resourceId) async {
    try {
      final docRef = _firestore
          .collection('communities')
          .doc(communityId)
          .collection('resources')
          .doc(resourceId);

      final doc = await docRef.get();
      if (!doc.exists) {
        throw 'Kaynak bulunamadı';
      }

      final currentFeatured = doc.data()?['isFeatured'] ?? false;
      await docRef.update({
        'isFeatured': !currentFeatured,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Kaynak durumu güncellenirken bir hata oluştu: $e';
    }
  }

  // Kaynağı sabitle
  Future<void> togglePinned(String communityId, String resourceId) async {
    try {
      final docRef = _firestore
          .collection('communities')
          .doc(communityId)
          .collection('resources')
          .doc(resourceId);

      final doc = await docRef.get();
      if (!doc.exists) {
        throw 'Kaynak bulunamadı';
      }

      final currentPinned = doc.data()?['isPinned'] ?? false;
      await docRef.update({
        'isPinned': !currentPinned,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Kaynak durumu güncellenirken bir hata oluştu: $e';
    }
  }

  // Kaynağı onayla
  Future<void> approveResource(String communityId, String resourceId) async {
    try {
      await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('resources')
          .doc(resourceId)
          .update({
        'isApproved': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Kaynak onaylanırken bir hata oluştu: $e';
    }
  }

  // Kaynak onayını kaldır
  Future<void> unapproveResource(String communityId, String resourceId) async {
    try {
      await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('resources')
          .doc(resourceId)
          .update({
        'isApproved': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Kaynak onayı kaldırılırken bir hata oluştu: $e';
    }
  }

  // Kaynak yönetimi yetkisini kontrol et
  Future<bool> canManageResources(String communityId, String userId) async {
    try {
      final membershipDoc = await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('members')
          .doc(userId)
          .get();

      if (!membershipDoc.exists) return false;

      final role = membershipDoc.data()?['role'] as String?;
      return role == 'admin' || role == 'moderator';
    } catch (e) {
      return false;
    }
  }

  // Kaynak oluşturma yetkisini kontrol et
  Future<bool> canCreateResources(String communityId, String userId) async {
    try {
      final membershipDoc = await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('members')
          .doc(userId)
          .get();

      if (!membershipDoc.exists) return false;

      final role = membershipDoc.data()?['role'] as String?;
      final status = membershipDoc.data()?['status'] as String?;

      return (role == 'admin' || role == 'moderator' || role == 'member') &&
          status == 'approved';
    } catch (e) {
      return false;
    }
  }

  // Kaynak düzenleme yetkisini kontrol et
  Future<bool> canEditResource(
    String communityId,
    String userId,
    String resourceId,
  ) async {
    try {
      final resourceDoc = await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('resources')
          .doc(resourceId)
          .get();

      if (!resourceDoc.exists) return false;

      final authorId = resourceDoc.data()?['authorId'] as String?;
      if (authorId == userId) return true;

      return await canManageResources(communityId, userId);
    } catch (e) {
      return false;
    }
  }

  // Kaynak silme yetkisini kontrol et
  Future<bool> canDeleteResource(
    String communityId,
    String userId,
    String resourceId,
  ) async {
    try {
      final resourceDoc = await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('resources')
          .doc(resourceId)
          .get();

      if (!resourceDoc.exists) return false;

      final authorId = resourceDoc.data()?['authorId'] as String?;
      if (authorId == userId) return true;

      return await canManageResources(communityId, userId);
    } catch (e) {
      return false;
    }
  }
}
