import 'package:get/get.dart';
import '../services/github_service.dart';
import '../repositories/auth_repository.dart';
import '../core/services/snackbar_service.dart';
import '../models/feed_item.dart';
import '../repositories/feed_repository.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class HomeController extends GetxController {
  final _authRepository = Get.find<AuthRepository>();
  final _githubService = Get.find<GithubService>();
  final _notificationService = Get.find<NotificationService>();
  final FeedRepository _feedRepository;

  final RxBool isLoading = false.obs;
  final RxList activityFeed = [].obs;
  final RxMap githubStats = {}.obs;
  final RxInt connectionCount = 0.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<FeedItem> items = <FeedItem>[].obs;
  final Rx<FeedItem?> selectedFeedItem = Rx<FeedItem?>(null);
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  HomeController({
    required FeedRepository feedRepository,
  }) : _feedRepository = feedRepository;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
    loadData();
    getNotifications();
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;

      // GitHub istatistiklerini yükle
      final username = _authRepository.currentUser?.providerData
              .firstWhereOrNull((info) => info.providerId == 'github.com')
              ?.displayName ??
          '';
      final stats = await _githubService.getGithubStats(username);
      githubStats.value = stats.toJson();

      // Aktivite akışını yükle
      final activities = await _githubService.getUserActivities(username);
      activityFeed.value = activities;

      // Bağlantı sayısını yükle
      final connections = await _authRepository.getUserConnections();
      connectionCount.value = connections.length;
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Veriler yüklenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadDashboardData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      items.value = await _feedRepository.getFeedItems();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Veriler yüklenirken bir hata oluştu';
      SnackbarService.showError('Veriler yüklenemedi');
    } finally {
      isLoading.value = false;
    }
  }

  void onItemTap(FeedItem item) {
    selectedFeedItem.value = item;
    Get.toNamed('/feed/detail', arguments: item);
  }

  void onLike(FeedItem item) async {
    try {
      await _feedRepository.likeFeedItem(item.id);
      final index = items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        items[index] = item.copyWith(
          likesCount: item.likesCount + 1,
          isLiked: true,
        );
      }
    } catch (e) {
      Get.snackbar('Hata', 'Beğeni işlemi başarısız oldu');
    }
  }

  void onComment(FeedItem item) {
    Get.toNamed('/comments', arguments: item);
  }

  void onShare(FeedItem item) async {
    try {
      await _feedRepository.shareFeedItem(item.id);
      final index = items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        items[index] = item.copyWith(
          sharesCount: item.sharesCount + 1,
          isShared: true,
        );
      }
      Get.snackbar('Başarılı', 'Gönderi paylaşıldı');
    } catch (e) {
      Get.snackbar('Hata', 'Paylaşım işlemi başarısız oldu');
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      for (var notification in notifications) {
        if (!notification.isRead) {
          await _notificationService.markNotificationAsRead(notification.id);
        }
      }
      await getNotifications(); // Bildirimleri yenile
    } catch (e) {
      debugPrint('Error marking notifications as read: $e');
    }
  }

  Future<void> getNotifications() async {
    try {
      // Örnek bildirimler (gerçek implementasyonda API'den gelecek)
      notifications.value = [
        NotificationModel(
          id: '1',
          title: 'Yeni Bağlantı',
          body: 'Ahmet sizinle bağlantı kurmak istiyor',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: false,
        ),
        NotificationModel(
          id: '2',
          title: 'Yeni Mesaj',
          body: 'Mehmet size mesaj gönderdi',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          isRead: false,
        ),
      ];
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    }
  }
}
