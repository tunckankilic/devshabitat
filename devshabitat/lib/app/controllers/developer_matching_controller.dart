import 'package:devshabitat/app/models/user_profile_model.dart';
import 'package:get/get.dart';
import '../services/github_service.dart';
import '../services/developer_matching_service.dart';
import '../core/services/error_handler_service.dart';

class DeveloperMatchingController extends GetxController {
  final GithubService _githubService = Get.find();
  final DeveloperMatchingService _matchingService = Get.find();
  final ErrorHandlerService _errorHandler = Get.find();

  final RxList<UserProfile> similarDevelopers = <UserProfile>[].obs;
  final RxList<Map<String, dynamic>> projectSuggestions =
      <Map<String, dynamic>>[].obs;
  final RxList<UserProfile> potentialMentors = <UserProfile>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingSimilar = false.obs;
  final RxBool isLoadingProjects = false.obs;
  final RxBool isLoadingMentors = false.obs;
  final RxString error = ''.obs;

  // Cache mekanizması
  final Map<String, List<UserProfile>> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheTimeout = const Duration(minutes: 10);

  // Benzer geliştiricileri bulma
  Future<void> findSimilarDevelopers() async {
    try {
      isLoading.value = true;
      isLoadingSimilar.value = true;
      error.value = '';

      // Cache kontrolü
      const cacheKey = 'similar_developers';
      if (_isCacheValid(cacheKey)) {
        similarDevelopers.value = _cache[cacheKey]!;
        return;
      }

      final username = await _githubService.getCurrentUsername();
      if (username == null) {
        error.value =
            'GitHub hesabınızla giriş yapmanız gerekiyor. Lütfen önce GitHub ile giriş yapın.';
        return;
      }

      // Kullanıcının teknoloji stack'ini al
      final userTechStack = await _githubService.getTechStack(username);
      if (userTechStack.isEmpty) {
        error.value =
            'GitHub profilinizde teknoloji bilgisi bulunamadı. Lütfen GitHub profilinizi güncelleyin.';
        return;
      }

      // Benzer teknolojileri kullanan geliştiricileri bul
      final developers = await _matchingService.findDevelopersByTechStack(
        techStack: userTechStack,
        excludeUsername: username,
      );

      // Eşleşme skoruna göre sırala
      developers.sort((a, b) {
        final scoreA = _matchingService.calculateMatchScore(a);
        final scoreB = _matchingService.calculateMatchScore(b);
        return scoreB.compareTo(scoreA);
      });

      // Cache'e kaydet
      _updateCache(cacheKey, developers);
      similarDevelopers.value = developers;
    } catch (e) {
      error.value = 'Benzer geliştiriciler bulunurken bir hata oluştu: $e';
      _errorHandler.handleError(e, ErrorHandlerService.MATCHING_ERROR);
    } finally {
      isLoading.value = false;
      isLoadingSimilar.value = false;
    }
  }

  // Proje önerileri
  Future<void> suggestCollaborations() async {
    try {
      isLoading.value = true;
      isLoadingProjects.value = true;
      error.value = '';

      final username = await _githubService.getCurrentUsername();
      if (username == null) {
        error.value =
            'GitHub hesabınızla giriş yapmanız gerekiyor. Lütfen önce GitHub ile giriş yapın.';
        return;
      }

      // Kullanıcının ilgi alanlarına göre proje önerileri
      final suggestions = await _matchingService.getProjectSuggestions(
        username: username,
      );

      projectSuggestions.value = suggestions;
    } catch (e) {
      error.value = 'Proje önerileri alınırken bir hata oluştu: $e';
      _errorHandler.handleError(e, ErrorHandlerService.MATCHING_ERROR);
    } finally {
      isLoading.value = false;
      isLoadingProjects.value = false;
    }
  }

  // Mentor bulma
  Future<void> findMentors() async {
    try {
      isLoading.value = true;
      isLoadingMentors.value = true;
      error.value = '';

      // Cache kontrolü
      const cacheKey = 'mentors';
      if (_isCacheValid(cacheKey)) {
        potentialMentors.value = _cache[cacheKey]!;
        return;
      }

      final username = await _githubService.getCurrentUsername();
      if (username == null) {
        error.value =
            'GitHub hesabınızla giriş yapmanız gerekiyor. Lütfen önce GitHub ile giriş yapın.';
        return;
      }

      // Kullanıcının öğrenmek istediği teknolojilere göre mentor önerileri
      final mentors = await _matchingService.findPotentialMentors(
        username: username,
      );

      // Cache'e kaydet
      _updateCache(cacheKey, mentors);
      potentialMentors.value = mentors;
    } catch (e) {
      error.value = 'Mentor önerileri alınırken bir hata oluştu: $e';
      _errorHandler.handleError(e, ErrorHandlerService.MATCHING_ERROR);
    } finally {
      isLoading.value = false;
      isLoadingMentors.value = false;
    }
  }

  // Eşleşme skoru hesaplama
  double calculateMatchScore(UserProfile developer) {
    try {
      return _matchingService.calculateMatchScore(developer);
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.MATCHING_ERROR);
      return 0.0;
    }
  }

  // İşbirliği talebi gönderme
  Future<void> sendCollaborationRequest(String developerId) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _matchingService.sendCollaborationRequest(
        targetUserId: developerId,
      );

      Get.snackbar(
        'Başarılı',
        'İşbirliği talebi gönderildi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'İşbirliği talebi gönderilirken bir hata oluştu: $e';
      _errorHandler.handleError(e, ErrorHandlerService.MATCHING_ERROR);
    } finally {
      isLoading.value = false;
    }
  }

  // Mentorluk talebi gönderme
  Future<void> sendMentorshipRequest(String mentorId) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _matchingService.sendMentorshipRequest(
        mentorId: mentorId,
      );

      Get.snackbar(
        'Başarılı',
        'Mentorluk talebi gönderildi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Mentorluk talebi gönderilirken bir hata oluştu: $e';
      _errorHandler.handleError(e, ErrorHandlerService.MATCHING_ERROR);
    } finally {
      isLoading.value = false;
    }
  }

  // Cache yardımcı methodları
  bool _isCacheValid(String key) {
    if (!_cache.containsKey(key) || !_cacheTimestamps.containsKey(key)) {
      return false;
    }

    final cacheTime = _cacheTimestamps[key]!;
    return DateTime.now().difference(cacheTime) < _cacheTimeout;
  }

  void _updateCache(String key, List<UserProfile> data) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }

  // Cache temizleme
  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  // Yenileme - cache temizleyerek
  Future<void> refresh() async {
    clearCache();
    await Future.wait([
      findSimilarDevelopers(),
      suggestCollaborations(),
      findMentors(),
    ]);
  }
}
