import 'package:get/get.dart';
import '../services/github_service.dart';
import '../repositories/auth_repository.dart';
import '../core/services/snackbar_service.dart';
import '../models/feed_item.dart';
import '../repositories/feed_repository.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../services/feed_service.dart';
import '../services/connection_service.dart';
import '../controllers/auth_controller.dart';

class HomeController extends GetxController {
  final _authRepository = Get.find<AuthRepository>();
  final _githubService = Get.find<GithubService>();
  final _notificationService = Get.find<NotificationService>();
  final FeedRepository _feedRepository;
  final FeedService _feedService = Get.find();
  final ConnectionService _connectionService = Get.find();
  final AuthController _authController = Get.find();

  final RxBool isLoading = false.obs;
  final RxList activityFeed = [].obs;
  final RxMap<String, dynamic> githubStats = <String, dynamic>{}.obs;
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
    await loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Paralel veri yükleme
      await Future.wait([
        _loadFeedItems(),
        _loadConnectionCount(),
        _loadGithubStats(),
      ]);
    } catch (e) {
      hasError.value = true;
      errorMessage.value =
          'Veriler yüklenirken bir hata oluştu: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadFeedItems() async {
    try {
      final feedItems = await _feedService.getFeedItems();
      items.assignAll(feedItems);
    } catch (e) {
      print('Feed yüklenirken hata: $e');
      rethrow;
    }
  }

  Future<void> _loadConnectionCount() async {
    try {
      final count = await _connectionService.getConnectionCount();
      connectionCount.value = count;
    } catch (e) {
      print('Bağlantı sayısı yüklenirken hata: $e');
      rethrow;
    }
  }

  Future<void> _loadGithubStats() async {
    try {
      final username = _authController.currentUser?.displayName;
      if (username == null) return;

      final userInfo = await _githubService.getUserInfo(username);
      final repos = await _githubService.getUserRepos(username);
      final contributedRepos =
          await _githubService.getContributedRepos(username);
      final starredRepos = await _githubService.getStarredRepos(username);
      final commitStats = await _githubService.getCommitStats(username);

      githubStats.assignAll({
        'userInfo': userInfo,
        'repos': repos,
        'contributedRepos': contributedRepos,
        'starredRepos': starredRepos,
        'commitStats': commitStats,
      });
    } catch (e) {
      print('GitHub istatistikleri yüklenirken hata: $e');
      rethrow;
    }
  }

  void onItemTap(FeedItem item) {
    selectedFeedItem.value = item;
    Get.toNamed('/feed/detail', arguments: item);
  }

  void onLike(FeedItem item) async {
    try {
      await _feedService.likeFeedItem(item.id);
      await _loadFeedItems(); // Güncel listeyi yükle
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Beğeni işlemi başarısız oldu',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void onComment(FeedItem item) {
    Get.toNamed('/comments', arguments: item);
  }

  void onShare(FeedItem item) async {
    try {
      await _feedService.shareFeedItem(item.id);
      await _loadFeedItems(); // Güncel listeyi yükle
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Paylaşım işlemi başarısız oldu',
        snackPosition: SnackPosition.BOTTOM,
      );
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
