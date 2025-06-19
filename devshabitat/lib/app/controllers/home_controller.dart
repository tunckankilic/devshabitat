import 'package:get/get.dart';
import '../services/github_service.dart';
import '../repositories/auth_repository.dart';
import '../core/services/snackbar_service.dart';
import '../models/feed_item.dart';
import '../repositories/feed_repository.dart';

class HomeController extends GetxController {
  final _authRepository = Get.find<AuthRepository>();
  final _githubService = Get.find<GithubService>();
  final FeedRepository _feedRepository;

  final RxBool isLoading = false.obs;
  final RxList activityFeed = [].obs;
  final RxMap githubStats = {}.obs;
  final RxInt connectionCount = 0.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<FeedItem> items = <FeedItem>[].obs;
  final Rx<FeedItem?> selectedFeedItem = Rx<FeedItem?>(null);

  HomeController({
    required FeedRepository feedRepository,
  }) : _feedRepository = feedRepository;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
    loadData();
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
    // TODO: İtem detay sayfasına yönlendir
    Get.toNamed('/item-detail', arguments: item);
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

  void onShare(FeedItem item) {
    // TODO: Paylaşım işlemini gerçekleştir
    Get.snackbar('Bilgi', 'Paylaşım özelliği yakında eklenecek');
  }
}
