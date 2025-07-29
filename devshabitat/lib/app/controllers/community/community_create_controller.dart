import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../models/community/community_model.dart';
import '../../services/community/community_service.dart';
import '../../services/storage_service.dart';
import '../../routes/app_pages.dart';

class CommunityCreateController extends GetxController {
  final CommunityService _communityService = Get.find<CommunityService>();
  final AuthRepository _authService = Get.find<AuthRepository>();
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
    // Form validasyonu ve güvenlik kontrolleri
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      Get.snackbar(
        'Hata',
        'Form verilerinde hata var, lütfen kontrol edin',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Kategori kontrolü
    if (selectedCategories.isEmpty) {
      Get.snackbar(
        'Hata',
        'En az bir kategori seçmelisiniz',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Kullanıcı doğrulama
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      Get.snackbar(
        'Hata',
        'Oturum açmanız gerekmektedir',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Input validasyonu
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        'Hata',
        'Topluluk adı boş olamaz',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (name.length < 3) {
      Get.snackbar(
        'Hata',
        'Topluluk adı en az 3 karakter olmalıdır',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (name.length > 50) {
      Get.snackbar(
        'Hata',
        'Topluluk adı en fazla 50 karakter olabilir',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (description.isEmpty) {
      Get.snackbar(
        'Hata',
        'Topluluk açıklaması boş olamaz',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (description.length > 500) {
      Get.snackbar(
        'Hata',
        'Topluluk açıklaması en fazla 500 karakter olabilir',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      String? coverImageUrl;
      if (_selectedImagePath != null) {
        coverImageUrl = await _storageService.uploadCommunityImage(
          _selectedImagePath!,
          'community_covers',
        );
      }

      final community = CommunityModel(
        id: '', // Firestore tarafından otomatik oluşturulacak
        name: name,
        description: description,
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
        AppRoutes.COMMUNITY_DETAIL,
        arguments: createdCommunity.id,
      );
    } on FirebaseException catch (e) {
      Get.snackbar(
        'Hata',
        'Firebase hatası: ${e.message}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on Exception catch (e) {
      Get.snackbar(
        'Hata',
        'Bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Topluluk oluşturulurken beklenmeyen bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
