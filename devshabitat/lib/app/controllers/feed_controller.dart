// ignore_for_file: avoid_print

import 'package:devshabitat/app/core/services/error_handler_service.dart';
import 'package:get/get.dart';
import '../models/feed_item.dart';
import '../repositories/feed_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedController extends GetxController {
  final FeedRepository _repository;
  final ErrorHandlerService _errorHandler;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  FeedController({
    required FeedRepository repository,
    required ErrorHandlerService errorHandler,
  }) : _repository = repository,
       _errorHandler = errorHandler;

  final RxList<FeedItem> _feedItems = <FeedItem>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;
  final RxInt _currentPage = 1.obs;

  List<FeedItem> get feedItems => _feedItems;
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    refreshFeed();
  }

  Future<List<FeedItem>> fetchFeedItems(int page, int pageSize) async {
    try {
      final items = await _repository.getFeedItems(
        page: page,
        pageSize: pageSize,
      );
      return items;
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.SERVER_ERROR);
      return [];
    }
  }

  Future<void> refreshFeed() async {
    _currentPage.value = 1;
    _feedItems.clear();
    try {
      final items = await fetchFeedItems(_currentPage.value, 10);
      _feedItems.addAll(items);
      _hasError.value = false;
    } catch (e) {
      _hasError.value = true;
      _errorHandler.handleError(e, ErrorHandlerService.SERVER_ERROR);
    }
  }

  Future<void> likeFeedItem(String itemId) async {
    try {
      await _repository.likeFeedItem(itemId);
      final index = _feedItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        final updatedItem = _feedItems[index].copyWith(
          likesCount: _feedItems[index].likesCount + 1,
          isLiked: true,
        );
        _feedItems[index] = updatedItem;
      }
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.SERVER_ERROR);
    }
  }

  Future<void> commentOnFeedItem(String itemId) async {
    try {
      // Yorum yapma işlemi
      Get.toNamed('/comments', arguments: itemId);
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.SERVER_ERROR);
    }
  }

  Future<void> shareFeedItem(String itemId) async {
    try {
      await _repository.shareFeedItem(itemId);
      final index = _feedItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        final updatedItem = _feedItems[index].copyWith(
          sharesCount: _feedItems[index].sharesCount + 1,
        );
        _feedItems[index] = updatedItem;
      }
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.SERVER_ERROR);
    }
  }

  Future<void> toggleLike(String postId) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final post = await postRef.get();
      final likes = List<String>.from(post.data()?['likes'] ?? []);

      if (likes.contains(currentUserId)) {
        likes.remove(currentUserId);
      } else {
        likes.add(currentUserId);
      }

      await postRef.update({'likes': likes});
    } catch (e) {
      print('Beğeni işlemi başarısız: $e');
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
      Get.snackbar('Başarılı', 'Gönderi silindi');
    } catch (e) {
      print('Gönderi silme başarısız: $e');
      Get.snackbar('Hata', 'Gönderi silinemedi');
    }
  }

  Future<void> reportPost(String postId) async {
    try {
      await _firestore.collection('reports').add({
        'postId': postId,
        'reportedBy': currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      Get.snackbar('Başarılı', 'Gönderi şikayet edildi');
    } catch (e) {
      print('Şikayet işlemi başarısız: $e');
      Get.snackbar('Hata', 'Şikayet gönderilemedi');
    }
  }
}
