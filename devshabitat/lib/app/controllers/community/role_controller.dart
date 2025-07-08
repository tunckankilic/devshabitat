import 'package:devshabitat/app/models/user_profile_model.dart';
import 'package:get/get.dart';
import '../../models/community/role_model.dart';
import '../../services/community/role_service.dart';
import '../../services/community/membership_service.dart';

class RoleController extends GetxController {
  final RoleService _roleService = Get.find<RoleService>();
  final MembershipService _membershipService = Get.find<MembershipService>();

  final roles = <RoleModel>[].obs;
  final members = <UserProfile>[].obs;
  final selectedRole = Rxn<RoleModel>();
  final isLoading = false.obs;
  final error = ''.obs;

  late final String communityId;

  @override
  void onInit() {
    super.onInit();
    communityId = Get.arguments as String;
    loadRoles();
    loadMembers();
  }

  // Rolleri yükle
  Future<void> loadRoles() async {
    try {
      isLoading.value = true;
      error.value = '';

      final communityRoles = await _roleService.getCommunityRoles(communityId);
      roles.assignAll(communityRoles);
    } catch (e) {
      error.value = 'Roller yüklenirken bir hata oluştu: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Üyeleri yükle
  Future<void> loadMembers() async {
    try {
      isLoading.value = true;
      error.value = '';

      final communityMembers =
          await _membershipService.getCommunityMembersDetailed(communityId);
      members.assignAll(communityMembers);
    } catch (e) {
      error.value = 'Üyeler yüklenirken bir hata oluştu: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Yeni rol oluştur
  Future<void> createRole(RoleModel role) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _roleService.createRole(role);
      await loadRoles();

      Get.back();
      Get.snackbar(
        'Başarılı',
        'Rol başarıyla oluşturuldu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Rol oluşturulurken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Rol oluşturulurken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Rol güncelle
  Future<void> updateRole(RoleModel role) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _roleService.updateRole(role);
      await loadRoles();

      Get.back();
      Get.snackbar(
        'Başarılı',
        'Rol başarıyla güncellendi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Rol güncellenirken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Rol güncellenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Rol sil
  Future<void> deleteRole(String roleId) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _roleService.deleteRole(communityId, roleId);
      await loadRoles();

      Get.back();
      Get.snackbar(
        'Başarılı',
        'Rol başarıyla silindi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Rol silinirken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Rol silinirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Üyeye rol ata
  Future<void> assignRole(String userId, String roleId) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _roleService.assignRole(communityId, userId, roleId);
      await loadMembers();

      Get.snackbar(
        'Başarılı',
        'Rol başarıyla atandı',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Rol atanırken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Rol atanırken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Üyeden rol kaldır
  Future<void> removeRole(String userId, String roleId) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _roleService.removeRole(communityId, userId, roleId);
      await loadMembers();

      Get.snackbar(
        'Başarılı',
        'Rol başarıyla kaldırıldı',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Rol kaldırılırken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Rol kaldırılırken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Üyenin rollerini getir
  Future<List<RoleModel>> getMemberRoles(String userId) async {
    try {
      return await _roleService.getMemberRoles(communityId, userId);
    } catch (e) {
      error.value = 'Üye rolleri yüklenirken bir hata oluştu: $e';
      return [];
    }
  }

  // Üyenin izinlerini getir
  Future<Set<RolePermission>> getMemberPermissions(String userId) async {
    try {
      return await _roleService.getMemberPermissions(communityId, userId);
    } catch (e) {
      error.value = 'Üye izinleri yüklenirken bir hata oluştu: $e';
      return {};
    }
  }

  // Üyenin belirli bir izne sahip olup olmadığını kontrol et
  Future<bool> hasPermission(String userId, RolePermission permission) async {
    try {
      return await _roleService.hasPermission(communityId, userId, permission);
    } catch (e) {
      error.value = 'İzin kontrolü yapılırken bir hata oluştu: $e';
      return false;
    }
  }

  // Rol yönetimi yetkisini kontrol et
  Future<bool> canManageRole(String userId, String targetRoleId) async {
    try {
      return await _roleService.canManageRole(
          communityId, userId, targetRoleId);
    } catch (e) {
      error.value = 'Yetki kontrolü yapılırken bir hata oluştu: $e';
      return false;
    }
  }
}
