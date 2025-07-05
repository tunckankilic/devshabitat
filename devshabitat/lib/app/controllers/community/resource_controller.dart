import 'package:get/get.dart';
import '../../models/community/resource_model.dart';
import '../../services/community/resource_service.dart';

class ResourceController extends GetxController {
  final ResourceService _resourceService = Get.find<ResourceService>();

  final resources = <ResourceModel>[].obs;
  final featuredResources = <ResourceModel>[].obs;
  final popularResources = <ResourceModel>[].obs;
  final trendingResources = <ResourceModel>[].obs;
  final selectedResource = Rxn<ResourceModel>();
  final selectedType = Rx<ResourceType?>(null);
  final selectedCategory = Rx<ResourceCategory?>(null);
  final selectedDifficulty = Rx<ResourceDifficulty?>(null);
  final selectedTag = RxnString();
  final searchQuery = ''.obs;
  final isLoading = false.obs;
  final error = ''.obs;

  late final String communityId;
  late final String userId;

  @override
  void onInit() {
    super.onInit();
    communityId = Get.arguments['communityId'] as String;
    userId = Get.arguments['userId'] as String;
    loadResources();
  }

  // Kaynakları yükle
  Future<void> loadResources() async {
    try {
      isLoading.value = true;
      error.value = '';

      await Future.wait([
        loadAllResources(),
        loadFeaturedResources(),
        loadPopularResources(),
        loadTrendingResources(),
      ]);
    } catch (e) {
      error.value = 'Kaynaklar yüklenirken bir hata oluştu: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Tüm kaynakları yükle
  Future<void> loadAllResources() async {
    try {
      final allResources = await _resourceService.getResources(
        communityId,
        type: selectedType.value,
        category: selectedCategory.value,
        difficulty: selectedDifficulty.value,
        tag: selectedTag.value,
      );
      resources.assignAll(allResources);
    } catch (e) {
      error.value = 'Kaynaklar yüklenirken bir hata oluştu: $e';
    }
  }

  // Öne çıkan kaynakları yükle
  Future<void> loadFeaturedResources() async {
    try {
      final featured = await _resourceService.getFeaturedResources(communityId);
      featuredResources.assignAll(featured);
    } catch (e) {
      error.value = 'Öne çıkan kaynaklar yüklenirken bir hata oluştu: $e';
    }
  }

  // Popüler kaynakları yükle
  Future<void> loadPopularResources() async {
    try {
      final popular = await _resourceService.getPopularResources(communityId);
      popularResources.assignAll(popular);
    } catch (e) {
      error.value = 'Popüler kaynaklar yüklenirken bir hata oluştu: $e';
    }
  }

  // Trend olan kaynakları yükle
  Future<void> loadTrendingResources() async {
    try {
      final trending = await _resourceService.getTrendingResources(communityId);
      trendingResources.assignAll(trending);
    } catch (e) {
      error.value = 'Trend kaynaklar yüklenirken bir hata oluştu: $e';
    }
  }

  // Yeni kaynak oluştur
  Future<void> createResource(ResourceModel resource) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _resourceService.createResource(resource);
      await loadResources();

      Get.back();
      Get.snackbar(
        'Başarılı',
        'Kaynak başarıyla oluşturuldu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Kaynak oluşturulurken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Kaynak oluşturulurken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Kaynağı güncelle
  Future<void> updateResource(ResourceModel resource) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _resourceService.updateResource(resource);
      await loadResources();

      Get.back();
      Get.snackbar(
        'Başarılı',
        'Kaynak başarıyla güncellendi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Kaynak güncellenirken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Kaynak güncellenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Kaynağı sil
  Future<void> deleteResource(String resourceId) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _resourceService.deleteResource(communityId, resourceId);
      await loadResources();

      Get.back();
      Get.snackbar(
        'Başarılı',
        'Kaynak başarıyla silindi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Kaynak silinirken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Kaynak silinirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Kaynağı oyla
  Future<void> voteResource(String resourceId, bool isUpvote) async {
    try {
      await _resourceService.voteResource(
        communityId: communityId,
        resourceId: resourceId,
        userId: userId,
        isUpvote: isUpvote,
      );

      await loadResources();
    } catch (e) {
      error.value = 'Oylama yapılırken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Oylama yapılırken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Görüntülenme sayısını artır
  Future<void> incrementViews(String resourceId) async {
    try {
      await _resourceService.incrementViews(communityId, resourceId);
    } catch (e) {
      print('Görüntülenme sayısı artırılırken bir hata oluştu: $e');
    }
  }

  // Kaynağı öne çıkar
  Future<void> toggleFeatured(String resourceId) async {
    try {
      await _resourceService.toggleFeatured(communityId, resourceId);
      await loadResources();

      Get.snackbar(
        'Başarılı',
        'Kaynak durumu güncellendi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Kaynak durumu güncellenirken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Kaynak durumu güncellenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Kaynağı sabitle
  Future<void> togglePinned(String resourceId) async {
    try {
      await _resourceService.togglePinned(communityId, resourceId);
      await loadResources();

      Get.snackbar(
        'Başarılı',
        'Kaynak durumu güncellendi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Kaynak durumu güncellenirken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Kaynak durumu güncellenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Kaynağı onayla
  Future<void> approveResource(String resourceId) async {
    try {
      await _resourceService.approveResource(communityId, resourceId);
      await loadResources();

      Get.snackbar(
        'Başarılı',
        'Kaynak onaylandı',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Kaynak onaylanırken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Kaynak onaylanırken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Kaynak onayını kaldır
  Future<void> unapproveResource(String resourceId) async {
    try {
      await _resourceService.unapproveResource(communityId, resourceId);
      await loadResources();

      Get.snackbar(
        'Başarılı',
        'Kaynak onayı kaldırıldı',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Kaynak onayı kaldırılırken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Kaynak onayı kaldırılırken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Kaynak yönetimi yetkisini kontrol et
  Future<bool> canManageResources() async {
    try {
      return await _resourceService.canManageResources(communityId, userId);
    } catch (e) {
      error.value = 'Yetki kontrolü yapılırken bir hata oluştu: $e';
      return false;
    }
  }

  // Kaynak oluşturma yetkisini kontrol et
  Future<bool> canCreateResources() async {
    try {
      return await _resourceService.canCreateResources(communityId, userId);
    } catch (e) {
      error.value = 'Yetki kontrolü yapılırken bir hata oluştu: $e';
      return false;
    }
  }

  // Kaynak düzenleme yetkisini kontrol et
  Future<bool> canEditResource(String resourceId) async {
    try {
      return await _resourceService.canEditResource(
        communityId,
        userId,
        resourceId,
      );
    } catch (e) {
      error.value = 'Yetki kontrolü yapılırken bir hata oluştu: $e';
      return false;
    }
  }

  // Kaynak silme yetkisini kontrol et
  Future<bool> canDeleteResource(String resourceId) async {
    try {
      return await _resourceService.canDeleteResource(
        communityId,
        userId,
        resourceId,
      );
    } catch (e) {
      error.value = 'Yetki kontrolü yapılırken bir hata oluştu: $e';
      return false;
    }
  }

  // Filtreleri sıfırla
  void resetFilters() {
    selectedType.value = null;
    selectedCategory.value = null;
    selectedDifficulty.value = null;
    selectedTag.value = null;
    searchQuery.value = '';
    loadResources();
  }

  // Kaynak türünü metne çevir
  String getResourceTypeText(ResourceType type) {
    switch (type) {
      case ResourceType.article:
        return 'Makale';
      case ResourceType.video:
        return 'Video';
      case ResourceType.tutorial:
        return 'Eğitim';
      case ResourceType.code:
        return 'Kod';
      case ResourceType.book:
        return 'Kitap';
      case ResourceType.tool:
        return 'Araç';
      case ResourceType.other:
        return 'Diğer';
    }
  }

  // Kaynak kategorisini metne çevir
  String getResourceCategoryText(ResourceCategory category) {
    switch (category) {
      case ResourceCategory.frontend:
        return 'Frontend';
      case ResourceCategory.backend:
        return 'Backend';
      case ResourceCategory.mobile:
        return 'Mobil';
      case ResourceCategory.devops:
        return 'DevOps';
      case ResourceCategory.design:
        return 'Tasarım';
      case ResourceCategory.database:
        return 'Veritabanı';
      case ResourceCategory.security:
        return 'Güvenlik';
      case ResourceCategory.testing:
        return 'Test';
      case ResourceCategory.architecture:
        return 'Mimari';
      case ResourceCategory.other:
        return 'Diğer';
    }
  }

  // Kaynak zorluğunu metne çevir
  String getResourceDifficultyText(ResourceDifficulty difficulty) {
    switch (difficulty) {
      case ResourceDifficulty.beginner:
        return 'Başlangıç';
      case ResourceDifficulty.intermediate:
        return 'Orta';
      case ResourceDifficulty.advanced:
        return 'İleri';
      case ResourceDifficulty.expert:
        return 'Uzman';
    }
  }
}
