import 'package:get/get.dart';
import '../models/user_profile_model.dart';
import '../models/blog_model.dart';
import '../models/community/community_model.dart';
import '../models/event/event_model.dart';
import '../services/recommendation_service.dart';
import '../core/services/error_handler_service.dart';

class RecommendationController extends GetxController {
  final RecommendationService _recommendationService =
      Get.find<RecommendationService>();
  final ErrorHandlerService _errorHandler = Get.find<ErrorHandlerService>();

  // State Management
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Recommendations
  final RxList<UserProfile> userRecommendations = <UserProfile>[].obs;
  final RxList<BlogModel> blogRecommendations = <BlogModel>[].obs;
  final RxList<CommunityModel> communityRecommendations =
      <CommunityModel>[].obs;
  final RxList<EventModel> eventRecommendations = <EventModel>[].obs;

  // Refresh indicators
  final RxBool isRefreshingUsers = false.obs;
  final RxBool isRefreshingBlogs = false.obs;
  final RxBool isRefreshingCommunities = false.obs;
  final RxBool isRefreshingEvents = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllRecommendations();
  }

  // Tüm önerileri yükle
  Future<void> loadAllRecommendations() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await Future.wait([
        loadUserRecommendations(),
        loadBlogRecommendations(),
        loadCommunityRecommendations(),
        loadEventRecommendations(),
      ]);
    } catch (e) {
      errorMessage.value = 'Öneriler yüklenirken hata oluştu';
      _errorHandler.handleError(
        'Öneriler yükleme hatası: $e',
        'RECOMMENDATIONS_LOAD_ERROR',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Kullanıcı önerileri yükle
  Future<void> loadUserRecommendations({bool refresh = false}) async {
    if (refresh) isRefreshingUsers.value = true;

    try {
      final recommendations = await _recommendationService
          .getUserRecommendations(limit: 15);
      userRecommendations.value = recommendations;
    } catch (e) {
      if (!refresh) {
        errorMessage.value = 'Kullanıcı önerileri yüklenemedi';
      }
      _errorHandler.handleError(
        'Kullanıcı önerileri hatası: $e',
        'USER_RECOMMENDATIONS_ERROR',
      );
    } finally {
      if (refresh) isRefreshingUsers.value = false;
    }
  }

  // Blog önerileri yükle
  Future<void> loadBlogRecommendations({bool refresh = false}) async {
    if (refresh) isRefreshingBlogs.value = true;

    try {
      final recommendations = await _recommendationService
          .getBlogRecommendations(limit: 20);
      blogRecommendations.value = recommendations;
    } catch (e) {
      if (!refresh) {
        errorMessage.value = 'Blog önerileri yüklenemedi';
      }
      _errorHandler.handleError(
        'Blog önerileri hatası: $e',
        'BLOG_RECOMMENDATIONS_ERROR',
      );
    } finally {
      if (refresh) isRefreshingBlogs.value = false;
    }
  }

  // Topluluk önerileri yükle
  Future<void> loadCommunityRecommendations({bool refresh = false}) async {
    if (refresh) isRefreshingCommunities.value = true;

    try {
      final recommendations = await _recommendationService
          .getCommunityRecommendations(limit: 12);
      communityRecommendations.value = recommendations;
    } catch (e) {
      if (!refresh) {
        errorMessage.value = 'Topluluk önerileri yüklenemedi';
      }
      _errorHandler.handleError(
        'Topluluk önerileri hatası: $e',
        'COMMUNITY_RECOMMENDATIONS_ERROR',
      );
    } finally {
      if (refresh) isRefreshingCommunities.value = false;
    }
  }

  // Etkinlik önerileri yükle
  Future<void> loadEventRecommendations({bool refresh = false}) async {
    if (refresh) isRefreshingEvents.value = true;

    try {
      final recommendations = await _recommendationService
          .getEventRecommendations(limit: 15);
      eventRecommendations.value = recommendations;
    } catch (e) {
      if (!refresh) {
        errorMessage.value = 'Etkinlik önerileri yüklenemedi';
      }
      _errorHandler.handleError(
        'Etkinlik önerileri hatası: $e',
        'EVENT_RECOMMENDATIONS_ERROR',
      );
    } finally {
      if (refresh) isRefreshingEvents.value = false;
    }
  }

  // Yenile işlemleri
  Future<void> refreshUserRecommendations() async {
    await loadUserRecommendations(refresh: true);
  }

  Future<void> refreshBlogRecommendations() async {
    await loadBlogRecommendations(refresh: true);
  }

  Future<void> refreshCommunityRecommendations() async {
    await loadCommunityRecommendations(refresh: true);
  }

  Future<void> refreshEventRecommendations() async {
    await loadEventRecommendations(refresh: true);
  }

  Future<void> refreshAllRecommendations() async {
    await Future.wait([
      refreshUserRecommendations(),
      refreshBlogRecommendations(),
      refreshCommunityRecommendations(),
      refreshEventRecommendations(),
    ]);
  }

  // Öneri kaldırma
  void dismissUserRecommendation(String userId) {
    userRecommendations.removeWhere((user) => user.id == userId);
  }

  void dismissBlogRecommendation(String blogId) {
    blogRecommendations.removeWhere((blog) => blog.id == blogId);
  }

  void dismissCommunityRecommendation(String communityId) {
    communityRecommendations.removeWhere(
      (community) => community.id == communityId,
    );
  }

  void dismissEventRecommendation(String eventId) {
    eventRecommendations.removeWhere((event) => event.id == eventId);
  }

  // Öneri detayına git
  void goToUserProfile(String userId) {
    Get.toNamed('/profile', arguments: userId);
  }

  void goToBlogDetail(String blogId) {
    Get.toNamed('/blog-detail', arguments: blogId);
  }

  void goToCommunityDetail(String communityId) {
    Get.toNamed('/community-detail', arguments: communityId);
  }

  void goToEventDetail(String eventId) {
    Get.toNamed('/event-details', arguments: eventId);
  }

  // Getters
  bool get hasUserRecommendations => userRecommendations.isNotEmpty;
  bool get hasBlogRecommendations => blogRecommendations.isNotEmpty;
  bool get hasCommunityRecommendations => communityRecommendations.isNotEmpty;
  bool get hasEventRecommendations => eventRecommendations.isNotEmpty;
  bool get hasAnyRecommendations =>
      hasUserRecommendations ||
      hasBlogRecommendations ||
      hasCommunityRecommendations ||
      hasEventRecommendations;

  int get totalRecommendations =>
      userRecommendations.length +
      blogRecommendations.length +
      communityRecommendations.length +
      eventRecommendations.length;
}
