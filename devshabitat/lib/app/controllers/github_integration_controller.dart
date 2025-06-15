import 'package:get/get.dart';
import '../models/github_stats_model.dart';
import '../services/github_service.dart';
import '../repositories/enhanced_auth_repository.dart';

class GithubIntegrationController extends GetxController {
  final GithubService _githubService = Get.find<GithubService>();
  final Rx<GithubStatsModel?> _githubStats = Rx<GithubStatsModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxBool _isConnected = false.obs;

  // Getters
  GithubStatsModel? get githubStats => _githubStats.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get isConnected => _isConnected.value;

  // GitHub bağlantısını başlatma
  Future<void> connectGithub() async {
    try {
      _isLoading.value = true;
      _error.value = '';

      // GitHub OAuth bağlantısını başlat
      final authRepository = Get.find<EnhancedAuthRepository>();
      await authRepository.linkWithGithub();
      _isConnected.value = true;

      await loadGithubStats();
    } catch (e) {
      _error.value = 'GitHub bağlantısı kurulurken bir hata oluştu: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  // GitHub istatistiklerini yükleme
  Future<void> loadGithubStats() async {
    if (!_isConnected.value) {
      _error.value = 'Önce GitHub hesabınızı bağlamanız gerekiyor';
      return;
    }

    try {
      _isLoading.value = true;
      _error.value = '';

      final username = _githubStats.value?.username ?? 'YOUR_GITHUB_USERNAME';
      _githubStats.value = await _githubService.getGithubStats(username);
    } catch (e) {
      _error.value = 'GitHub istatistikleri yüklenirken bir hata oluştu: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  // GitHub bağlantısını kesme
  Future<void> disconnectGithub() async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final authRepository = Get.find<EnhancedAuthRepository>();
      await authRepository.unlinkProvider('github.com');
      _isConnected.value = false;
      _githubStats.value = null;

      Get.snackbar(
        'Başarılı',
        'GitHub hesabı başarıyla bağlantısı kesildi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _error.value = 'GitHub bağlantısı kesilirken bir hata oluştu: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  // GitHub profilini doğrulama
  Future<bool> verifyGithubProfile() async {
    if (!_isConnected.value) {
      _error.value = 'Önce GitHub hesabınızı bağlamanız gerekiyor';
      return false;
    }

    try {
      _isLoading.value = true;
      _error.value = '';

      final username = _githubStats.value?.username ?? 'YOUR_GITHUB_USERNAME';
      await _githubService.getUserInfo(username);

      Get.snackbar(
        'Başarılı',
        'GitHub profili başarıyla doğrulandı',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      _error.value = 'GitHub profili doğrulanırken bir hata oluştu: $e';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
}
