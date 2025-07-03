import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devshabitat/app/models/community/membership_model.dart';
import 'package:devshabitat/app/services/community/membership_service.dart';

class ModerationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'communities';
  final MembershipService _membershipService = MembershipService();

  // Check if user has moderation rights
  Future<bool> canModerate({
    required String communityId,
    required String userId,
  }) async {
    final membership = await _membershipService.getMemberStatus(
      communityId: communityId,
      userId: userId,
    );

    return membership?.role == MembershipRole.admin ||
        membership?.role == MembershipRole.moderator;
  }

  // Report content
  Future<void> reportContent({
    required String communityId,
    required String contentId,
    required String reporterId,
    required String reason,
    required String contentType, // 'post', 'comment', 'event', etc.
  }) async {
    await _firestore
        .collection(_collection)
        .doc(communityId)
        .collection('reports')
        .add({
      'contentId': contentId,
      'contentType': contentType,
      'reporterId': reporterId,
      'reason': reason,
      'status': 'pending',
      'createdAt': DateTime.now(),
    });
  }

  // Get reported content
  Future<List<Map<String, dynamic>>> getReportedContent({
    required String communityId,
    String? status,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = _firestore
        .collection(_collection)
        .doc(communityId)
        .collection('reports');

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot =
        await query.orderBy('createdAt', descending: true).limit(limit).get();

    return snapshot.docs
        .map((doc) => {
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            })
        .toList();
  }

  // Handle report
  Future<void> handleReport({
    required String communityId,
    required String reportId,
    required String action, // 'dismiss', 'remove_content', 'ban_user'
    String? moderatorNote,
  }) async {
    final reportRef = _firestore
        .collection(_collection)
        .doc(communityId)
        .collection('reports')
        .doc(reportId);

    await reportRef.update({
      'status': 'resolved',
      'action': action,
      'moderatorNote': moderatorNote,
      'resolvedAt': DateTime.now(),
    });

    // If action is ban_user, get the reported content and ban the user
    if (action == 'ban_user') {
      final report = await reportRef.get();
      final data = report.data();
      if (data != null && data['contentId'] != null) {
        final contentDoc = await _firestore
            .collection(_collection)
            .doc(communityId)
            .collection(data['contentType'])
            .doc(data['contentId'])
            .get();

        if (contentDoc.exists) {
          final userId = contentDoc.data()?['userId'];
          if (userId != null) {
            await _membershipService.blockMember(
              communityId: communityId,
              userId: userId,
            );
          }
        }
      }
    }
  }

  // Get moderation logs
  Future<List<Map<String, dynamic>>> getModerationLogs({
    required String communityId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = _firestore
        .collection(_collection)
        .doc(communityId)
        .collection('reports')
        .where('status', isEqualTo: 'resolved');

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot =
        await query.orderBy('resolvedAt', descending: true).limit(limit).get();

    return snapshot.docs
        .map((doc) => {
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            })
        .toList();
  }

  // Get community guidelines
  Future<Map<String, dynamic>?> getCommunityGuidelines(
      String communityId) async {
    final doc = await _firestore
        .collection(_collection)
        .doc(communityId)
        .collection('settings')
        .doc('guidelines')
        .get();

    return doc.data();
  }

  // Update community guidelines
  Future<void> updateCommunityGuidelines({
    required String communityId,
    required Map<String, dynamic> guidelines,
  }) async {
    await _firestore
        .collection(_collection)
        .doc(communityId)
        .collection('settings')
        .doc('guidelines')
        .set(guidelines, SetOptions(merge: true));
  }
}
