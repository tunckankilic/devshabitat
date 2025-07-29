import 'package:devshabitat/app/models/user_profile_model.dart';
import 'package:get/get.dart';
import '../services/github_service.dart';
import '../services/developer_matching_service.dart';
import '../core/services/error_handler_service.dart';
import 'networking_controller.dart';

class DeveloperMatchingController extends GetxController {
  final GithubService _githubService = Get.find();
  final DeveloperMatchingService _matchingService = Get.find();
  final ErrorHandlerService _errorHandler = Get.find();
  final NetworkingController _networkingController = Get.find();

  final RxList<UserProfile> similarDevelopers = <UserProfile>[].obs;
  final RxList<Map<String, dynamic>> projectSuggestions =
      <Map<String, dynamic>>[].obs;
  final RxList<UserProfile> potentialMentors = <UserProfile>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingSimilar = false.obs;
  final RxBool isLoadingProjects = false.obs;
  final RxBool isLoadingMentors = false.obs;
  final RxString error = ''.obs;

  // Skill-based matching preferences
  final RxList<String> preferredSkills = <String>[].obs;
  final RxList<String> preferredTechnologies = <String>[].obs;
  final RxInt minExperienceYears = 0.obs;
  final RxInt maxDistance = 50.obs; // km
  final RxBool preferRemote = true.obs;
  final RxBool preferFullTime = true.obs;
  final RxBool preferPartTime = false.obs;
  final RxBool preferFreelance = false.obs;

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

      // Tercih edilen teknolojileri ekle
      final allTechStack = [...userTechStack, ...preferredTechnologies];

      // Benzer teknolojileri kullanan geliştiricileri bul
      final developers = await _matchingService.findDevelopersByTechStack(
        techStack: allTechStack,
        excludeUsername: username,
      );

      // Filtreleme uygula
      final filteredDevelopers = developers.where((developer) {
        // Deneyim yılı kontrolü
        if (developer.yearsOfExperience < minExperienceYears.value) {
          return false;
        }

        // Çalışma türü kontrolü
        if (preferRemote.value && !developer.isRemote) {
          return false;
        }
        if (preferFullTime.value && !developer.isFullTime) {
          return false;
        }
        if (preferPartTime.value && !developer.isPartTime) {
          return false;
        }
        if (preferFreelance.value && !developer.isFreelance) {
          return false;
        }

        return true;
      }).toList();

      // Eşleşme skoruna göre sırala
      filteredDevelopers.sort((a, b) {
        final scoreA = calculateMatchScore(a);
        final scoreB = calculateMatchScore(b);
        return scoreB.compareTo(scoreA);
      });

      // Cache'e kaydet
      _updateCache(cacheKey, filteredDevelopers);
      similarDevelopers.value = filteredDevelopers;
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
      double baseScore = _matchingService.calculateMatchScore(developer);

      // Skill-based bonus
      double skillBonus = 0.0;
      if (preferredSkills.isNotEmpty) {
        final commonSkills = developer.skills
            .where((skill) => preferredSkills.contains(skill))
            .length;
        skillBonus = commonSkills / preferredSkills.length * 0.2;
      }

      // Technology bonus
      double techBonus = 0.0;
      if (preferredTechnologies.isNotEmpty) {
        final commonTechs = developer.skills
            .where((tech) => preferredTechnologies.contains(tech))
            .length;
        techBonus = commonTechs / preferredTechnologies.length * 0.15;
      }

      // Experience bonus
      double expBonus = 0.0;
      if (developer.yearsOfExperience >= minExperienceYears.value) {
        expBonus = 0.1;
      }

      // Work type bonus
      double workTypeBonus = 0.0;
      if (preferRemote.value && developer.isRemote) workTypeBonus += 0.05;
      if (preferFullTime.value && developer.isFullTime) workTypeBonus += 0.05;
      if (preferPartTime.value && developer.isPartTime) workTypeBonus += 0.05;
      if (preferFreelance.value && developer.isFreelance) workTypeBonus += 0.05;

      final totalScore =
          baseScore + skillBonus + techBonus + expBonus + workTypeBonus;
      return totalScore.clamp(0.0, 1.0);
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

      // NetworkingController'a da ekle
      await _networkingController.addConnection(developerId);

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
  @override
  Future<void> refresh() async {
    clearCache();
    await Future.wait([
      findSimilarDevelopers(),
      suggestCollaborations(),
      findMentors(),
    ]);
  }
}
