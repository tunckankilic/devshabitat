import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/community/community_model.dart';
import '../../services/community/community_service.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../routes/app_routes.dart';

class CommunityCreateController extends GetxController {
  final CommunityService _communityService = Get.find<CommunityService>();
  final AuthService _authService = Get.find<AuthService>();
  final StorageService _storageService = Get.find<StorageService>();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final coverImageUrl = RxnString();
  final selectedCategories = <String>[].obs;
  final requiresApproval = true.obs;
  final isPrivate = false.obs;
  final isLoading = false.obs;

  String? _selectedImagePath;

  List<String> get availableCategories => _communityService.getCategories();

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  void onCoverImageSelected(String imagePath) {
    _selectedImagePath = imagePath;
  }

  Future<void> createCommunity() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedCategories.isEmpty) {
      Get.snackbar(
        'Hata',
        'En az bir kategori seçmelisiniz',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      final currentUser = _authService.currentUser.value;
      if (currentUser == null) {
        throw Exception('Oturum açmanız gerekmektedir');
      }

      String? coverImageUrl;
      if (_selectedImagePath != null) {
        coverImageUrl = await _storageService.uploadCommunityImage(
          _selectedImagePath!,
          'community_covers',
        );
      }

      final community = CommunityModel(
        id: '', // Firestore tarafından otomatik oluşturulacak
        name: nameController.text,
        description: descriptionController.text,
        coverImageUrl: coverImageUrl,
        creatorId: currentUser.uid,
        moderatorIds: [currentUser.uid],
        memberIds: [currentUser.uid],
        pendingMemberIds: [],
        settings: {
          'requiresApproval': requiresApproval.value,
          'isPrivate': isPrivate.value,
          'categories': selectedCategories.toList(),
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        memberCount: 1,
        eventCount: 0,
        postCount: 0,
      );

      final createdCommunity =
          await _communityService.createCommunity(community);

      Get.snackbar(
        'Başarılı',
        'Topluluk başarıyla oluşturuldu',
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.offNamed(
        Routes.COMMUNITY_DETAIL,
        arguments: createdCommunity.id,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Topluluk oluşturulurken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
