import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../services/github/content_sharing_service.dart';
import '../models/github_repository_model.dart';
import '../models/collaboration_request_model.dart';
import '../core/services/logger_service.dart';
import '../core/services/error_handler_service.dart';

import '../controllers/auth_controller.dart';

class GitHubContentController extends GetxController {
  final GitHubContentSharingService _contentService;
  final LoggerService _logger;
  final ErrorHandlerService _errorHandler;

  // UI State
  final selectedCollaborationType = RxnString();
  final selectedSkills = <String>[].obs;
  final messageController = TextEditingController();
  final isLoading = false.obs;

  // Repository Data
  final repositories = <GitHubRepositoryModel>[].obs;
  final currentPage = 1.obs;
  final hasMoreData = true.obs;
  final contributionCount = 0.obs;
  final collaborationCount = 0.obs;

  GitHubContentController({
    required GitHubContentSharingService contentService,
    required LoggerService logger,
    required ErrorHandlerService errorHandler,
  }) : _contentService = contentService,
       _logger = logger,
       _errorHandler = errorHandler;

  @override
  void onInit() {
    super.onInit();
    loadInitialRepositories();
    loadContributions();
    loadCollaborations();
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  // Repository Yönetimi
  Future<void> loadInitialRepositories() async {
    try {
      isLoading.value = true;
      currentPage.value = 1;
      repositories.clear();

      final newRepos = await _contentService.getDiscoverableRepositories(
        page: currentPage.value,
      );

      repositories.addAll(newRepos);
      hasMoreData.value = newRepos.length == 20; // Sayfa başına 20 repo
    } catch (e) {
      _handleError('Repolar yüklenirken hata oluştu', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreRepositories() async {
    if (isLoading.value || !hasMoreData.value) return;

    try {
      isLoading.value = true;
      currentPage.value++;

      final newRepos = await _contentService.getDiscoverableRepositories(
        page: currentPage.value,
      );

      repositories.addAll(newRepos);
      hasMoreData.value = newRepos.length == 20;
    } catch (e) {
      _handleError('Daha fazla repo yüklenirken hata oluştu', e);
      currentPage.value--; // Hata durumunda sayfayı geri al
    } finally {
      isLoading.value = false;
    }
  }

  // İşbirliği İşlemleri
  Future<void> initiateCollaboration(GitHubRepositoryModel repository) async {
    try {
      if (selectedCollaborationType.value == null) {
        throw Exception('Lütfen bir işbirliği türü seçin');
      }

      if (messageController.text.trim().isEmpty) {
        throw Exception('Lütfen bir işbirliği mesajı yazın');
      }

      final request = CollaborationRequestModel(
        id: CollaborationRequestModel.generateId(),
        repositoryOwner: repository.owner,
        repositoryName: repository.name,
        requesterId: Get.find<AuthController>().currentUser!.uid,
        requesterUsername: Get.find<AuthController>().currentUser!.displayName!,
        collaborationType: selectedCollaborationType.value!,
        message: messageController.text.trim(),
        requiredSkills: selectedSkills,
        createdAt: DateTime.now(),
        status: 'pending',
      );

      await _contentService.createCollaborationRequest(
        repository.owner,
        repository.name,
        request,
      );

      Get.back();
      Get.snackbar(
        'Başarılı',
        'İşbirliği isteği gönderildi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _handleError('İşbirliği isteği gönderilemedi', e);
    }
  }

  Future<void> openDiscussion(GitHubRepositoryModel repository) async {
    try {
      final title = 'Tartışma: ${repository.name}';
      final body = 'Bu repository hakkında bir tartışma başlatmak istiyorum.';

      await _contentService.createDiscussion(
        repository.owner,
        repository.name,
        title,
        body,
      );

      Get.snackbar(
        'Başarılı',
        'Tartışma başlatıldı',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _handleError('Tartışma başlatılamadı', e);
    }
  }

  Future<void> shareRepository(GitHubRepositoryModel repository) async {
    try {
      await Share.share(
        'Check out this GitHub repository: https://github.com/${repository.owner}/${repository.name}',
        subject: repository.name,
      );
    } catch (e) {
      _handleError('Repository paylaşılamadı', e);
    }
  }

  // UI Helpers
  void setCollaborationType(String? type) {
    selectedCollaborationType.value = type;
  }

  void toggleSkill(String skill) {
    if (selectedSkills.contains(skill)) {
      selectedSkills.remove(skill);
    } else {
      selectedSkills.add(skill);
    }
  }

  void _handleError(String message, dynamic error) {
    _logger.e('$message: $error');
    _errorHandler.handleError(error);
  }

  Future<void> loadContributions() async {
    try {
      final count = await _contentService.getUserContributionsCount();
      contributionCount.value = count;
    } catch (e) {
      _handleError('Katkı sayısı yüklenirken hata oluştu', e);
    }
  }

  Future<void> loadCollaborations() async {
    try {
      final count = await _contentService.getUserCollaborationsCount();
      collaborationCount.value = count;
    } catch (e) {
      _handleError('İşbirliği sayısı yüklenirken hata oluştu', e);
    }
  }

  // İşbirliği İstekleri
  Future<void> cancelCollaborationRequest(
    GitHubRepositoryModel repository,
    CollaborationRequestModel request,
  ) async {
    try {
      await _contentService.cancelCollaborationRequest(
        repository.owner,
        repository.name,
        request.id,
      );
      Get.back();
      Get.snackbar(
        'Başarılı',
        'İşbirliği isteği iptal edildi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _handleError('İşbirliği isteği iptal edilemedi', e);
    }
  }

  Future<void> submitCollaborationRequest(
    GitHubRepositoryModel repository,
    CollaborationRequestModel? existingRequest,
  ) async {
    try {
      if (selectedCollaborationType.value == null) {
        throw Exception('Lütfen bir işbirliği türü seçin');
      }

      if (messageController.text.trim().isEmpty) {
        throw Exception('Lütfen bir işbirliği mesajı yazın');
      }

      final request = CollaborationRequestModel(
        id: existingRequest?.id ?? CollaborationRequestModel.generateId(),
        repositoryOwner: repository.owner,
        repositoryName: repository.name,
        requesterId: Get.find<AuthController>().currentUser!.uid,
        requesterUsername: Get.find<AuthController>().currentUser!.displayName!,
        collaborationType: selectedCollaborationType.value!,
        message: messageController.text.trim(),
        requiredSkills: selectedSkills,
        createdAt: DateTime.now(),
        status: 'pending',
      );

      if (existingRequest != null) {
        await _contentService.updateCollaborationRequest(
          repository.owner,
          repository.name,
          request,
        );
      } else {
        await _contentService.createCollaborationRequest(
          repository.owner,
          repository.name,
          request,
        );
      }

      Get.back();
      Get.snackbar(
        'Başarılı',
        existingRequest != null
            ? 'İşbirliği isteği güncellendi'
            : 'İşbirliği isteği gönderildi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _handleError('İşbirliği isteği gönderilemedi', e);
    }
  }
}
