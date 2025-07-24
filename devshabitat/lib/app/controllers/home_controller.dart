// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/github_service.dart';
import '../repositories/auth_repository.dart';
import '../models/feed_item.dart';

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
  late final FeedService _feedService;
  late final ConnectionService _connectionService;
  late final AuthController _authController;

  final RxBool isLoading = false.obs;
  final RxList activityFeed = [].obs;
  final RxMap<String, dynamic> githubStats = <String, dynamic>{}.obs;
  final RxInt connectionCount = 0.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<FeedItem> items = <FeedItem>[].obs;
  final Rx<FeedItem?> selectedFeedItem = Rx<FeedItem?>(null);
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoadingMore = false.obs;
  DocumentSnapshot? lastNotificationDocument;

  int get unreadNotificationsCount =>
      notifications.where((n) => !n.isRead).length;

  HomeController() {
    // Empty constructor
  }

  @override
  void onInit() {
    super.onInit();

    try {
      _feedService = Get.find<FeedService>();
      _connectionService = Get.find<ConnectionService>();
      _authController = Get.find<AuthController>();
      loadDashboardData();
      loadData();
      getNotifications();
    } catch (e) {
      print('Startup data loading: $e');
    }
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;

      // GitHub stats'ı optional yap
      String? username;
      try {
        username = await _authController.getGithubUsername();
        if (username != null && username.isNotEmpty) {
          final stats = await _githubService.getGithubStats(username);
          if (stats != null) {
            githubStats.value = {'stats': stats}; // Basit assign
          }
        }
      } catch (e) {
        print('GitHub stats skipped: $e');
      }

      // Aktivite akışını yükle
      if (username != null) {
        final activities = await _githubService.getUserActivities(username);
        activityFeed.value = activities;
      }

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
      if (_feedService != null) {
        final feedItems = await _feedService.getFeedItems();
        items.assignAll(feedItems);
      }
    } catch (e) {
      print('Feed yüklenirken hata: $e');
      rethrow;
    }
  }

  Future<void> _loadConnectionCount() async {
    try {
      if (_connectionService != null) {
        final count = await _connectionService.getConnectionCount();
        connectionCount.value = count;
      }
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
      if (_feedService != null) {
        await _feedService.likeFeedItem(item.id);
        await _loadFeedItems(); // Güncel listeyi yükle
      }
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
      if (_feedService != null) {
        await _feedService.shareFeedItem(item.id);
        await _loadFeedItems(); // Güncel listeyi yükle
      }
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
      final notifs = await _notificationService.getNotifications(
        lastDocument: lastNotificationDocument,
      );
      if (notifs.isNotEmpty) {
        notifications.addAll(notifs);
        lastNotificationDocument = notifs.last as DocumentSnapshot;
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    }
  }

  Future<void> loadMoreNotifications() async {
    if (isLoadingMore.value) return;

    try {
      isLoadingMore.value = true;
      await getNotifications();
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshNotifications() async {
    notifications.clear();
    lastNotificationDocument = null;
    await getNotifications();
  }

  Future<void> loadNotifications() async {
    await refreshNotifications();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _notificationService.markNotificationAsRead(notificationId);
      // Bildirimleri yenile
      await refreshNotifications();
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }
}
