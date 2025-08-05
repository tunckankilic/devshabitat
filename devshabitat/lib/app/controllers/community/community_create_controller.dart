import 'dart:io';
import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../models/community/community_model.dart';
import '../../services/community/community_service.dart';
import '../../services/storage_service.dart';
import '../../routes/app_pages.dart';

import '../../core/mixins/form_validation_mixin.dart';
import '../../core/config/validation_config.dart';
import '../../core/error/validation_error.dart';
import '../../core/services/validation_service.dart';

class CommunityCreateController extends GetxController
    with FormValidationMixin {
  final CommunityService _communityService = Get.find<CommunityService>();
  final AuthRepository _authService = Get.find<AuthRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  final coverImageUrl = RxnString();
  final selectedCategories = <String>[].obs;
  final requiresApproval = true.obs;
  final isPrivate = false.obs;
  final isLoading = false.obs;

  String? _selectedImagePath;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController()
      ..addListener(() {
        validateName(nameController.text);
        markFormDirty();
      });

    descriptionController = TextEditingController()
      ..addListener(() {
        validateDescription(descriptionController.text);
        markFormDirty();
      });
  }

  // Form validasyonları
  Future<void> validateName(String value) async {
    final validationService = Get.find<ValidationService>();
    final error = validationService.validateText(
      value,
      fieldName: 'Topluluk adı',
      minLength: ValidationConfig.minCommunityNameLength,
      maxLength: ValidationConfig.maxCommunityNameLength,
    );

    if (error == null && isFormDirty.value) {
      final uniquenessError = await validationService
          .validateCommunityNameUniqueness(value);
      if (uniquenessError != null) {
        setError('name', uniquenessError);
        return;
      }
    }

    setError('name', error);
  }

  void validateDescription(String value) {
    final validationService = Get.find<ValidationService>();
    final error = validationService.validateText(
      value,
      fieldName: 'Açıklama',
      minLength: ValidationConfig.minCommunityDescriptionLength,
      maxLength: ValidationConfig.maxCommunityDescriptionLength,
    );
    setError('description', error);
  }

  @override
  String? validateCategories(List<String> categories) {
    final error = super.validateCategories(categories);
    if (error != null) {
      setError('categories', error);
    }
    return error;
  }

  void validateSelectedCategories() {
    validateCategories(selectedCategories);
  }

  Future<void> validateCoverImage() async {
    if (_selectedImagePath == null) return;

    final file = File(_selectedImagePath!);
    final validationService = Get.find<ValidationService>();
    final error = await validationService.validateFile(
      file,
      allowedExtensions: ValidationConfig.allowedImageExtensions,
      maxSizeInMB: ValidationConfig.maxCoverImageSizeMB,
      isImage: true,
    );
    setError('coverImage', error);
  }

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

  @override
  Future<bool> validateForm() async {
    try {
      // Tüm validasyonları çalıştır
      await validateName(nameController.text);
      validateDescription(descriptionController.text);
      validateSelectedCategories();
      await validateCoverImage();

      // Tüm hataları kontrol et
      return !hasError('name') &&
          !hasError('description') &&
          !hasError('categories') &&
          !hasError('coverImage');
    } catch (e) {
      setError('general', e.toString());
      return false;
    }
  }

  Future<void> createCommunity() async {
    try {
      // Form validasyonu
      if (!await validateForm()) {
        return;
      }

      // Kullanıcı doğrulama
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw ValidationError('Oturum açmanız gerekmektedir');
      }

      // Input sanitizasyonu
      final name = sanitizeInput(nameController.text);
      final description = sanitizeInput(descriptionController.text);

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

      final createdCommunity = await _communityService.createCommunity(
        community,
      );

      Get.snackbar(
        'Başarılı',
        'Topluluk başarıyla oluşturuldu',
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.offNamed(AppRoutes.COMMUNITY_DETAIL, arguments: createdCommunity.id);
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
