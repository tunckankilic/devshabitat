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

      final user = _authController.currentUser;
      final userName = user?.displayName ?? 'Kullanıcı';
      final userPhotoUrl = user?.photoURL;

      final feedRef = _firestore.collection('feed').doc(feedItemId);
      final commentsRef = feedRef.collection('comments');

      await commentsRef.add({
        'userId': userId,
        'userName': userName,
        'userPhotoUrl': userPhotoUrl,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
        'likesCount': 0,
        'isLiked': false,
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
      final userId = _authController.currentUser?.uid;
      final commentsRef = _firestore
          .collection('feed')
          .doc(feedItemId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      final snapshot = await commentsRef.get();
      final comments = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final commentData = doc.data();
        final commentId = doc.id;

        // Kullanıcının bu yorumu beğenip beğenmediğini kontrol et
        bool isLiked = false;
        if (userId != null) {
          final likeDoc = await _firestore
              .collection('feed')
              .doc(feedItemId)
              .collection('comments')
              .doc(commentId)
              .collection('likes')
              .doc(userId)
              .get();
          isLiked = likeDoc.exists;
        }

        comments.add({
          ...commentData,
          'id': commentId,
          'isLiked': isLiked,
        });
      }

      return comments;
    } catch (e) {
      print('Yorumlar alınırken hata: $e');
      return [];
    }
  }

  Future<void> deleteComment(String feedItemId, String commentId) async {
    try {
      final userId = _authController.currentUser?.uid;
      if (userId == null) throw 'Kullanıcı oturumu bulunamadı';

      final feedRef = _firestore.collection('feed').doc(feedItemId);
      final commentRef = feedRef.collection('comments').doc(commentId);

      // Yorumun kullanıcıya ait olup olmadığını kontrol et
      final commentDoc = await commentRef.get();
      if (!commentDoc.exists) {
        throw 'Yorum bulunamadı';
      }

      final commentData = commentDoc.data();
      if (commentData?['userId'] != userId) {
        throw 'Bu yorumu silme yetkiniz yok';
      }

      // Yorumu sil
      await commentRef.delete();

      // Feed öğesinin yorum sayısını güncelle
      await feedRef.update({
        'commentsCount': FieldValue.increment(-1),
      });
    } catch (e) {
      print('Yorum silinirken hata: $e');
      rethrow;
    }
  }

  Future<void> likeComment(String feedItemId, String commentId) async {
    try {
      final userId = _authController.currentUser?.uid;
      if (userId == null) throw 'Kullanıcı oturumu bulunamadı';

      final feedRef = _firestore.collection('feed').doc(feedItemId);
      final commentRef = feedRef.collection('comments').doc(commentId);
      final likesRef = commentRef.collection('likes');

      final likeDoc = await likesRef.doc(userId).get();
      if (likeDoc.exists) {
        // Beğeniyi kaldır
        await likeDoc.reference.delete();
        await commentRef.update({
          'likesCount': FieldValue.increment(-1),
        });
      } else {
        // Beğeni ekle
        await likesRef.doc(userId).set({
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await commentRef.update({
          'likesCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      print('Yorum beğenilirken hata: $e');
      rethrow;
    }
  }
}
