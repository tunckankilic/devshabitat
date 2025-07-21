import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devshabitat/app/repositories/auth_repository.dart';
import '../models/feed_item.dart';
import '../services/github_oauth_service.dart';
import '../core/services/error_handler_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class FeedRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthRepository _authService = AuthRepository(
    githubOAuthService: GitHubOAuthService(
      logger: Get.find<Logger>(),
      errorHandler: Get.find<ErrorHandlerService>(),
    ),
  );

  Future<List<FeedItem>> getFeedItems({int page = 1, int pageSize = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection('feed')
          .orderBy('createdAt', descending: true)
          .limit(pageSize)
          .get();

      return querySnapshot.docs
          .map((doc) => FeedItem.fromMap(doc.data(), id: doc.id))
          .toList();
    } catch (e) {
      throw Exception(AppStrings.feedLoadingError);
    }
  }

  Future<void> createFeedItem(FeedItem item) async {
    await _firestore.collection('feed').add(item.toMap());
  }

  Future<void> updateFeedItem(FeedItem item) async {
    await _firestore.collection('feed').doc(item.id).update(item.toMap());
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
      throw Exception(AppStrings.likeError);
    }
  }

  Future<void> unlikeFeedItem(String itemId) async {
    try {
      await _firestore.collection('feed').doc(itemId).update({
        'likesCount': FieldValue.increment(-1),
        'isLiked': false,
      });
    } catch (e) {
      throw Exception(AppStrings.unlikeError);
    }
  }

  Future<void> shareFeedItem(String itemId) async {
    try {
      final docRef = _firestore.collection('feed').doc(itemId);
      await docRef.update({
        'sharesCount': FieldValue.increment(1),
        'sharedBy': FieldValue.arrayUnion([_authService.currentUser?.uid]),
      });
    } catch (e) {
      throw Exception(AppStrings.shareError);
    }
  }
}
