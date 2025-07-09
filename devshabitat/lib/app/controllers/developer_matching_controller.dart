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
  final RxString error = ''.obs;

  // Benzer geliştiricileri bulma
  Future<void> findSimilarDevelopers() async {
    try {
      isLoading.value = true;
      error.value = '';

      final username = await _githubService.getCurrentUsername();
      if (username == null) {
        throw Exception('GitHub kullanıcı adı bulunamadı');
      }

      // Kullanıcının teknoloji stack'ini al
      final userTechStack = await _githubService.getTechStack(username);

      // Benzer teknolojileri kullanan geliştiricileri bul
      final developers = await _matchingService.findDevelopersByTechStack(
        techStack: userTechStack,
        excludeUsername: username,
      );

      similarDevelopers.value = developers;
    } catch (e) {
      error.value = 'Benzer geliştiriciler bulunurken bir hata oluştu: $e';
      _errorHandler.handleError(e, ErrorHandlerService.MATCHING_ERROR);
    } finally {
      isLoading.value = false;
    }
  }

  // Proje önerileri
  Future<void> suggestCollaborations() async {
    try {
      isLoading.value = true;
      error.value = '';

      final username = await _githubService.getCurrentUsername();
      if (username == null) {
        throw Exception('GitHub kullanıcı adı bulunamadı');
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
    }
  }

  // Mentor bulma
  Future<void> findMentors() async {
    try {
      isLoading.value = true;
      error.value = '';

      final username = await _githubService.getCurrentUsername();
      if (username == null) {
        throw Exception('GitHub kullanıcı adı bulunamadı');
      }

      // Kullanıcının öğrenmek istediği teknolojilere göre mentor önerileri
      final mentors = await _matchingService.findPotentialMentors(
        username: username,
      );

      potentialMentors.value = mentors;
    } catch (e) {
      error.value = 'Mentor önerileri alınırken bir hata oluştu: $e';
      _errorHandler.handleError(e, ErrorHandlerService.MATCHING_ERROR);
    } finally {
      isLoading.value = false;
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
}
