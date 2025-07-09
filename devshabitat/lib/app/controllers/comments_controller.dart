import 'package:get/get.dart';
import '../models/comment_model.dart';
import '../models/feed_item.dart';
import '../services/feed_service.dart';
import '../core/services/error_handler_service.dart';
import '../controllers/auth_controller.dart';

class CommentsController extends GetxController {
  final FeedService _feedService = Get.find();
  final ErrorHandlerService _errorHandler = Get.find();

  final RxList<CommentModel> comments = <CommentModel>[].obs;
  final Rx<FeedItem?> currentFeedItem = Rx<FeedItem?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool isAddingComment = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Route'dan gelen feed item'ı al
    final arguments = Get.arguments;
    if (arguments is FeedItem) {
      currentFeedItem.value = arguments;
      loadComments();
    }
  }

  Future<void> loadComments() async {
    try {
      isLoading.value = true;
      error.value = '';

      final feedItem = currentFeedItem.value;
      if (feedItem == null) {
        error.value = 'Feed öğesi bulunamadı';
        return;
      }

      final commentsData = await _feedService.getComments(feedItem.id);
      final commentModels = commentsData.map((data) {
        return CommentModel.fromMap({
          ...data,
          'feedItemId': feedItem.id,
        });
      }).toList();

      comments.assignAll(commentModels);
    } catch (e) {
      error.value = 'Yorumlar yüklenirken bir hata oluştu: $e';
      _errorHandler.handleError(e, ErrorHandlerService.SERVER_ERROR);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addComment(String commentText) async {
    try {
      isAddingComment.value = true;
      error.value = '';

      final feedItem = currentFeedItem.value;
      if (feedItem == null) {
        error.value = 'Feed öğesi bulunamadı';
        return;
      }

      if (commentText.trim().isEmpty) {
        error.value = 'Yorum boş olamaz';
        return;
      }

      await _feedService.addComment(feedItem.id, commentText.trim());

      // Yorumları yenile
      await loadComments();

      Get.snackbar(
        'Başarılı',
        'Yorum başarıyla eklendi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Yorum eklenirken bir hata oluştu: $e';
      _errorHandler.handleError(e, ErrorHandlerService.SERVER_ERROR);
    } finally {
      isAddingComment.value = false;
    }
  }

  Future<void> likeComment(String commentId) async {
    try {
      final feedItem = currentFeedItem.value;
      if (feedItem == null) {
        error.value = 'Feed öğesi bulunamadı';
        return;
      }

      await _feedService.likeComment(feedItem.id, commentId);

      // Yorumları yenile
      await loadComments();
    } catch (e) {
      error.value = 'Yorum beğenilirken bir hata oluştu: $e';
      _errorHandler.handleError(e, ErrorHandlerService.SERVER_ERROR);
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      final feedItem = currentFeedItem.value;
      if (feedItem == null) {
        error.value = 'Feed öğesi bulunamadı';
        return;
      }

      await _feedService.deleteComment(feedItem.id, commentId);

      // Yorumları yenile
      await loadComments();

      Get.snackbar(
        'Başarılı',
        'Yorum başarıyla silindi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Yorum silinirken bir hata oluştu: $e';
      _errorHandler.handleError(e, ErrorHandlerService.SERVER_ERROR);
    }
  }

  void refreshComments() {
    loadComments();
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  String? get currentUserId {
    return Get.find<AuthController>().currentUser?.uid;
  }
}
