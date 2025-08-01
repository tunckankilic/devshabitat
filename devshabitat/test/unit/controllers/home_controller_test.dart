import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devshabitat/app/controllers/home_controller.dart';
import 'package:devshabitat/app/services/github_service.dart';
import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:devshabitat/app/models/feed_item.dart';
import 'package:devshabitat/app/models/notification_model.dart';
import 'package:devshabitat/app/services/notification_service.dart';
import 'package:devshabitat/app/services/feed_service.dart';
import 'package:devshabitat/app/services/connection_service.dart';
import 'package:devshabitat/app/controllers/auth_controller.dart';
import 'package:devshabitat/app/models/github_stats_model.dart';
import '../../../test/test_helper.dart';

@GenerateNiceMocks([
  MockSpec<GithubService>(),
  MockSpec<AuthRepository>(),
  MockSpec<NotificationService>(),
  MockSpec<FeedService>(),
  MockSpec<ConnectionService>(),
  MockSpec<AuthController>(),
  MockSpec<DocumentSnapshot>(),
])
import 'home_controller_test.mocks.dart';

void main() {
  late HomeController controller;
  late MockGithubService mockGithubService;
  late MockAuthRepository mockAuthRepository;
  late MockNotificationService mockNotificationService;
  late MockFeedService mockFeedService;
  late MockConnectionService mockConnectionService;
  late MockAuthController mockAuthController;

  setUp(() async {
    await setupTestEnvironment();

    mockGithubService = MockGithubService();
    mockAuthRepository = MockAuthRepository();
    mockNotificationService = MockNotificationService();
    mockFeedService = MockFeedService();
    mockConnectionService = MockConnectionService();
    mockAuthController = MockAuthController();

    // onStart metodlarını mock'la
    when(mockGithubService.onStart()).thenAnswer((_) async {});
    when(mockNotificationService.onStart()).thenAnswer((_) async {});
    when(mockFeedService.onStart()).thenAnswer((_) async {});
    when(mockConnectionService.onStart()).thenAnswer((_) async {});
    when(mockAuthController.onStart()).thenAnswer((_) async {});

    // Get.put ile mock'ları kaydet
    Get.put<GithubService>(mockGithubService);
    Get.put<AuthRepository>(mockAuthRepository);
    Get.put<NotificationService>(mockNotificationService);
    Get.put<FeedService>(mockFeedService);
    Get.put<ConnectionService>(mockConnectionService);
    Get.put<AuthController>(mockAuthController);

    controller = HomeController();
  });

  tearDown(() {
    Get.reset();
  });

  group('HomeController - Temel Fonksiyonlar', () {
    test('başlangıç değerleri doğru olmalı', () {
      expect(controller.isLoading.value, false);
      expect(controller.hasError.value, false);
      expect(controller.errorMessage.value, '');
      expect(controller.items.length, 0);
      expect(controller.notifications.length, 0);
      expect(controller.connectionCount.value, 0);
    });

    test('unreadNotificationsCount doğru hesaplanmalı', () {
      // Okunmamış bildirimler ekle
      controller.notifications.addAll([
        NotificationModel(
          id: '1',
          title: 'Test 1',
          body: 'Body 1',
          createdAt: DateTime.now(),
          isRead: false,
          type: NotificationType.message,
        ),
        NotificationModel(
          id: '2',
          title: 'Test 2',
          body: 'Body 2',
          createdAt: DateTime.now(),
          isRead: true,
          type: NotificationType.message,
        ),
        NotificationModel(
          id: '3',
          title: 'Test 3',
          body: 'Body 3',
          createdAt: DateTime.now(),
          isRead: false,
          type: NotificationType.message,
        ),
      ]);

      expect(controller.unreadNotificationsCount, 2);
    });
  });

  group('HomeController - Dashboard Veri Yükleme', () {
    test('loadDashboardData başarılı durumda', () async {
      // Mock setup
      when(mockAuthController.getGithubUsername())
          .thenAnswer((_) async => 'testuser');
      when(mockGithubService.getGithubStats('testuser'))
          .thenAnswer((_) async => GithubStatsModel(
                username: 'testuser',
                totalRepositories: 10,
                totalContributions: 100,
                languageStats: {'Dart': 5, 'JavaScript': 3},
                recentRepositories: [],
                contributionGraph: {},
                followers: 50,
                following: 30,
              ));
      when(mockAuthRepository.getUserConnections())
          .thenAnswer((_) async => List.generate(25, (i) => 'conn_$i'));

      await controller.loadDashboardData();

      expect(controller.githubStats['totalRepositories'], 10);
      expect(controller.githubStats['followers'], 50);
      expect(controller.githubStats['following'], 30);
      expect(controller.connectionCount.value, 25);
      expect(controller.hasError.value, false);
    });

    test('loadDashboardData hata durumunda', () async {
      // Mock setup - hata fırlat
      when(mockAuthController.getGithubUsername())
          .thenAnswer((_) async => 'testuser');
      when(mockGithubService.getGithubStats('testuser'))
          .thenThrow(Exception('GitHub API hatası'));
      when(mockAuthRepository.getUserConnections())
          .thenThrow(Exception('Bağlantı hatası'));

      await controller.loadDashboardData();

      expect(controller.hasError.value, true);
      expect(controller.errorMessage.value, isNotEmpty);
    });

    test('loadDashboardData yükleme durumu', () async {
      // Mock setup - yavaş response
      when(mockAuthController.getGithubUsername())
          .thenAnswer((_) async => 'testuser');
      when(mockGithubService.getGithubStats('testuser')).thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 100));
        return GithubStatsModel(
          username: 'testuser',
          totalRepositories: 5,
          totalContributions: 50,
          languageStats: {},
          recentRepositories: [],
          contributionGraph: {},
          followers: 25,
          following: 15,
        );
      });

      final future = controller.loadDashboardData();

      // Yükleme başladığında loading true olmalı
      expect(controller.isLoading.value, true);

      await future;

      // Yükleme bittiğinde loading false olmalı
      expect(controller.isLoading.value, false);
    });
  });

  group('HomeController - Feed Veri Yükleme', () {
    test('loadData başarılı durumda', () async {
      final mockFeedItems = [
        FeedItem(
          id: '1',
          userId: 'user1',
          content: 'Test post 1',
          likesCount: 10,
          commentsCount: 5,
          sharesCount: 2,
          isLiked: false,
          isShared: false,
          createdAt: DateTime.now(),
        ),
        FeedItem(
          id: '2',
          userId: 'user2',
          content: 'Test post 2',
          likesCount: 15,
          commentsCount: 8,
          sharesCount: 3,
          isLiked: true,
          isShared: false,
          createdAt: DateTime.now(),
        ),
      ];

      when(mockFeedService.getFeedItems())
          .thenAnswer((_) async => mockFeedItems);

      await controller.loadData();

      expect(controller.items.length, 2);
      expect(controller.items[0].content, 'Test post 1');
      expect(controller.items[1].content, 'Test post 2');
      expect(controller.hasError.value, false);
    });

    test('loadData boş liste durumunda', () async {
      when(mockFeedService.getFeedItems()).thenAnswer((_) async => []);

      await controller.loadData();

      expect(controller.items.length, 0);
      expect(controller.hasError.value, false);
    });

    test('loadData hata durumunda', () async {
      when(mockFeedService.getFeedItems())
          .thenThrow(Exception('Feed yükleme hatası'));

      await controller.loadData();

      expect(controller.hasError.value, true);
      expect(controller.errorMessage.value, isNotEmpty);
    });
  });

  group('HomeController - Bildirim Yönetimi', () {
    test('getNotifications başarılı durumda', () async {
      final mockNotifications = [
        NotificationModel(
          id: '1',
          title: 'Yeni mesaj',
          body: 'Birisi size mesaj gönderdi',
          createdAt: DateTime.now(),
          isRead: false,
          type: NotificationType.message,
        ),
        NotificationModel(
          id: '2',
          title: 'Bağlantı isteği',
          body: 'Yeni bağlantı isteği aldınız',
          createdAt: DateTime.now(),
          isRead: true,
          type: NotificationType.connection,
        ),
      ];

      when(mockNotificationService.getNotifications())
          .thenAnswer((_) async => mockNotifications);

      await controller.getNotifications();

      expect(controller.notifications.length, 2);
      expect(controller.notifications[0].title, 'Yeni mesaj');
      expect(controller.notifications[1].title, 'Bağlantı isteği');
    });

    test('getNotifications hata durumunda', () async {
      when(mockNotificationService.getNotifications())
          .thenThrow(Exception('Bildirim yükleme hatası'));

      await controller.getNotifications();

      expect(controller.hasError.value, true);
      expect(controller.errorMessage.value, isNotEmpty);
    });
  });

  group('HomeController - Feed Item İşlemleri', () {
    setUp(() {
      // Test için feed item'ları ekle
      controller.items.addAll([
        FeedItem(
          id: '1',
          userId: 'user1',
          content: 'Test post',
          likesCount: 10,
          commentsCount: 5,
          sharesCount: 2,
          isLiked: false,
          isShared: false,
          createdAt: DateTime.now(),
        ),
      ]);
    });

    test('onLike başarılı durumda', () async {
      when(mockFeedService.likeFeedItem('1')).thenAnswer((_) async => true);
      when(mockFeedService.getFeedItems()).thenAnswer((_) async => [
            FeedItem(
              id: '1',
              userId: 'user1',
              content: 'Test post',
              likesCount: 11,
              commentsCount: 5,
              sharesCount: 2,
              isLiked: true,
              isShared: false,
              createdAt: DateTime.now(),
            ),
          ]);

      controller.onLike(controller.items[0]);

      verify(mockFeedService.likeFeedItem('1')).called(1);
    });

    test('onShare başarılı durumda', () async {
      when(mockFeedService.shareFeedItem('1')).thenAnswer((_) async => true);
      when(mockFeedService.getFeedItems()).thenAnswer((_) async => [
            FeedItem(
              id: '1',
              userId: 'user1',
              content: 'Test post',
              likesCount: 10,
              commentsCount: 5,
              sharesCount: 3,
              isLiked: false,
              isShared: true,
              createdAt: DateTime.now(),
            ),
          ]);

      controller.onShare(controller.items[0]);

      verify(mockFeedService.shareFeedItem('1')).called(1);
    });
  });

  group('HomeController - Pagination', () {
    test('loadMoreNotifications başarılı durumda', () async {
      when(mockNotificationService.getNotifications(
              lastDocument: anyNamed('lastDocument')))
          .thenAnswer((_) async => [
                NotificationModel(
                  id: '3',
                  title: 'Additional notification',
                  body: 'Additional notification body',
                  createdAt: DateTime.now(),
                  isRead: false,
                  type: NotificationType.message,
                ),
              ]);

      await controller.loadMoreNotifications();

      expect(controller.isLoadingMore.value, false);
    });

    test('loadMoreNotifications hata durumunda', () async {
      when(mockNotificationService.getNotifications(
              lastDocument: anyNamed('lastDocument')))
          .thenThrow(Exception('Bildirim yükleme hatası'));

      await controller.loadMoreNotifications();

      expect(controller.isLoadingMore.value, false);
    });
  });

  group('HomeController - State Management', () {
    test('onItemTap selectedFeedItem seçimi', () {
      final testItem = FeedItem(
        id: '1',
        userId: 'user1',
        content: 'Test post',
        likesCount: 10,
        commentsCount: 5,
        sharesCount: 2,
        isLiked: false,
        isShared: false,
        createdAt: DateTime.now(),
      );

      controller.onItemTap(testItem);

      expect(controller.selectedFeedItem.value, testItem);
    });

    test('refreshData tüm verileri yeniden yüklemeli', () async {
      when(mockAuthController.getGithubUsername())
          .thenAnswer((_) async => 'testuser');
      when(mockGithubService.getGithubStats('testuser'))
          .thenAnswer((_) async => GithubStatsModel(
                username: 'testuser',
                totalRepositories: 5,
                totalContributions: 50,
                languageStats: {},
                recentRepositories: [],
                contributionGraph: {},
                followers: 25,
                following: 15,
              ));
      when(mockAuthRepository.getUserConnections())
          .thenAnswer((_) async => List.generate(10, (i) => 'conn_$i'));
      when(mockFeedService.getFeedItems()).thenAnswer((_) async => []);
      when(mockNotificationService.getNotifications())
          .thenAnswer((_) async => []);

      await controller.refreshData();

      expect(controller.hasError.value, false);
      expect(controller.errorMessage.value, '');
    });
  });

  group('HomeController - Edge Cases', () {
    test('null feed item işlemleri', () async {
      // Null feed item testleri kaldırıldı çünkü metodlar null kabul etmiyor
    });

    test('var olmayan feed item işlemleri', () async {
      when(mockFeedService.likeFeedItem('nonexistent'))
          .thenThrow(Exception('Item bulunamadı'));

      final testItem = FeedItem(
        id: 'nonexistent',
        userId: 'user1',
        content: 'Test post',
        likesCount: 10,
        commentsCount: 5,
        sharesCount: 2,
        isLiked: false,
        isShared: false,
        createdAt: DateTime.now(),
      );

      controller.onLike(testItem);

      // Hata durumunda snackbar gösterilmeli
    });

    test('çoklu hızlı işlemler', () async {
      when(mockFeedService.likeFeedItem('1')).thenAnswer((_) async => true);
      when(mockFeedService.getFeedItems()).thenAnswer((_) async => []);

      final testItem = FeedItem(
        id: '1',
        userId: 'user1',
        content: 'Test post',
        likesCount: 10,
        commentsCount: 5,
        sharesCount: 2,
        isLiked: false,
        isShared: false,
        createdAt: DateTime.now(),
      );

      for (int i = 0; i < 5; i++) {
        controller.onLike(testItem);
      }

      // Son durum tutarlı olmalı
      verify(mockFeedService.likeFeedItem('1')).called(5);
    });
  });

  group('HomeController - Performans Testleri', () {
    test('büyük veri seti ile performans', () async {
      final largeFeedItems = List.generate(
          100,
          (index) => FeedItem(
                id: 'item_$index',
                userId: 'user_$index',
                content: 'Post $index',
                likesCount: index,
                commentsCount: index ~/ 2,
                sharesCount: index ~/ 3,
                isLiked: index % 2 == 0,
                isShared: index % 3 == 0,
                createdAt: DateTime.now(),
              ));

      when(mockFeedService.getFeedItems())
          .thenAnswer((_) async => largeFeedItems);

      final stopwatch = Stopwatch()..start();
      await controller.loadData();
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      expect(controller.items.length, 100);
    });
  });
}
