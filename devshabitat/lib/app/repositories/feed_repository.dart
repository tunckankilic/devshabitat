import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feed_item.dart';

class FeedRepository {
  final FirebaseFirestore _firestore;

  FeedRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<FeedItem>> getFeedItems() async {
    final snapshot = await _firestore
        .collection('feed')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => FeedItem.fromJson({
              ...doc.data(),
              'id': doc.id,
            }))
        .toList();
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
}
