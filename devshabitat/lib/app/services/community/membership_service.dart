import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devshabitat/app/models/community/membership_model.dart';
import 'package:devshabitat/app/models/user_profile_model.dart';
import 'package:get/get.dart';

class MembershipService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'communities';

  // Join a community
  Future<MembershipModel> joinCommunity({
    required String communityId,
    required String userId,
    MembershipRole role = MembershipRole.member,
    bool requiresApproval = false,
  }) async {
    final membership = MembershipModel(
      id: '',
      communityId: communityId,
      userId: userId,
      role: role,
      status:
          requiresApproval ? MembershipStatus.pending : MembershipStatus.active,
      joinedAt: DateTime.now(),
    );

    final docRef = await _firestore
        .collection(_collection)
        .doc(communityId)
        .collection('members')
        .add(membership.toJson());

    return membership.copyWith(id: docRef.id);
  }

  // Leave a community
  Future<void> leaveCommunity({
    required String communityId,
    required String userId,
  }) async {
    final snapshot = await _firestore
        .collection(_collection)
        .doc(communityId)
        .collection('members')
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.delete();
    }
  }

  // Update member role
  Future<void> updateMemberRole({
    required String communityId,
    required String userId,
    required MembershipRole newRole,
  }) async {
    final snapshot = await _firestore
        .collection(_collection)
        .doc(communityId)
        .collection('members')
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({'role': newRole.toString()});
    }
  }

  // Get member status
  Future<MembershipModel?> getMemberStatus({
    required String communityId,
    required String userId,
  }) async {
    final snapshot = await _firestore
        .collection(_collection)
        .doc(communityId)
        .collection('members')
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return MembershipModel.fromFirestore(snapshot.docs.first);
  }

  // Get community members
  Future<List<MembershipModel>> getCommunityMembers({
    required String communityId,
    MembershipRole? role,
    MembershipStatus? status,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = _firestore
        .collection(_collection)
        .doc(communityId)
        .collection('members');

    if (role != null) {
      query = query.where('role', isEqualTo: role.toString());
    }

    if (status != null) {
      query = query.where('status', isEqualTo: status.toString());
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.limit(limit).get();
    return snapshot.docs
        .map((doc) => MembershipModel.fromFirestore(doc))
        .toList();
  }

  // Approve or reject membership request
  Future<void> handleMembershipRequest({
    required String communityId,
    required String userId,
    required bool approved,
  }) async {
    final snapshot = await _firestore
        .collection(_collection)
        .doc(communityId)
        .collection('members')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: MembershipStatus.pending.toString())
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'status': approved
            ? MembershipStatus.active.toString()
            : MembershipStatus.blocked.toString(),
      });
    }
  }

  // Block a member
  Future<void> blockMember({
    required String communityId,
    required String userId,
  }) async {
    final snapshot = await _firestore
        .collection(_collection)
        .doc(communityId)
        .collection('members')
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'status': MembershipStatus.blocked.toString(),
      });
    }
  }

  // Get user's communities
  Future<List<String>> getUserCommunities({
    required String userId,
    MembershipStatus status = MembershipStatus.active,
  }) async {
    final communities = <String>[];
    final snapshot = await _firestore
        .collectionGroup('members')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status.toString())
        .get();

    for (var doc in snapshot.docs) {
      communities.add(doc.reference.parent.parent!.id);
    }

    return communities;
  }

  // Üyelik talebi gönderme
  Future<void> requestMembership({
    required String communityId,
    required String userId,
  }) async {
    try {
      final communityRef =
          _firestore.collection('communities').doc(communityId);
      _firestore.collection('users').doc(userId);

      await _firestore.runTransaction((transaction) async {
        final communityDoc = await transaction.get(communityRef);
        if (!communityDoc.exists) {
          throw Exception('Topluluk bulunamadı');
        }

        final pendingMemberIds =
            List<String>.from(communityDoc.data()?['pendingMemberIds'] ?? []);
        final memberIds =
            List<String>.from(communityDoc.data()?['memberIds'] ?? []);

        if (memberIds.contains(userId)) {
          throw Exception('Zaten topluluk üyesisiniz');
        }

        if (pendingMemberIds.contains(userId)) {
          throw Exception('Zaten bekleyen bir üyelik talebiniz var');
        }

        pendingMemberIds.add(userId);
        transaction.update(communityRef, {
          'pendingMemberIds': pendingMemberIds,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Üyelik talebi gönderilemedi: $e');
    }
  }

  // Üyelik talebini kabul etme
  Future<void> acceptMembership({
    required String communityId,
    required String userId,
  }) async {
    try {
      final communityRef =
          _firestore.collection('communities').doc(communityId);
      _firestore.collection('users').doc(userId);

      await _firestore.runTransaction((transaction) async {
        final communityDoc = await transaction.get(communityRef);
        if (!communityDoc.exists) {
          throw Exception('Topluluk bulunamadı');
        }

        final pendingMemberIds =
            List<String>.from(communityDoc.data()?['pendingMemberIds'] ?? []);
        final memberIds =
            List<String>.from(communityDoc.data()?['memberIds'] ?? []);

        if (!pendingMemberIds.contains(userId)) {
          throw Exception('Bekleyen üyelik talebi bulunamadı');
        }

        pendingMemberIds.remove(userId);
        memberIds.add(userId);

        transaction.update(communityRef, {
          'pendingMemberIds': pendingMemberIds,
          'memberIds': memberIds,
          'memberCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Üyelik talebi kabul edilemedi: $e');
    }
  }

  // Üyelik talebini reddetme
  Future<void> rejectMembership({
    required String communityId,
    required String userId,
  }) async {
    try {
      final communityRef =
          _firestore.collection('communities').doc(communityId);

      await _firestore.runTransaction((transaction) async {
        final communityDoc = await transaction.get(communityRef);
        if (!communityDoc.exists) {
          throw Exception('Topluluk bulunamadı');
        }

        final pendingMemberIds =
            List<String>.from(communityDoc.data()?['pendingMemberIds'] ?? []);

        if (!pendingMemberIds.contains(userId)) {
          throw Exception('Bekleyen üyelik talebi bulunamadı');
        }

        pendingMemberIds.remove(userId);

        transaction.update(communityRef, {
          'pendingMemberIds': pendingMemberIds,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Üyelik talebi reddedilemedi: $e');
    }
  }

  // Üyeyi topluluktan çıkarma
  Future<void> removeMember({
    required String communityId,
    required String userId,
  }) async {
    try {
      final communityRef =
          _firestore.collection('communities').doc(communityId);

      await _firestore.runTransaction((transaction) async {
        final communityDoc = await transaction.get(communityRef);
        if (!communityDoc.exists) {
          throw Exception('Topluluk bulunamadı');
        }

        final memberIds =
            List<String>.from(communityDoc.data()?['memberIds'] ?? []);
        final moderatorIds =
            List<String>.from(communityDoc.data()?['moderatorIds'] ?? []);

        if (!memberIds.contains(userId)) {
          throw Exception('Üye bulunamadı');
        }

        memberIds.remove(userId);
        moderatorIds
            .remove(userId); // Eğer moderatör ise, moderatörlükten de çıkar

        transaction.update(communityRef, {
          'memberIds': memberIds,
          'moderatorIds': moderatorIds,
          'memberCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Üye çıkarılamadı: $e');
    }
  }

  // Üyeyi moderatör yapma
  Future<void> promoteToModerator({
    required String communityId,
    required String userId,
  }) async {
    try {
      final communityRef =
          _firestore.collection('communities').doc(communityId);

      await _firestore.runTransaction((transaction) async {
        final communityDoc = await transaction.get(communityRef);
        if (!communityDoc.exists) {
          throw Exception('Topluluk bulunamadı');
        }

        final memberIds =
            List<String>.from(communityDoc.data()?['memberIds'] ?? []);
        final moderatorIds =
            List<String>.from(communityDoc.data()?['moderatorIds'] ?? []);

        if (!memberIds.contains(userId)) {
          throw Exception('Üye bulunamadı');
        }

        if (moderatorIds.contains(userId)) {
          throw Exception('Kullanıcı zaten moderatör');
        }

        moderatorIds.add(userId);

        transaction.update(communityRef, {
          'moderatorIds': moderatorIds,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Moderatör atanamadı: $e');
    }
  }

  // Topluluk üyelerini detaylı getirme
  Future<List<UserProfile>> getCommunityMembersDetailed(
      String communityId) async {
    try {
      final communityDoc =
          await _firestore.collection('communities').doc(communityId).get();

      if (!communityDoc.exists) {
        throw Exception('Topluluk bulunamadı');
      }

      final memberIds =
          List<String>.from(communityDoc.data()?['memberIds'] ?? []);
      if (memberIds.isEmpty) return [];

      final userDocs = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: memberIds)
          .get();

      return userDocs.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Üyeler getirilemedi: $e');
    }
  }

  // Bekleyen üyeleri getirme
  Future<List<UserProfile>> getPendingMembers(String communityId) async {
    try {
      final communityDoc =
          await _firestore.collection('communities').doc(communityId).get();

      if (!communityDoc.exists) {
        throw Exception('Topluluk bulunamadı');
      }

      final pendingMemberIds =
          List<String>.from(communityDoc.data()?['pendingMemberIds'] ?? []);
      if (pendingMemberIds.isEmpty) return [];

      final userDocs = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: pendingMemberIds)
          .get();

      return userDocs.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Bekleyen üyeler getirilemedi: $e');
    }
  }
}
