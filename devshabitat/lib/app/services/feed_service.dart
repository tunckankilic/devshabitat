import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../core/services/error_handler_service.dart';
import '../models/post.dart';

class FeedService extends GetxService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ErrorHandlerService _errorHandler;

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
      _errorHandler.handleError(e);
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
      _errorHandler.handleError(e);
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
      _errorHandler.handleError(e);
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
      _errorHandler.handleError(e);
      return Stream.value([]);
    }
  }
}
