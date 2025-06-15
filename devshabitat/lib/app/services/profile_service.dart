import 'package:get/get.dart';
import '../models/developer_profile_model.dart';
import '../models/skill_model.dart';
import '../models/github_stats_model.dart';

class ProfileService extends GetxService {
  // API endpoint'leri
  static const String _baseUrl = 'https://api.devs-habitat.com/v1';
  static const String _profileEndpoint = '/profiles';
  static const String _skillsEndpoint = '/skills';
  static const String _githubEndpoint = '/github';

  // Profil verilerini getir
  Future<DeveloperProfile> getProfile(String userId) async {
    try {
      final response =
          await GetConnect().get('$_baseUrl$_profileEndpoint/$userId');
      if (response.status.hasError) {
        throw Exception('Profil yüklenemedi: ${response.statusText}');
      }
      return DeveloperProfile.fromJson(response.body);
    } catch (e) {
      throw Exception('Profil yüklenirken bir hata oluştu: $e');
    }
  }

  // Yetenekleri getir
  Future<List<SkillModel>> getSkills(String userId) async {
    try {
      final response =
          await GetConnect().get('$_baseUrl$_skillsEndpoint/$userId');
      if (response.status.hasError) {
        throw Exception('Yetenekler yüklenemedi: ${response.statusText}');
      }
      return (response.body as List)
          .map((skill) => SkillModel.fromJson(skill))
          .toList();
    } catch (e) {
      throw Exception('Yetenekler yüklenirken bir hata oluştu: $e');
    }
  }

  // GitHub istatistiklerini getir
  Future<GithubStatsModel> getGithubStats(String username) async {
    try {
      final response =
          await GetConnect().get('$_baseUrl$_githubEndpoint/$username');
      if (response.status.hasError) {
        throw Exception(
            'GitHub istatistikleri yüklenemedi: ${response.statusText}');
      }
      return GithubStatsModel.fromJson(response.body);
    } catch (e) {
      throw Exception('GitHub istatistikleri yüklenirken bir hata oluştu: $e');
    }
  }

  // Profil güncelle
  Future<void> updateProfile(DeveloperProfile profile) async {
    try {
      final response = await GetConnect().put(
        '$_baseUrl$_profileEndpoint/${profile.id}',
        profile.toJson(),
      );
      if (response.status.hasError) {
        throw Exception('Profil güncellenemedi: ${response.statusText}');
      }
    } catch (e) {
      throw Exception('Profil güncellenirken bir hata oluştu: $e');
    }
  }

  // Yetenek ekle
  Future<void> addSkill(String userId, SkillModel skill) async {
    try {
      final response = await GetConnect().post(
        '$_baseUrl$_skillsEndpoint/$userId',
        skill.toJson(),
      );
      if (response.status.hasError) {
        throw Exception('Yetenek eklenemedi: ${response.statusText}');
      }
    } catch (e) {
      throw Exception('Yetenek eklenirken bir hata oluştu: $e');
    }
  }

  // Yetenek sil
  Future<void> removeSkill(String userId, String skillId) async {
    try {
      final response = await GetConnect().delete(
        '$_baseUrl$_skillsEndpoint/$userId/$skillId',
      );
      if (response.status.hasError) {
        throw Exception('Yetenek silinemedi: ${response.statusText}');
      }
    } catch (e) {
      throw Exception('Yetenek silinirken bir hata oluştu: $e');
    }
  }
}
