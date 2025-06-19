import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feed_item.dart';

class FeedRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<FeedItem>> getFeedItems({int page = 1, int pageSize = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection('feed')
          .orderBy('createdAt', descending: true)
          .limit(pageSize)
          .get();

      return querySnapshot.docs
          .map((doc) => FeedItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Feed öğeleri yüklenirken hata oluştu: $e');
    }
  }

  Future<void> createFeedItem(FeedItem item) async {
    await _firestore.collection('feed').add(item.toJson());
  }

  Future<void> updateFeedItem(FeedItem item) async {
    await _firestore.collection('feed').doc(item.id).update(item.toJson());
  }

  Future<void> deleteFeedItem(String id) async {
    await _firestore.collection('feed').doc(id).delete();
  }

  Future<void> likeFeedItem(String itemId) async {
    try {
      await _firestore.collection('feed').doc(itemId).update({
        'likesCount': FieldValue.increment(1),
        'isLiked': true,
      });
    } catch (e) {
      throw Exception('Beğeni işlemi başarısız oldu: $e');
    }
  }

  Future<void> unlikeFeedItem(String itemId) async {
    try {
      await _firestore.collection('feed').doc(itemId).update({
        'likesCount': FieldValue.increment(-1),
        'isLiked': false,
      });
    } catch (e) {
      throw Exception('Beğeni kaldırma işlemi başarısız oldu: $e');
    }
  }
}
