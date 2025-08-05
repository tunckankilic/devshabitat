import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/community/community_model.dart';
import '../../models/community/content_model.dart';
import '../../services/community/content_moderation_service.dart';
import '../../core/base/base_community_controller.dart';
import '../../repositories/auth_repository.dart';

class CommunityContentController extends BaseCommunityController {
  final ContentModerationService _moderationService =
      Get.find<ContentModerationService>();
  final AuthRepository _authService = Get.find<AuthRepository>();

  final contentItems = <CommunityContentModel>[].obs;
  final isLoadingMore = false.obs;
  final hasMoreContent = true.obs;
  final selectedContentType = Rx<ContentType?>(null);

  DocumentSnapshot? _lastDocument;
  static const int _pageSize = 20;

  String? communityId;

  @override
  void onInit() {
    super.onInit();
    communityId = Get.arguments as String;
    ever(selectedContentType, (_) => loadInitialContent());
    loadInitialContent();
  }

  Future<void> loadInitialContent() async {
    await handleAsync(
      operation: () async {
        final snapshot = await _moderationService.getApprovedContent(
          communityId: communityId!,
          limit: _pageSize,
          contentType: selectedContentType.value,
        );

        if (snapshot.docs.isNotEmpty) {
          _lastDocument = snapshot.docs.last;
          contentItems.value = snapshot.docs
              .map((doc) => CommunityContentModel.fromFirestore(doc))
              .toList();
          hasMoreContent.value = snapshot.docs.length == _pageSize;
        } else {
          hasMoreContent.value = false;
        }
      },
      successMessage: 'İçerikler yüklendi',
    );
  }

  Future<void> loadMoreContent() async {
    if (isLoadingMore.value || !hasMoreContent.value) return;

    isLoadingMore.value = true;

    try {
      final snapshot = await _moderationService.getApprovedContent(
        communityId: communityId!,
        limit: _pageSize,
        startAfter: _lastDocument,
        contentType: selectedContentType.value,
      );

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        contentItems.addAll(
          snapshot.docs.map((doc) => CommunityContentModel.fromFirestore(doc)),
        );
        hasMoreContent.value = snapshot.docs.length == _pageSize;
      } else {
        hasMoreContent.value = false;
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> submitContent({
    required String title,
    required String content,
    required ContentType type,
    String? url,
    String? githubRepo,
  }) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      setError('Oturum açmanız gerekmektedir');
      return;
    }

    await handleAsync(
      operation: () async {
        final newContent = CommunityContentModel(
          id: '',
          communityId: communityId!,
          authorId: userId,
          title: title,
          content: content,
          type: type,
          url: url,
          githubRepo: githubRepo,
          createdAt: DateTime.now(),
          status: ContentStatus.pending,
        );

        await _moderationService.submitContent(newContent);
      },
      successMessage: 'İçerik başarıyla gönderildi ve onay için bekliyor',
    );
  }

  Future<void> likeContent(String contentId) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      setError('Oturum açmanız gerekmektedir');
      return;
    }

    await handleAsync(
      operation: () async {
        await _moderationService.likeContent(
          contentId: contentId,
          userId: userId,
        );

        // Yerel state'i güncelle
        final index = contentItems.indexWhere((item) => item.id == contentId);
        if (index != -1) {
          final updatedContent = contentItems[index].copyWith(
            likedBy: [...contentItems[index].likedBy, userId],
          );
          contentItems[index] = updatedContent;
        }
      },
      showLoading: false,
    );
  }

  Future<void> unlikeContent(String contentId) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      setError('Oturum açmanız gerekmektedir');
      return;
    }

    await handleAsync(
      operation: () async {
        await _moderationService.unlikeContent(
          contentId: contentId,
          userId: userId,
        );

        // Yerel state'i güncelle
        final index = contentItems.indexWhere((item) => item.id == contentId);
        if (index != -1) {
          final updatedContent = contentItems[index].copyWith(
            likedBy: contentItems[index].likedBy
                .where((id) => id != userId)
                .toList(),
          );
          contentItems[index] = updatedContent;
        }
      },
      showLoading: false,
    );
  }

  Future<void> deleteContent(String contentId) async {
    await handleAsync(
      operation: () async {
        await _moderationService.deleteContent(contentId);
        contentItems.removeWhere((item) => item.id == contentId);
      },
      successMessage: 'İçerik silindi',
    );
  }

  bool canModerateContent() {
    return Get.find<CommunityModel>().isModerator(
      _authService.currentUser?.uid ?? '',
    );
  }

  Future<void> reportContent(String contentId, String reason) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      setError('Oturum açmanız gerekmektedir');
      return;
    }

    await handleAsync(
      operation: () => _moderationService.reportContent(
        contentId: contentId,
        reporterId: userId,
        reason: reason,
      ),
      successMessage: 'İçerik başarıyla raporlandı',
    );
  }
}
