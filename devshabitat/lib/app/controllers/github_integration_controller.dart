import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:get/get.dart';
import '../models/github_stats_model.dart';
import '../services/github_service.dart';
import '../controllers/auth_controller.dart';

class GithubIntegrationController extends GetxController {
  final GithubService _githubService = Get.find<GithubService>();
  final AuthController _authController = Get.find<AuthController>();
  final Rx<GithubStatsModel?> _githubStats = Rx<GithubStatsModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxBool _isConnected = false.obs;

  // Getters
  GithubStatsModel? get githubStats => _githubStats.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get isConnected => _isConnected.value;

  @override
  void onInit() {
    super.onInit();
    // Sayfa açıldığında GitHub bağlantı durumunu kontrol et
    _checkGithubConnection();
  }

  // GitHub bağlantı durumunu kontrol et
  Future<void> _checkGithubConnection() async {
    try {
      final username = await _authController.getGithubUsername();
      if (username != null && username.isNotEmpty) {
        _isConnected.value = true;
        // GitHub stats'ları yükle
        await loadGithubStats();
      } else {
        _isConnected.value = false;
      }
    } catch (e) {
      _isConnected.value = false;
      _error.value = 'GitHub bağlantı durumu kontrol edilirken hata: $e';
    }
  }

  // GitHub bağlantısını başlatma (sadece gerekirse)
  Future<void> connectGithub() async {
    try {
      _isLoading.value = true;
      _error.value = '';

      // Önce mevcut bağlantıyı kontrol et
      final username = await _authController.getGithubUsername();
      if (username != null && username.isNotEmpty) {
        _isConnected.value = true;
        await loadGithubStats();
        Get.snackbar(
          'Bilgi',
          'GitHub hesabınız zaten bağlı',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // GitHub OAuth bağlantısını başlat
      final authRepository = Get.find<AuthRepository>();
      await authRepository.linkWithGithub();
      _isConnected.value = true;

      await loadGithubStats();

      Get.snackbar(
        'Başarılı',
        'GitHub hesabınız başarıyla bağlandı',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _error.value = 'GitHub bağlantısı kurulurken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'GitHub bağlantısı kurulamadı: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // GitHub istatistiklerini yükleme
  Future<void> loadGithubStats() async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final username = await _authController.getGithubUsername();
      if (username == null || username.isEmpty) {
        _error.value = 'GitHub kullanıcı adı bulunamadı';
        return;
      }

      final stats = await _githubService.getGithubStats(username);
      if (stats != null) {
        _githubStats.value = stats;
        _isConnected.value = true;
      } else {
        _error.value = 'GitHub istatistikleri alınamadı';
      }
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

      final authRepository = Get.find<AuthRepository>();
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
      Get.snackbar(
        'Hata',
        'GitHub bağlantısı kesilirken hata: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // GitHub profilini doğrulama
  Future<bool> verifyGithubProfile() async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final username = await _authController.getGithubUsername();
      if (username == null || username.isEmpty) {
        _error.value = 'GitHub kullanıcı adı bulunamadı';
        return false;
      }

      await _githubService.getUserInfo(username);

      Get.snackbar(
        'Başarılı',
        'GitHub profili başarıyla doğrulandı',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      _error.value = 'GitHub profili doğrulanırken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'GitHub profili doğrulanamadı: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // GitHub verilerini yenile
  Future<void> refreshGithubData() async {
    await loadGithubStats();
  }
}
