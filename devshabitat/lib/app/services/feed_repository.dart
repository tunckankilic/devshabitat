import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feed_item.dart';

class FeedRepository {
  final FirebaseFirestore _firestore;

  FeedRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<FeedItem>> getFeedItems({
    required int page,
    required int pageSize,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('feed')
          .orderBy('createdAt', descending: true)
          .limit(pageSize)
          .startAfter([(page - 1) * pageSize]).get();

      return snapshot.docs
          .map((doc) => FeedItem.fromMap(doc.data(), id: doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> likeFeedItem(String itemId) async {
    try {
      await _firestore.collection('feed').doc(itemId).update({
        'likesCount': FieldValue.increment(1),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> shareFeedItem(String itemId) async {
    try {
      await _firestore.collection('feed').doc(itemId).update({
        'sharesCount': FieldValue.increment(1),
      });
    } catch (e) {
      rethrow;
    }
  }
}
