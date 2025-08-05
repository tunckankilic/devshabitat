import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/comment_model.dart';
import '../services/comment_service.dart';
import '../core/services/error_handler_service.dart';
import '../repositories/auth_repository.dart';

class CommentsController extends GetxController {
  final CommentService _commentService = Get.find<CommentService>();
  final ErrorHandlerService _errorHandler = Get.find<ErrorHandlerService>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  // Form Controllers
  late TextEditingController commentController;
  late ScrollController scrollController;

  // State Management
  final RxBool isLoading = false.obs;
  final RxBool isAddingComment = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString postId = ''.obs;

  // Comments Data
  final RxList<CommentModel> comments = <CommentModel>[].obs;
  final RxList<String> likedComments = <String>[].obs;
  final Rx<CommentModel?> replyingTo = Rx<CommentModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  void _initializeControllers() {
    commentController = TextEditingController();
    scrollController = ScrollController();
  }

  void _disposeControllers() {
    commentController.dispose();
    scrollController.dispose();
  }

  // Post ID'yi ayarla ve yorumları yükle
  void setPostId(String id) {
    postId.value = id;
    loadComments();
  }

  // Yorumları yükle
  Future<void> loadComments() async {
    if (postId.value.isEmpty) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final commentList = await _commentService.getComments(postId.value);
      comments.value = commentList;
    } catch (e) {
      errorMessage.value = 'Yorumlar yüklenemedi';
      _errorHandler.handleError('Yorum yükleme hatası: $e', 'COMMENT_LOAD_ERROR');
    } finally {
      isLoading.value = false;
    }
  }

  // Yorum ekleme
  Future<void> addComment() async {
    final content = commentController.text.trim();
    if (content.isEmpty || postId.value.isEmpty) return;

    isAddingComment.value = true;
    
    try {
      final commentId = await _commentService.addComment(
        postId: postId.value,
        content: content,
        parentCommentId: replyingTo.value?.id,
      );

      if (commentId != null) {
        commentController.clear();
        replyingTo.value = null;
        await loadComments(); // Yorumları yenile
        _scrollToBottom();
        
        Get.snackbar(
          'Başarılı',
          'Yorum eklendi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
      }
    } catch (e) {
      errorMessage.value = 'Yorum eklenemedi';
      _errorHandler.handleError('Yorum ekleme hatası: $e', 'COMMENT_ADD_ERROR');
    } finally {
      isAddingComment.value = false;
    }
  }

  // Yorum beğeni/beğenmeme
  Future<void> toggleLike(String commentId) async {
    try {
      final isLiked = await _commentService.toggleLike(commentId);
      
      if (isLiked) {
        likedComments.add(commentId);
      } else {
        likedComments.remove(commentId);
      }
      
      // Yorumları yenile
      await loadComments();
    } catch (e) {
      errorMessage.value = 'Beğeni işlemi başarısız';
      _errorHandler.handleError('Beğeni hatası: $e', 'COMMENT_LIKE_ERROR');
    }
  }

  // Yorum düzenleme
  Future<void> editComment(String commentId, String newContent) async {
    if (newContent.trim().isEmpty) return;

    try {
      final success = await _commentService.editComment(commentId, newContent.trim());
      
      if (success) {
        await loadComments(); // Yorumları yenile
        
        Get.snackbar(
          'Başarılı',
          'Yorum düzenlendi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
      }
    } catch (e) {
      errorMessage.value = 'Yorum düzenlenemedi';
      _errorHandler.handleError('Yorum düzenleme hatası: $e', 'COMMENT_EDIT_ERROR');
    }
  }

  // Yorum silme
  Future<void> deleteComment(String commentId) async {
    try {
      final success = await _commentService.deleteComment(commentId, postId.value);
      
      if (success) {
        await loadComments(); // Yorumları yenile
        
        Get.snackbar(
          'Başarılı',
          'Yorum silindi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
      }
    } catch (e) {
      errorMessage.value = 'Yorum silinemedi';
      _errorHandler.handleError('Yorum silme hatası: $e', 'COMMENT_DELETE_ERROR');
    }
  }

  // Yanıtla işlemi
  void setReplyTo(CommentModel comment) {
    replyingTo.value = comment;
    commentController.text = '@${comment.authorName} ';
    // Input'a focus ver
  }

  // Yanıtlamayı iptal et
  void cancelReply() {
    replyingTo.value = null;
    commentController.clear();
  }

  // En alta kaydır
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Yorum beğenildi mi kontrol et
  bool isCommentLiked(String commentId) {
    return likedComments.contains(commentId);
  }

  // Kullanıcı yorumu düzenleyebilir mi
  bool canEditComment(CommentModel comment) {
    final currentUser = _authRepository.currentUser;
    return currentUser != null && currentUser.uid == comment.authorId;
  }

  // Getters
  bool get hasComments => comments.isNotEmpty;
  bool get isReplying => replyingTo.value != null;
  String get replyingToName => replyingTo.value?.authorName ?? '';
}