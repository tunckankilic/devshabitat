import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/community/community_model.dart';
import '../../models/user_model.dart';
import '../../services/community/community_service.dart';
import '../../services/community/membership_service.dart';
import '../../services/storage_service.dart';
import '../../routes/app_pages.dart';

class CommunityManageController extends GetxController {
  final CommunityService _communityService = Get.find<CommunityService>();
  final MembershipService _membershipService = Get.find<MembershipService>();
  final StorageService _storageService = Get.find<StorageService>();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final coverImageUrl = RxnString();
  final selectedCategories = <String>[].obs;
  final requiresApproval = true.obs;
  final isPrivate = false.obs;
  final isLoading = false.obs;
  final error = ''.obs;

  final members = <UserModel>[].obs;
  final pendingMembers = <UserModel>[].obs;

  String? _selectedImagePath;
  late String communityId;

  List<String> get availableCategories => _communityService.getCategories();

  @override
  void onInit() {
    super.onInit();
    communityId = Get.arguments as String;
    loadCommunity();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> loadCommunity() async {
    try {
      isLoading.value = true;
      error.value = '';

      final community = await _communityService.getCommunity(communityId);

      nameController.text = community.name;
      descriptionController.text = community.description;
      coverImageUrl.value = community.coverImageUrl;
      selectedCategories.value =
          List<String>.from(community.settings['categories'] ?? []);
      requiresApproval.value = community.settings['requiresApproval'] ?? true;
      isPrivate.value = community.settings['isPrivate'] ?? false;

      await loadMembers();
      await loadPendingMembers();
    } catch (e) {
      error.value = 'Topluluk bilgileri yüklenirken bir hata oluştu: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMembers() async {
    try {
      final membersList =
          await _membershipService.getCommunityMembersDetailed(communityId);
      members.assignAll(membersList);
    } catch (e) {
      error.value = 'Üyeler yüklenirken bir hata oluştu: $e';
    }
  }

  Future<void> loadPendingMembers() async {
    try {
      final pendingList =
          await _membershipService.getPendingMembers(communityId);
      pendingMembers.assignAll(pendingList);
    } catch (e) {
      error.value = 'Bekleyen üyeler yüklenirken bir hata oluştu: $e';
    }
  }

  void onCoverImageSelected(String imagePath) {
    _selectedImagePath = imagePath;
  }

  Future<void> updateCommunity() async {
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

      String? newCoverImageUrl = coverImageUrl.value;
      if (_selectedImagePath != null) {
        newCoverImageUrl = await _storageService.uploadCommunityImage(
          _selectedImagePath!,
          'community_covers',
        );
      }

      final community = CommunityModel(
        id: communityId,
        name: nameController.text,
        description: descriptionController.text,
        coverImageUrl: newCoverImageUrl,
        creatorId: '', // Mevcut değeri koru
        moderatorIds: [], // Mevcut değeri koru
        memberIds: [], // Mevcut değeri koru
        pendingMemberIds: [], // Mevcut değeri koru
        settings: {
          'requiresApproval': requiresApproval.value,
          'isPrivate': isPrivate.value,
          'categories': selectedCategories.toList(),
        },
        createdAt: DateTime.now(), // Mevcut değeri koru
        updatedAt: DateTime.now(),
        memberCount: 0, // Mevcut değeri koru
        eventCount: 0, // Mevcut değeri koru
        postCount: 0, // Mevcut değeri koru
      );

      await _communityService.updateCommunity(community);

      Get.snackbar(
        'Başarılı',
        'Topluluk başarıyla güncellendi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Topluluk güncellenirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCommunity() async {
    try {
      isLoading.value = true;

      await _communityService.deleteCommunity(communityId);

      Get.snackbar(
        'Başarılı',
        'Topluluk başarıyla silindi',
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Topluluk silinirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptMember(UserModel user) async {
    try {
      await _membershipService.acceptMembership(
        communityId: communityId,
        userId: user.id,
      );

      pendingMembers.remove(user);
      await loadMembers();

      Get.snackbar(
        'Başarılı',
        'Üyelik talebi kabul edildi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Üyelik talebi kabul edilirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> rejectMember(UserModel user) async {
    try {
      await _membershipService.rejectMembership(
        communityId: communityId,
        userId: user.id,
      );

      pendingMembers.remove(user);

      Get.snackbar(
        'Başarılı',
        'Üyelik talebi reddedildi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Üyelik talebi reddedilirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> removeMember(UserModel user) async {
    try {
      await _membershipService.removeMember(
        communityId: communityId,
        userId: user.id,
      );

      await loadMembers();

      Get.snackbar(
        'Başarılı',
        'Üye topluluktan çıkarıldı',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Üye çıkarılırken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> promoteToModerator(UserModel user) async {
    try {
      await _membershipService.promoteToModerator(
        communityId: communityId,
        userId: user.id,
      );

      await loadCommunity();

      Get.snackbar(
        'Başarılı',
        'Üye moderatör yapıldı',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Moderatör atanırken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void showMemberProfile(UserModel user) {
    // TODO: Implement user profile navigation
  }
}
