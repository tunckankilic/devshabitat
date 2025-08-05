import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/comment_model.dart';
import '../repositories/auth_repository.dart';
import '../core/services/error_handler_service.dart';

class CommentService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final ErrorHandlerService _errorHandler = Get.find<ErrorHandlerService>();

  // Yorum ekleme
  Future<String?> addComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final user = _authRepository.currentUser;
      if (user == null) throw Exception('Kullanıcı oturum açmamış');

      final commentData = {
        'postId': postId,
        'authorId': user.uid,
        'authorName': user.displayName ?? 'Anonim',
        'authorPhotoUrl': user.photoURL,
        'content': content,
        'parentCommentId': parentCommentId,
        'likes': 0,
        'replies': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isEdited': false,
        'isDeleted': false,
      };

      final docRef = await _firestore.collection('comments').add(commentData);

      // Post'un yorum sayısını artır
      await _updatePostCommentCount(postId, 1);

      return docRef.id;
    } catch (e) {
      _logger.e('Yorum eklenirken hata: $e');
      _errorHandler.handleError('Yorum eklenemedi: $e', 'COMMENT_ADD_ERROR');
      return null;
    }
  }

  // Yorumları getir
  Future<List<CommentModel>> getComments(String postId) async {
    try {
      final snapshot = await _firestore
          .collection('comments')
          .where('postId', isEqualTo: postId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => CommentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      _logger.e('Yorumlar getirilirken hata: $e');
      _errorHandler.handleError(
        'Yorumlar getirilemedi: $e',
        'COMMENT_FETCH_ERROR',
      );
      return [];
    }
  }

  // Yorum beğenme/beğenmeme
  Future<bool> toggleLike(String commentId) async {
    try {
      final user = _authRepository.currentUser;
      if (user == null) throw Exception('Kullanıcı oturum açmamış');

      final likeDoc = await _firestore
          .collection('comment_likes')
          .where('commentId', isEqualTo: commentId)
          .where('userId', isEqualTo: user.uid)
          .get();

      if (likeDoc.docs.isEmpty) {
        // Beğeni ekle
        await _firestore.collection('comment_likes').add({
          'commentId': commentId,
          'userId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Yorum beğeni sayısını artır
        await _firestore.collection('comments').doc(commentId).update({
          'likes': FieldValue.increment(1),
        });

        return true;
      } else {
        // Beğeniyi kaldır
        await _firestore
            .collection('comment_likes')
            .doc(likeDoc.docs.first.id)
            .delete();

        // Yorum beğeni sayısını azalt
        await _firestore.collection('comments').doc(commentId).update({
          'likes': FieldValue.increment(-1),
        });

        return false;
      }
    } catch (e) {
      _logger.e('Yorum beğenme işleminde hata: $e');
      _errorHandler.handleError(
        'Beğeni işlemi başarısız: $e',
        'COMMENT_LIKE_ERROR',
      );
      return false;
    }
  }

  // Yorum düzenleme
  Future<bool> editComment(String commentId, String newContent) async {
    try {
      final user = _authRepository.currentUser;
      if (user == null) throw Exception('Kullanıcı oturum açmamış');

      await _firestore.collection('comments').doc(commentId).update({
        'content': newContent,
        'updatedAt': FieldValue.serverTimestamp(),
        'isEdited': true,
      });

      return true;
    } catch (e) {
      _logger.e('Yorum düzenlenirken hata: $e');
      _errorHandler.handleError(
        'Yorum düzenlenemedi: $e',
        'COMMENT_EDIT_ERROR',
      );
      return false;
    }
  }

  // Yorum silme
  Future<bool> deleteComment(String commentId, String postId) async {
    try {
      final user = _authRepository.currentUser;
      if (user == null) throw Exception('Kullanıcı oturum açmamış');

      await _firestore.collection('comments').doc(commentId).update({
        'isDeleted': true,
        'content': '[Bu yorum silindi]',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Post'un yorum sayısını azalt
      await _updatePostCommentCount(postId, -1);

      return true;
    } catch (e) {
      _logger.e('Yorum silinirken hata: $e');
      _errorHandler.handleError('Yorum silinemedi: $e', 'COMMENT_DELETE_ERROR');
      return false;
    }
  }

  // Post'un yorum sayısını güncelle
  Future<void> _updatePostCommentCount(String postId, int increment) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'commentCount': FieldValue.increment(increment),
      });
    } catch (e) {
      _logger.w('Post yorum sayısı güncellenemedi: $e');
    }
  }

  // Kullanıcının yorumlarını getir
  Future<List<CommentModel>> getUserComments(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('comments')
          .where('authorId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CommentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      _logger.e('Kullanıcı yorumları getirilirken hata: $e');
      return [];
    }
  }
}
