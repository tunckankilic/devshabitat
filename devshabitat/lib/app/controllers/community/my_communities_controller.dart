import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:get/get.dart';
import '../../models/community/community_model.dart';
import '../../services/community/community_service.dart';

class MyCommunitiesController extends GetxController {
  final CommunityService _communityService = Get.find<CommunityService>();
  final AuthRepository _authService = Get.find<AuthRepository>();

  final memberCommunities = <CommunityModel>[].obs;
  final managedCommunities = <CommunityModel>[].obs;
  final isLoadingMemberships = false.obs;
  final isLoadingManaged = false.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCommunities();
  }

  Future<void> loadCommunities() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      error.value = 'Oturum açmanız gerekmektedir';
      return;
    }

    await Future.wait([
      loadMemberCommunities(currentUser.uid),
      loadManagedCommunities(currentUser.uid),
    ]);
  }

  Future<void> loadMemberCommunities(String userId) async {
    try {
      isLoadingMemberships.value = true;
      error.value = '';

      final communities = await _communityService.getUserCommunities(userId);
      memberCommunities.assignAll(communities);
    } catch (e) {
      error.value = 'Üye olunan topluluklar yüklenirken bir hata oluştu: $e';
    } finally {
      isLoadingMemberships.value = false;
    }
  }

  Future<void> loadManagedCommunities(String userId) async {
    try {
      isLoadingManaged.value = true;
      error.value = '';

      final communities = await _communityService.getManagedCommunities(userId);
      managedCommunities.assignAll(communities);
    } catch (e) {
      error.value = 'Yönetilen topluluklar yüklenirken bir hata oluştu: $e';
    } finally {
      isLoadingManaged.value = false;
    }
  }
}
