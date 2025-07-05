import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devshabitat/app/models/community/community_model.dart';
import 'package:devshabitat/app/models/community/community_settings_model.dart';
import 'package:devshabitat/app/models/community/membership_model.dart';
import 'package:devshabitat/app/services/community/community_service.dart';
import 'package:devshabitat/app/services/community/membership_service.dart';
import 'package:devshabitat/app/services/community/moderation_service.dart';
import 'package:devshabitat/app/models/user_model.dart';
import 'package:devshabitat/app/models/community/moderation_model.dart';

class CommunityController extends GetxController {
  final CommunityService _communityService = Get.find<CommunityService>();
  final MembershipService _membershipService = Get.find<MembershipService>();
  final ModerationService _moderationService = ModerationService();
  final AuthRepository _authService = Get.find<AuthRepository>();

  final community = Rxn<CommunityModel>();
  final communitySettings = Rx<CommunitySettingsModel?>(null);
  final membershipStatus = Rx<MembershipModel?>(null);
  final isLoading = false.obs;
  final error = ''.obs;
  final isUserModerator = false.obs;
  final isMember = false.obs;
  final members = <UserModel>[].obs;
  final pendingMembers = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    final communityId = Get.arguments as String;
    loadCommunity(communityId);
  }

  Future<void> loadCommunity(String communityId) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Topluluk bilgilerini yükle
      community.value = await _communityService.getCommunity(communityId);

      // Kullanıcı rollerini kontrol et
      final currentUser = _authService.currentUser;
      if (currentUser != null && community.value != null) {
        isUserModerator.value = community.value!.isModerator(currentUser.uid);
        isMember.value = community.value!.isMember(currentUser.uid);
      }

      // Üyeleri yükle
      await loadMembers();

      // Moderatör ise bekleyen üyeleri yükle
      if (isUserModerator.value) {
        await loadPendingMembers();
      }

      // Load community settings
      final settings =
          await _communityService.getCommunitySettings(communityId);
      communitySettings.value = settings;

      // Load membership status for current user
      if (currentUser != null) {
        final membership = await _membershipService.getMemberStatus(
          communityId: communityId,
          userId: currentUser.uid,
        );
        membershipStatus.value = membership;
      }
    } catch (e) {
      error.value = 'Topluluk bilgileri yüklenirken bir hata oluştu: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMembers() async {
    try {
      if (community.value == null) return;

      final membersList = await _membershipService
          .getCommunityMembersDetailed(community.value!.id);
      members.assignAll(membersList);
    } catch (e) {
      error.value = 'Üyeler yüklenirken bir hata oluştu: $e';
    }
  }

  Future<void> loadPendingMembers() async {
    try {
      if (community.value == null) return;

      final pendingList = await _membershipService.getPendingMembers(
        community.value!.id,
      );
      pendingMembers.assignAll(pendingList);
    } catch (e) {
      error.value = 'Bekleyen üyeler yüklenirken bir hata oluştu: $e';
    }
  }

  Future<void> joinCommunity() async {
    try {
      if (community.value == null) return;

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        error.value = 'Oturum açmanız gerekmektedir';
        return;
      }

      await _membershipService.requestMembership(
        communityId: community.value!.id,
        userId: currentUser.uid,
      );

      Get.snackbar(
        'Başarılı',
        'Üyelik talebiniz gönderildi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Topluluğa katılırken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Topluluğa katılırken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> leaveCommunity() async {
    try {
      if (community.value == null) return;

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        error.value = 'Oturum açmanız gerekmektedir';
        return;
      }

      await _membershipService.removeMember(
        communityId: community.value!.id,
        userId: currentUser.uid,
      );

      isMember.value = false;
      await loadMembers();

      Get.snackbar(
        'Başarılı',
        'Topluluktan ayrıldınız',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Topluluktan ayrılırken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Topluluktan ayrılırken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> acceptMember(UserModel user) async {
    try {
      if (community.value == null) return;

      await _membershipService.acceptMembership(
        communityId: community.value!.id,
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
      error.value = 'Üyelik talebi kabul edilirken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Üyelik talebi kabul edilirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> rejectMember(UserModel user) async {
    try {
      if (community.value == null) return;

      await _membershipService.rejectMembership(
        communityId: community.value!.id,
        userId: user.id,
      );

      pendingMembers.remove(user);

      Get.snackbar(
        'Başarılı',
        'Üyelik talebi reddedildi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Üyelik talebi reddedilirken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Üyelik talebi reddedilirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> removeMember(UserModel user) async {
    try {
      if (community.value == null) return;

      await _membershipService.removeMember(
        communityId: community.value!.id,
        userId: user.id,
      );

      await loadMembers();

      Get.snackbar(
        'Başarılı',
        'Üye topluluktan çıkarıldı',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Üye çıkarılırken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Üye çıkarılırken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> promoteToModerator(UserModel user) async {
    try {
      if (community.value == null) return;

      await _membershipService.promoteToModerator(
        communityId: community.value!.id,
        userId: user.id,
      );

      await loadCommunity(community.value!.id);

      Get.snackbar(
        'Başarılı',
        'Üye moderatör yapıldı',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Moderatör atanırken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Moderatör atanırken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void showMemberProfile(UserModel user) {
    navigateToUserProfile(user.id);
  }

  void navigateToUserProfile(String userId) {
    Get.toNamed('/profile/$userId');
  }

  // Update community settings
  Future<void> updateSettings(CommunitySettingsModel newSettings) async {
    if (community.value == null) return;

    try {
      isLoading.value = true;
      await _communityService.updateCommunitySettings(newSettings);
      communitySettings.value = newSettings;
      Get.snackbar('Başarılı', 'Topluluk ayarları güncellendi');
    } catch (e) {
      Get.snackbar('Hata', 'Ayarlar güncellenirken bir hata oluştu');
    } finally {
      isLoading.value = false;
    }
  }

  // Report content
  Future<void> reportContent({
    required String contentId,
    required ModerationReason reason,
    required ContentType contentType,
  }) async {
    if (community.value == null) return;

    try {
      isLoading.value = true;
      final userId = Get.find<String>();

      await _moderationService.reportContent(
        communityId: community.value!.id,
        contentId: contentId,
        reporterId: userId,
        reason: reason,
        contentType: contentType,
      );

      Get.snackbar('Başarılı', 'İçerik moderatörlere bildirildi');
    } catch (e) {
      Get.snackbar('Hata', 'İçerik bildirilirken bir hata oluştu');
    } finally {
      isLoading.value = false;
    }
  }

  // Check if user can moderate
  Future<bool> canModerate() async {
    if (community.value == null) return false;

    try {
      final userId = Get.find<String>();
      return await _moderationService.canModerate(
        communityId: community.value!.id,
        userId: userId,
      );
    } catch (e) {
      return false;
    }
  }

  // Get community members
  Future<List<UserModel>> getMembers({
    MembershipRole? role,
    MembershipStatus? status,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    if (community.value == null) return [];

    try {
      final memberships = await _membershipService
          .getCommunityMembersDetailed(community.value!.id);
      return memberships;
    } catch (e) {
      Get.snackbar('Hata', 'Üyeler yüklenirken bir hata oluştu');
      return [];
    }
  }
}
