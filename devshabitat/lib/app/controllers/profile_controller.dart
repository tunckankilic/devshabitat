import 'package:get/get.dart';
import '../models/developer_profile_model.dart';
import '../models/skill_model.dart';
import '../models/github_stats_model.dart';
import '../services/profile_service.dart';

class ProfileController extends GetxController {
  final ProfileService _profileService = Get.find<ProfileService>();
  final Rx<DeveloperProfile?> _profile = Rx<DeveloperProfile?>(null);
  final RxList<SkillModel> _skills = <SkillModel>[].obs;
  final Rx<GithubStatsModel?> _githubStats = Rx<GithubStatsModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  // Getters
  DeveloperProfile? get profile => _profile.value;
  List<SkillModel> get skills => _skills;
  GithubStatsModel? get githubStats => _githubStats.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  // Profile yükleme
  Future<void> loadProfile(String userId) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      _profile.value = await _profileService.getProfile(userId);
      await loadSkills();
      await loadGithubStats();
    } catch (e) {
      _error.value = 'Profil yüklenirken bir hata oluştu: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  // Yetenekleri yükleme
  Future<void> loadSkills() async {
    try {
      if (_profile.value != null) {
        _skills.value = await _profileService.getSkills(_profile.value!.id);
      }
    } catch (e) {
      _error.value = 'Yetenekler yüklenirken bir hata oluştu: $e';
    }
  }

  // GitHub istatistiklerini yükleme
  Future<void> loadGithubStats() async {
    try {
      if (_profile.value != null) {
        final githubUsername =
            _profile.value!.githubStats['username'] as String?;
        if (githubUsername != null) {
          _githubStats.value =
              await _profileService.getGithubStats(githubUsername);
        }
      }
    } catch (e) {
      _error.value = 'GitHub istatistikleri yüklenirken bir hata oluştu: $e';
    }
  }

  // Profil güncelleme
  Future<void> updateProfile(DeveloperProfile updatedProfile) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      await _profileService.updateProfile(updatedProfile);
      _profile.value = updatedProfile;

      Get.snackbar(
        'Başarılı',
        'Profil başarıyla güncellendi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _error.value = 'Profil güncellenirken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        'Profil güncellenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Yetenek ekleme
  Future<void> addSkill(SkillModel skill) async {
    try {
      if (_profile.value != null) {
        await _profileService.addSkill(_profile.value!.id, skill);
        _skills.add(skill);
      }
    } catch (e) {
      _error.value = 'Yetenek eklenirken bir hata oluştu: $e';
    }
  }

  // Yetenek silme
  Future<void> removeSkill(String skillId) async {
    try {
      if (_profile.value != null) {
        await _profileService.removeSkill(_profile.value!.id, skillId);
        _skills.removeWhere((skill) => skill.id == skillId);
      }
    } catch (e) {
      _error.value = 'Yetenek silinirken bir hata oluştu: $e';
    }
  }
}
