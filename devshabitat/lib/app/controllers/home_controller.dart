import 'package:get/get.dart';
import '../repositories/enhanced_auth_repository.dart';
import '../services/github_service.dart';

class HomeController extends GetxController {
  final _authRepository = Get.find<EnhancedAuthRepository>();
  final _githubService = Get.find<GithubService>();

  final RxBool isLoading = false.obs;
  final RxList activityFeed = [].obs;
  final RxMap githubStats = {}.obs;
  final RxInt connectionCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;

      // GitHub istatistiklerini yükle
      final username =
          'YOUR_GITHUB_USERNAME'; // TODO: Get actual username from auth
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
}
