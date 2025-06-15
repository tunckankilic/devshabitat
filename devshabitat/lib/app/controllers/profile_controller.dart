import 'package:get/get.dart';
import '../models/developer_profile_model.dart';
import '../models/skill_model.dart';
import '../models/github_stats_model.dart';

class ProfileController extends GetxController {
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

      // TODO: API'den profil verilerini yükle
      // Örnek veri:
      _profile.value = DeveloperProfile(
        id: userId,
        name: 'John Doe',
        title: 'Senior Flutter Developer',
        bio: 'Passionate about mobile development',
        skills: ['Flutter', 'Dart', 'Firebase'],
        languages: ['Dart', 'JavaScript', 'Python'],
        frameworks: ['Flutter', 'React', 'Django'],
        githubStats: {},
        profileImage: '',
        location: 'Istanbul, Turkey',
        portfolioLinks: [],
        experienceLevel: ExperienceLevel.senior,
        interests: ['Mobile Development', 'UI/UX'],
      );

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
      // TODO: API'den yetenekleri yükle
      _skills.value = [
        SkillModel(
          id: '1',
          name: 'Flutter',
          category: SkillCategory.framework,
          proficiency: 5,
        ),
        SkillModel(
          id: '2',
          name: 'Dart',
          category: SkillCategory.programming,
          proficiency: 4,
        ),
      ];
    } catch (e) {
      _error.value = 'Yetenekler yüklenirken bir hata oluştu: $e';
    }
  }

  // GitHub istatistiklerini yükleme
  Future<void> loadGithubStats() async {
    try {
      // TODO: GitHub API'den istatistikleri yükle
      _githubStats.value = GithubStatsModel(
        username: 'johndoe',
        totalRepositories: 50,
        totalContributions: 1000,
        languageStats: {'Dart': 60, 'JavaScript': 30, 'Python': 10},
        recentRepositories: [],
        contributionGraph: {},
        followers: 100,
        following: 50,
      );
    } catch (e) {
      _error.value = 'GitHub istatistikleri yüklenirken bir hata oluştu: $e';
    }
  }

  // Profil güncelleme
  Future<void> updateProfile(DeveloperProfile updatedProfile) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      // TODO: API'ye profil güncellemesini gönder
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
      // TODO: API'ye yetenek ekleme isteği gönder
      _skills.add(skill);
    } catch (e) {
      _error.value = 'Yetenek eklenirken bir hata oluştu: $e';
    }
  }

  // Yetenek silme
  Future<void> removeSkill(String skillId) async {
    try {
      // TODO: API'ye yetenek silme isteği gönder
      _skills.removeWhere((skill) => skill.id == skillId);
    } catch (e) {
      _error.value = 'Yetenek silinirken bir hata oluştu: $e';
    }
  }
}
