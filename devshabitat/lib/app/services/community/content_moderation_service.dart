import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/community/content_model.dart';
import '../../core/services/base_firestore_service.dart';

class ContentModerationService extends BaseFirestoreService {
  final CollectionReference _contentCollection = FirebaseFirestore.instance
      .collection('community_content');

  Future<QuerySnapshot> getApprovedContent({
    required String communityId,
    int limit = 20,
    DocumentSnapshot? startAfter,
    ContentType? contentType,
  }) async {
    Query query = _contentCollection
        .where('communityId', isEqualTo: communityId)
        .where('status', isEqualTo: ContentStatus.approved.name);

    if (contentType != null) {
      query = query.where('type', isEqualTo: contentType.name);
    }

    query = query.orderBy('createdAt', descending: true).limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.get();
  }

  Future<void> submitContent(CommunityContentModel content) async {
    final docRef = _contentCollection.doc();
    await docRef.set({
      ...content.toMap(),
      'id': docRef.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> approveContent(String contentId) async {
    await _contentCollection.doc(contentId).update({
      'status': ContentStatus.approved.name,
      'moderatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> rejectContent(String contentId, String reason) async {
    await _contentCollection.doc(contentId).update({
      'status': ContentStatus.rejected.name,
      'rejectionReason': reason,
      'moderatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteContent(String contentId) async {
    await _contentCollection.doc(contentId).delete();
  }

  Future<void> likeContent({
    required String contentId,
    required String userId,
  }) async {
    await _contentCollection.doc(contentId).update({
      'likedBy': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> unlikeContent({
    required String contentId,
    required String userId,
  }) async {
    await _contentCollection.doc(contentId).update({
      'likedBy': FieldValue.arrayRemove([userId]),
    });
  }

  Future<QuerySnapshot> getPendingContent({
    required String communityId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = _contentCollection
        .where('communityId', isEqualTo: communityId)
        .where('status', isEqualTo: ContentStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.get();
  }

  Future<void> reportContent({
    required String contentId,
    required String reporterId,
    required String reason,
  }) async {
    final reportRef = _contentCollection
        .doc(contentId)
        .collection('reports')
        .doc(reporterId);

    await reportRef.set({
      'reporterId': reporterId,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Rapor sayısını artır
    await _contentCollection.doc(contentId).update({
      'reportCount': FieldValue.increment(1),
    });
  }

  Stream<QuerySnapshot> streamCommunityContent(String communityId) {
    return _contentCollection
        .where('communityId', isEqualTo: communityId)
        .where('status', isEqualTo: ContentStatus.approved.name)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }
}
