import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/post.dart';
import 'image_upload_service.dart';
import '../core/services/error_handler_service.dart';

class PostService extends GetxService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ImageUploadService _imageUploadService;
  final ErrorHandlerService _errorHandler;

  PostService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    ImageUploadService? imageUploadService,
    ErrorHandlerService? errorHandler,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _imageUploadService = imageUploadService ?? Get.find(),
        _errorHandler = errorHandler ?? Get.find();

  // Post oluştur
  Future<Post?> createPost({
    required String content,
    List<String> imagePaths = const [],
    String? githubRepoUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturum açmamış');

      // Resimleri yükle
      final uploadedImages = await Future.wait(
        imagePaths.map((path) => _imageUploadService.uploadImage(path)),
      );

      // Post verilerini hazırla
      final postData = {
        'userId': user.uid,
        'content': content,
        'images': uploadedImages.whereType<String>().toList(),
        'likes': [],
        'comments': [],
        'createdAt': FieldValue.serverTimestamp(),
        'githubRepoUrl': githubRepoUrl,
        'metadata': metadata,
      };

      // Post'u Firestore'a kaydet
      final docRef = await _firestore.collection('posts').add(postData);

      // Post verilerini al
      final doc = await docRef.get();
      if (!doc.exists) throw Exception('Post oluşturulamadı');

      return Post.fromJson({
        ...doc.data()!,
        'id': doc.id,
        'createdAt': doc.data()!['createdAt'] ?? Timestamp.now(),
      });
    } catch (e) {
      _errorHandler.handleError(e);
      return null;
    }
  }

  // Post'ları getir
  Stream<List<Post>> getPosts({String? userId}) {
    try {
      var query =
          _firestore.collection('posts').orderBy('createdAt', descending: true);

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return Post.fromJson({
            ...doc.data(),
            'id': doc.id,
          });
        }).toList();
      });
    } catch (e) {
      _errorHandler.handleError(e);
      return Stream.value([]);
    }
  }

  // Post'u beğen/beğenmekten vazgeç
  Future<void> toggleLike(String postId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturum açmamış');

      final postRef = _firestore.collection('posts').doc(postId);
      final post = await postRef.get();

      if (!post.exists) throw Exception('Post bulunamadı');

      final likes = List<String>.from(post.data()!['likes'] ?? []);

      if (likes.contains(user.uid)) {
        await postRef.update({
          'likes': FieldValue.arrayRemove([user.uid]),
        });
      } else {
        await postRef.update({
          'likes': FieldValue.arrayUnion([user.uid]),
        });
      }
    } catch (e) {
      _errorHandler.handleError(e);
    }
  }

  // Post'u sil
  Future<void> deletePost(String postId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturum açmamış');

      final postRef = _firestore.collection('posts').doc(postId);
      final post = await postRef.get();

      if (!post.exists) throw Exception('Post bulunamadı');
      if (post.data()!['userId'] != user.uid) {
        throw Exception('Bu postu silme yetkiniz yok');
      }

      // Post'un resimlerini sil
      final images = List<String>.from(post.data()!['images'] ?? []);
      await Future.wait(
        images.map((url) => _imageUploadService.deleteImage(url)),
      );

      // Post'u sil
      await postRef.delete();
    } catch (e) {
      _errorHandler.handleError(e);
    }
  }

  // Post'u güncelle
  Future<Post?> updatePost({
    required String postId,
    String? content,
    List<String>? newImagePaths,
    List<String>? deleteImageUrls,
    String? githubRepoUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturum açmamış');

      final postRef = _firestore.collection('posts').doc(postId);
      final post = await postRef.get();

      if (!post.exists) throw Exception('Post bulunamadı');
      if (post.data()!['userId'] != user.uid) {
        throw Exception('Bu postu düzenleme yetkiniz yok');
      }

      final updateData = <String, dynamic>{};

      // İçerik güncelleme
      if (content != null) {
        updateData['content'] = content;
      }

      // GitHub repo URL güncelleme
      if (githubRepoUrl != null) {
        updateData['githubRepoUrl'] = githubRepoUrl;
      }

      // Metadata güncelleme
      if (metadata != null) {
        updateData['metadata'] = metadata;
      }

      // Resim işlemleri
      if (deleteImageUrls != null && deleteImageUrls.isNotEmpty) {
        // Silinecek resimleri storage'dan kaldır
        await Future.wait(
          deleteImageUrls.map((url) => _imageUploadService.deleteImage(url)),
        );
        updateData['images'] = FieldValue.arrayRemove(deleteImageUrls);
      }

      if (newImagePaths != null && newImagePaths.isNotEmpty) {
        // Yeni resimleri yükle
        final uploadedImages = await Future.wait(
          newImagePaths.map((path) => _imageUploadService.uploadImage(path)),
        );
        updateData['images'] = FieldValue.arrayUnion(
          uploadedImages.whereType<String>().toList(),
        );
      }

      // Post'u güncelle
      await postRef.update(updateData);

      // Güncellenmiş post'u getir
      final updatedDoc = await postRef.get();
      return Post.fromJson({
        ...updatedDoc.data()!,
        'id': updatedDoc.id,
      });
    } catch (e) {
      _errorHandler.handleError(e);
      return null;
    }
  }
}
