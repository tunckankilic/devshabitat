// ignore_for_file: unused_field

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/post.dart';
import 'image_upload_service.dart';
import '../core/services/error_handler_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:logger/logger.dart';

class PostService extends GetxService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ImageUploadService _imageUploadService;
  final ErrorHandlerService _errorHandler;
  final Logger _logger;

  // Önbellekleme için değişkenler
  final Map<String, Post> _postCache = {};
  final Map<String, List<Post>> _userPostsCache = {};
  final Duration _cacheDuration = const Duration(minutes: 15);
  final Map<String, DateTime> _cacheTimestamps = {};
  final BehaviorSubject<List<Post>> _postsController =
      BehaviorSubject<List<Post>>();

  // Timer for cache cleanup
  Timer? _cleanupTimer;

  PostService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    ImageUploadService? imageUploadService,
    ErrorHandlerService? errorHandler,
    Logger? logger,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _imageUploadService = imageUploadService ?? Get.find(),
        _errorHandler = errorHandler ?? Get.find(),
        _logger = logger ?? Get.find();

  @override
  void onInit() {
    super.onInit();
    _startCleanupTimer();
  }

  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      _cleanupCache();
    });
  }

  void _cleanupCache() {
    final now = DateTime.now();
    _cacheTimestamps.removeWhere((key, timestamp) {
      final isExpired = now.difference(timestamp) > _cacheDuration;
      if (isExpired) {
        _postCache.remove(key);
        _userPostsCache.remove(key);
      }
      return isExpired;
    });
  }

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

      // Resimleri paralel olarak yükle
      final uploadedImages = await Future.wait(
        imagePaths.map((path) => _imageUploadService.uploadImage(
              path,
              shouldCompress: true,
              generateThumbnail: true,
            )),
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

      final post = Post.fromJson({
        ...doc.data()!,
        'id': doc.id,
        'createdAt': doc.data()!['createdAt'] ?? Timestamp.now(),
      });

      // Önbelleğe ekle
      _addToCache(post);

      return post;
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
      return null;
    }
  }

  void _addToCache(Post post) {
    _postCache[post.id] = post;
    _cacheTimestamps[post.id] = DateTime.now();

    // Kullanıcı postları önbelleğini güncelle
    final userPosts = _userPostsCache[post.userId] ?? [];
    userPosts.insert(0, post);
    _userPostsCache[post.userId] = userPosts;
    _cacheTimestamps[post.userId] = DateTime.now();

    // Stream'i güncelle
    final currentPosts = _postsController.valueOrNull ?? [];
    currentPosts.insert(0, post);
    _postsController.add(currentPosts);
  }

  // Post'ları getir
  Stream<List<Post>> getPosts({String? userId}) {
    try {
      // Önbellekten kontrol et
      if (userId != null && _isCacheValid(userId)) {
        final cachedPosts = _userPostsCache[userId];
        if (cachedPosts != null) {
          return Stream.value(cachedPosts);
        }
      }

      var query = _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(20); // Pagination için limit

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      return query.snapshots().map((snapshot) {
        final posts = snapshot.docs.map((doc) {
          final post = Post.fromJson({
            ...doc.data(),
            'id': doc.id,
          });

          // Önbelleğe ekle
          _postCache[post.id] = post;
          _cacheTimestamps[post.id] = DateTime.now();

          return post;
        }).toList();

        // Kullanıcı postları önbelleğini güncelle
        if (userId != null) {
          _userPostsCache[userId] = posts;
          _cacheTimestamps[userId] = DateTime.now();
        }

        return posts;
      });
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
      return Stream.value([]);
    }
  }

  bool _isCacheValid(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) <= _cacheDuration;
  }

  // Post'u beğen/beğenmekten vazgeç
  Future<void> toggleLike(String postId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturum açmamış');

      final postRef = _firestore.collection('posts').doc(postId);

      // Optimistik güncelleme
      final cachedPost = _postCache[postId];
      if (cachedPost != null) {
        final likes = List<String>.from(cachedPost.likes);
        if (likes.contains(user.uid)) {
          likes.remove(user.uid);
        } else {
          likes.add(user.uid);
        }

        final updatedPost = cachedPost.copyWith(likes: likes);
        _addToCache(updatedPost);
      }

      // Firestore'da güncelle
      await _firestore.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);
        if (!postDoc.exists) throw Exception('Post bulunamadı');

        final likes = List<String>.from(postDoc.data()!['likes'] ?? []);
        if (likes.contains(user.uid)) {
          likes.remove(user.uid);
        } else {
          likes.add(user.uid);
        }

        transaction.update(postRef, {'likes': likes});
      });
    } catch (e) {
      // Hata durumunda önbelleği geri al
      if (_postCache.containsKey(postId)) {
        _postCache.remove(postId);
        _cacheTimestamps.remove(postId);
      }
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
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

      // Önbellekten sil
      _postCache.remove(postId);
      _cacheTimestamps.remove(postId);

      if (_userPostsCache.containsKey(user.uid)) {
        _userPostsCache[user.uid]?.removeWhere((p) => p.id == postId);
      }

      // Post'un resimlerini sil
      final images = List<String>.from(post.data()!['images'] ?? []);
      await Future.wait(
        images.map((url) => _imageUploadService.deleteImage(url)),
      );

      // Post'u sil
      await postRef.delete();

      // Stream'i güncelle
      final currentPosts = _postsController.valueOrNull ?? [];
      currentPosts.removeWhere((p) => p.id == postId);
      _postsController.add(currentPosts);
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
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
        // Yeni resimleri paralel olarak yükle
        final uploadedImages = await Future.wait(
          newImagePaths.map((path) => _imageUploadService.uploadImage(
                path,
                shouldCompress: true,
                generateThumbnail: true,
              )),
        );
        updateData['images'] = FieldValue.arrayUnion(
          uploadedImages.whereType<String>().toList(),
        );
      }

      // Post'u güncelle
      await postRef.update(updateData);

      // Güncellenmiş post'u getir
      final updatedDoc = await postRef.get();
      final updatedPost = Post.fromJson({
        ...updatedDoc.data()!,
        'id': updatedDoc.id,
      });

      // Önbelleği güncelle
      _addToCache(updatedPost);

      return updatedPost;
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
      return null;
    }
  }

  @override
  void onClose() {
    _cleanupTimer?.cancel();
    _postsController.close();
    _postCache.clear();
    _userPostsCache.clear();
    _cacheTimestamps.clear();
    super.onClose();
  }
}
