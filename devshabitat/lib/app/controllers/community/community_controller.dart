import 'package:devshabitat/app/models/user_profile_model.dart';
import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devshabitat/app/models/community/community_model.dart';
import 'package:devshabitat/app/models/community/community_settings_model.dart';
import 'package:devshabitat/app/models/community/membership_model.dart';
import 'package:devshabitat/app/services/community/community_service.dart';
import 'package:devshabitat/app/services/community/membership_service.dart';
import 'package:devshabitat/app/services/community/moderation_service.dart';
import 'package:devshabitat/app/models/community/moderation_model.dart';

import '../../core/base/base_community_controller.dart';

class CommunityController extends BaseCommunityController {
  final CommunityService _communityService = Get.find<CommunityService>();
  final MembershipService _membershipService = Get.find<MembershipService>();
  final ModerationService _moderationService = ModerationService();
  final AuthRepository _authService = Get.find<AuthRepository>();

  final community = Rxn<CommunityModel>();
  final communitySettings = Rx<CommunitySettingsModel?>(null);
  final membershipStatus = Rx<MembershipModel?>(null);
  final isUserModerator = false.obs;
  final isMember = false.obs;
  final members = <UserProfile>[].obs;
  final pendingMembers = <UserProfile>[].obs;

  @override
  void onInit() {
    super.onInit();
    final communityId = Get.arguments as String;
    loadCommunity(communityId);
  }

  Future<void> loadCommunity(String communityId) async {
    await handleAsync(
      operation: () async {
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
        final settings = await _communityService.getCommunitySettings(
          communityId,
        );
        communitySettings.value = settings;

        // Load membership status for current user
        if (currentUser != null) {
          final membership = await _membershipService.getMemberStatus(
            communityId: communityId,
            userId: currentUser.uid,
          );
          membershipStatus.value = membership;
        }
      },
      successMessage: 'Topluluk bilgileri başarıyla yüklendi',
    );
  }

  Future<void> loadMembers() async {
    if (community.value == null) return;

    await handleAsync(
      operation: () async {
        final membersList = await _membershipService
            .getCommunityMembersDetailed(community.value!.id);
        members.assignAll(membersList);
      },
      showLoading: false,
    );
  }

  Future<void> loadPendingMembers() async {
    if (community.value == null) return;

    await handleAsync(
      operation: () async {
        final pendingList = await _membershipService.getPendingMembers(
          community.value!.id,
        );
        pendingMembers.assignAll(pendingList);
      },
      showLoading: false,
    );
  }

  Future<void> joinCommunity() async {
    if (community.value == null) return;

    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      setError('Oturum açmanız gerekmektedir');
      return;
    }

    await handleAsync(
      operation: () async {
        await _membershipService.requestMembership(
          communityId: community.value!.id,
          userId: currentUser.uid,
        );
      },
      successMessage: 'Üyelik talebiniz gönderildi',
    );
  }

  Future<void> leaveCommunity() async {
    if (community.value == null) return;

    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      setError('Oturum açmanız gerekmektedir');
      return;
    }

    await handleAsync(
      operation: () async {
        await _membershipService.removeMember(
          communityId: community.value!.id,
          userId: currentUser.uid,
        );

        isMember.value = false;
        await loadMembers();
      },
      successMessage: 'Topluluktan ayrıldınız',
    );
  }

  Future<void> acceptMember(UserProfile user) async {
    if (community.value == null) return;

    await handleAsync(
      operation: () async {
        await _membershipService.acceptMembership(
          communityId: community.value!.id,
          userId: user.id,
        );

        pendingMembers.remove(user);
        await loadMembers();
      },
      successMessage: 'Üyelik talebi kabul edildi',
    );
  }

  Future<void> rejectMember(UserProfile user) async {
    if (community.value == null) return;

    await handleAsync(
      operation: () async {
        await _membershipService.rejectMembership(
          communityId: community.value!.id,
          userId: user.id,
        );

        pendingMembers.remove(user);
      },
      successMessage: 'Üyelik talebi reddedildi',
    );
  }

  Future<void> removeMember(UserProfile user) async {
    if (community.value == null) return;

    await handleAsync(
      operation: () async {
        await _membershipService.removeMember(
          communityId: community.value!.id,
          userId: user.id,
        );

        await loadMembers();
      },
      successMessage: 'Üye topluluktan çıkarıldı',
    );
  }

  Future<void> promoteToModerator(UserProfile user) async {
    if (community.value == null) return;

    await handleAsync(
      operation: () async {
        await _membershipService.promoteToModerator(
          communityId: community.value!.id,
          userId: user.id,
        );

        await loadCommunity(community.value!.id);
      },
      successMessage: 'Üye moderatör yapıldı',
    );
  }

  void showMemberProfile(UserProfile user) {
    navigateToUserProfile(user.id);
  }

  void navigateToUserProfile(String userId) {
    Get.toNamed('/profile/$userId');
  }

  // Update community settings
  Future<void> updateSettings(CommunitySettingsModel newSettings) async {
    if (community.value == null) return;

    await handleAsync(
      operation: () async {
        await _communityService.updateCommunitySettings(newSettings);
        communitySettings.value = newSettings;
      },
      successMessage: 'Topluluk ayarları güncellendi',
    );
  }

  // Report content
  Future<void> reportContent({
    required String contentId,
    required ModerationReason reason,
    required ContentType contentType,
  }) async {
    if (community.value == null) return;

    final userId = Get.find<String>();

    await handleAsync(
      operation: () async {
        await _moderationService.reportContent(
          communityId: community.value!.id,
          contentId: contentId,
          reporterId: userId,
          reason: reason,
          contentType: contentType,
        );
      },
      successMessage: 'İçerik moderatörlere bildirildi',
    );
  }

  // Check if user can moderate
  Future<bool> canModerate() async {
    if (community.value == null) return false;

    final userId = Get.find<String>();
    final result = await handleAsync<bool>(
      operation: () async {
        return await _moderationService.canModerate(
          communityId: community.value!.id,
          userId: userId,
        );
      },
      showLoading: false,
    );

    return result ?? false;
  }

  // Get community members
  Future<List<UserProfile>> getMembers({
    MembershipRole? role,
    MembershipStatus? status,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    if (community.value == null) return [];

    final result = await handleAsync<List<UserProfile>>(
      operation: () async {
        return await _membershipService.getCommunityMembersDetailed(
          community.value!.id,
        );
      },
      showLoading: false,
    );

    return result ?? [];
  }
}
