import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/community/announcement_model.dart';
import '../../services/community/announcement_service.dart';

class CommunityAnnouncementController extends GetxController {
  final AnnouncementService _announcementService =
      Get.find<AnnouncementService>();

  final RxList<AnnouncementModel> announcements = <AnnouncementModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCategory = 'all'.obs;
  late final TextEditingController titleController;
  late final TextEditingController contentController;

  @override
  void onInit() {
    super.onInit();
    titleController = TextEditingController();
    contentController = TextEditingController();
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }

  // Duyuruları yükle
  Future<void> loadAnnouncements(String communityId) async {
    try {
      isLoading.value = true;

      AnnouncementCategory? category;
      if (selectedCategory.value != 'all') {
        category = AnnouncementCategory.values.firstWhere(
          (e) => e.toString().split('.').last == selectedCategory.value,
        );
      }

      final result = await _announcementService.getAnnouncements(
        communityId,
        category: category,
      );

      announcements.value = result;
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Duyurular yüklenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Yeni duyuru oluştur
  Future<void> createAnnouncement({
    required String communityId,
    required String title,
    required String content,
    required AnnouncementCategory category,
  }) async {
    try {
      await _announcementService.createAnnouncement(
        communityId: communityId,
        title: title,
        content: content,
        category: category,
      );

      // Duyuruları yeniden yükle
      await loadAnnouncements(communityId);

      Get.snackbar(
        'Başarılı',
        'Duyuru başarıyla oluşturuldu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Duyuru oluşturulurken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Duyuru sil
  Future<void> deleteAnnouncement(
    String communityId,
    String announcementId,
  ) async {
    try {
      await _announcementService.deleteAnnouncement(
        communityId,
        announcementId,
      );

      // Duyuruları yeniden yükle
      await loadAnnouncements(communityId);

      Get.snackbar(
        'Başarılı',
        'Duyuru başarıyla silindi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Duyuru silinirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Kategori listesini getir
  List<Map<String, String>> getCategories() {
    final categories = _announcementService.getCategories();
    // Tümü seçeneğini ekle
    categories.insert(0, {'value': 'all', 'display': 'Tümü'});
    return categories;
  }

  // Kategori değiştir
  void changeCategory(String category) {
    selectedCategory.value = category;
  }
}
