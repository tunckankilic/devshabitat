import 'package:get/get.dart';
import '../services/blog_social_service.dart';
import '../services/blog_notification_service.dart';
import '../services/blog_management_service.dart';
import '../models/blog_interaction_model.dart';
import '../repositories/auth_repository.dart';

class BlogSocialController extends GetxController {
  final _socialService = Get.find<BlogSocialService>();
  final _notificationService = Get.find<BlogNotificationService>();
  final _blogService = Get.find<BlogManagementService>();
  final _authRepo = Get.find<AuthRepository>();

  // Reaktif değişkenler
  final comments = <BlogCommentModel>[].obs;
  final isLoadingComments = false.obs;
  final selectedComment = Rx<BlogCommentModel?>(null);
  final userReadingLists = <UserReadingListModel>[].obs;
  final recommendedBlogs = <String>[].obs;
  final isProcessing = false.obs;

  // Blog etkileşimleri
  Future<void> toggleBlogReaction(String blogId, String type) async {
    try {
      isProcessing.value = true;
      await _socialService.toggleBlogReaction(blogId, type);

      if (type == 'like') {
        // Beğeni bildirimi gönder
        final currentUser = _authRepo.currentUser;
        if (currentUser != null) {
          final blog = await _blogService.getBlogById(blogId);
          await _notificationService.sendLikeNotification(
            blogId: blogId,
            blogTitle: blog?.title ?? '',
            likerId: currentUser.uid,
            likerName: currentUser.displayName ?? 'Anonim',
            authorId: blog?.authorId ?? '',
          );
        }
      }
    } finally {
      isProcessing.value = false;
    }
  }

  // Yorum ekleme
  Future<void> addComment({
    required String blogId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      isProcessing.value = true;
      final comment = await _socialService.addComment(
        blogId: blogId,
        content: content,
        parentCommentId: parentCommentId,
      );

      if (parentCommentId == null) {
        comments.add(comment);
      } else {
        // Alt yorumu ekle
        final parentIndex = comments.indexWhere((c) => c.id == parentCommentId);
        if (parentIndex != -1) {
          final parent = comments[parentIndex];
          comments[parentIndex] = BlogCommentModel(
            id: parent.id,
            blogId: parent.blogId,
            userId: parent.userId,
            userName: parent.userName,
            userPhotoUrl: parent.userPhotoUrl,
            content: parent.content,
            createdAt: parent.createdAt,
            replies: [...parent.replies, comment.id],
          );
        }
      }

      // Yorum bildirimi gönder
      final currentUser = _authRepo.currentUser;
      if (currentUser != null) {
        final blog = await _blogService.getBlogById(blogId);
        await _notificationService.sendCommentNotification(
          blogId: blogId,
          blogTitle: blog?.title ?? '',
          commenterId: currentUser.uid,
          commenterName: currentUser.displayName ?? 'Anonim',
          authorId: blog?.authorId ?? '',
        );
      }
    } finally {
      isProcessing.value = false;
    }
  }

  // Blog paylaşma
  Future<void> shareBlog(String blogId, String title, String url) async {
    await _socialService.shareBlog(blogId, title, url);
  }

  // Yazar takip etme
  Future<void> toggleFollowAuthor(String authorId) async {
    try {
      isProcessing.value = true;
      await _socialService.toggleFollowAuthor(authorId);

      // Takip bildirimi gönder
      final currentUser = _authRepo.currentUser;
      if (currentUser != null) {
        await _notificationService.sendFollowNotification(
          followerId: currentUser.uid,
          followerName: currentUser.displayName ?? 'Anonim',
          authorId: authorId,
        );
      }
    } finally {
      isProcessing.value = false;
    }
  }

  // Okuma listesi oluşturma
  Future<void> createReadingList({
    required String title,
    String? description,
    bool isPublic = false,
  }) async {
    try {
      isProcessing.value = true;
      final readingList = await _socialService.createReadingList(
        title: title,
        description: description,
        isPublic: isPublic,
      );
      userReadingLists.add(readingList);
    } finally {
      isProcessing.value = false;
    }
  }

  // Okuma listesine blog ekleme/çıkarma
  Future<void> toggleBlogInReadingList(
    String readingListId,
    String blogId,
  ) async {
    try {
      isProcessing.value = true;
      await _socialService.toggleBlogInReadingList(readingListId, blogId);

      // Okuma listelerini güncelle
      final index = userReadingLists.indexWhere(
        (list) => list.id == readingListId,
      );
      if (index != -1) {
        final list = userReadingLists[index];
        final updatedBlogIds = List<String>.from(list.blogIds);

        if (updatedBlogIds.contains(blogId)) {
          updatedBlogIds.remove(blogId);
        } else {
          updatedBlogIds.add(blogId);
        }

        userReadingLists[index] = UserReadingListModel(
          id: list.id,
          userId: list.userId,
          title: list.title,
          description: list.description,
          blogIds: updatedBlogIds,
          isPublic: list.isPublic,
          createdAt: list.createdAt,
          updatedAt: DateTime.now(),
        );
      }
    } finally {
      isProcessing.value = false;
    }
  }

  // Blog önerilerini yükle
  Future<void> loadRecommendedBlogs() async {
    try {
      final currentUser = _authRepo.currentUser;
      if (currentUser == null) return;

      final recommendations = await _socialService.getRecommendedBlogs(
        currentUser.uid,
      );
      recommendedBlogs.value = recommendations;
    } catch (e) {
      print('Blog önerileri yüklenirken hata: $e');
    }
  }

  // Okuma süresi takibi
  Future<void> trackReadingTime(String blogId, Duration readingTime) async {
    await _socialService.trackReadingTime(blogId, readingTime);
  }

  @override
  void onInit() {
    super.onInit();
    loadRecommendedBlogs();
  }
}
