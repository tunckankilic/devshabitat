import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../core/services/error_handler_service.dart';
import '../models/post.dart';
import '../models/feed_item.dart';
import '../controllers/auth_controller.dart';

class FeedService extends GetxService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ErrorHandlerService _errorHandler;
  final AuthController _authController = Get.find();

  FeedService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    ErrorHandlerService? errorHandler,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _errorHandler = errorHandler ?? Get.find();

  // For You feed stream'i (kendi ve bağlantıların postları)
  Stream<List<Post>> getForYouFeedStream() {
    try {
      final user = _auth.currentUser;
      if (user == null) return Stream.value([]);

      return _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .asyncMap((userDoc) async {
        if (!userDoc.exists) return [];

        // Kullanıcının bağlantılarını al
        final connections =
            List<String>.from(userDoc.data()?['connections'] ?? []);
        connections.add(user.uid); // Kendi postlarını da ekle

        // Son 50 postu getir
        final querySnapshot = await _firestore
            .collection('posts')
            .where('userId', whereIn: connections)
            .orderBy('createdAt', descending: true)
            .limit(50)
            .get();

        return querySnapshot.docs
            .map((doc) => Post.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList();
      });
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.SERVER_ERROR);
      return Stream.value([]);
    }
  }

  // Popular feed stream'i (tüm kullanıcılardan en popüler postlar)
  Stream<List<Post>> getPopularFeedStream() {
    try {
      return _firestore
          .collection('posts')
          .orderBy('likes', descending: true)
          .limit(30)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Post.fromJson({
                    ...doc.data(),
                    'id': doc.id,
                  }))
              .toList());
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.SERVER_ERROR);
      return Stream.value([]);
    }
  }

  // Profil feed'i
  Stream<List<Post>> getProfileFeedStream(String userId) {
    try {
      return _firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Post.fromJson({
                    ...doc.data(),
                    'id': doc.id,
                  }))
              .toList());
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.SERVER_ERROR);
      return Stream.value([]);
    }
  }

  // Etiket bazlı feed
  Stream<List<Post>> getTagFeedStream(String tag) {
    try {
      return _firestore
          .collection('posts')
          .where('metadata.tags', arrayContains: tag)
          .orderBy('createdAt', descending: true)
          .limit(30)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Post.fromJson({
                    ...doc.data(),
                    'id': doc.id,
                  }))
              .toList());
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.SERVER_ERROR);
      return Stream.value([]);
    }
  }

  Future<List<FeedItem>> getFeedItems({int limit = 10}) async {
    try {
      final userId = _authController.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('feed')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => FeedItem.fromMap(doc.data(), id: doc.id))
          .toList();
    } catch (e) {
      print('Feed öğeleri alınırken hata: $e');
      return [];
    }
  }

  Future<void> likeFeedItem(String feedItemId) async {
    try {
      final userId = _authController.currentUser?.uid;
      if (userId == null) throw 'Kullanıcı oturumu bulunamadı';

      final feedRef = _firestore.collection('feed').doc(feedItemId);
      final likesRef = feedRef.collection('likes');

      final likeDoc = await likesRef.doc(userId).get();
      if (likeDoc.exists) {
        // Beğeniyi kaldır
        await likeDoc.reference.delete();
        await feedRef.update({
          'likesCount': FieldValue.increment(-1),
        });
      } else {
        // Beğeni ekle
        await likesRef.doc(userId).set({
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await feedRef.update({
          'likesCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      print('Feed öğesi beğenilirken hata: $e');
      rethrow;
    }
  }

  Future<void> shareFeedItem(String feedItemId) async {
    try {
      final userId = _authController.currentUser?.uid;
      if (userId == null) throw 'Kullanıcı oturumu bulunamadı';

      final feedRef = _firestore.collection('feed').doc(feedItemId);
      final sharesRef = feedRef.collection('shares');

      final shareDoc = await sharesRef.doc(userId).get();
      if (!shareDoc.exists) {
        // Paylaşım ekle
        await sharesRef.doc(userId).set({
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await feedRef.update({
          'sharesCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      print('Feed öğesi paylaşılırken hata: $e');
      rethrow;
    }
  }

  Future<void> addComment(String feedItemId, String comment) async {
    try {
      final userId = _authController.currentUser?.uid;
      if (userId == null) throw 'Kullanıcı oturumu bulunamadı';

      final feedRef = _firestore.collection('feed').doc(feedItemId);
      final commentsRef = feedRef.collection('comments');

      await commentsRef.add({
        'userId': userId,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await feedRef.update({
        'commentsCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Yorum eklenirken hata: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getComments(
    String feedItemId, {
    int limit = 10,
  }) async {
    try {
      final commentsRef = _firestore
          .collection('feed')
          .doc(feedItemId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      final snapshot = await commentsRef.get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Yorumlar alınırken hata: $e');
      return [];
    }
  }
}
