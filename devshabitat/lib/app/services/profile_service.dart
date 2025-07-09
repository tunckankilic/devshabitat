import 'package:get/get.dart';
import '../models/developer_profile_model.dart';
import '../models/skill_model.dart';
import '../models/github_stats_model.dart';
import '../core/services/api_optimization_service.dart';

class ProfileService extends GetxService {
  final ApiOptimizationService _apiOptimizer =
      Get.find<ApiOptimizationService>();

  // API endpoint'leri
  static const String _baseUrl = 'https://api.devs-habitat.com/v1';
  static const String _profileEndpoint = '/profiles';
  static const String _skillsEndpoint = '/skills';
  static const String _githubEndpoint = '/github';

  // Profil verilerini getir
  Future<DeveloperProfile> getProfile(String userId) async {
    return await _apiOptimizer.optimizeApiCall(
      apiCall: () async {
        final response =
            await GetConnect().get('$_baseUrl$_profileEndpoint/$userId');
        if (response.status.hasError) {
          throw Exception('Profil yüklenemedi: ${response.statusText}');
        }
        return DeveloperProfile.fromJson(response.body);
      },
      cacheKey: 'profile_$userId',
      cacheDuration: const Duration(minutes: 10),
    );
  }

  // Yetenekleri getir
  Future<List<SkillModel>> getSkills(String userId) async {
    return await _apiOptimizer.optimizeApiCall(
      apiCall: () async {
        final response =
            await GetConnect().get('$_baseUrl$_skillsEndpoint/$userId');
        if (response.status.hasError) {
          throw Exception('Yetenekler yüklenemedi: ${response.statusText}');
        }
        return (response.body as List)
            .map((skill) => SkillModel.fromJson(skill))
            .toList();
      },
      cacheKey: 'skills_$userId',
      cacheDuration: const Duration(minutes: 15),
    );
  }

  // GitHub istatistiklerini getir
  Future<GithubStatsModel> getGithubStats(String username) async {
    return await _apiOptimizer.optimizeApiCall(
      apiCall: () async {
        final response =
            await GetConnect().get('$_baseUrl$_githubEndpoint/$username');
        if (response.status.hasError) {
          throw Exception(
              'GitHub istatistikleri yüklenemedi: ${response.statusText}');
        }
        return GithubStatsModel.fromJson(response.body);
      },
      cacheKey: 'github_stats_api_$username',
      cacheDuration: const Duration(minutes: 20),
    );
  }

  // Profil güncelle
  Future<void> updateProfile(DeveloperProfile profile) async {
    return await _apiOptimizer.retryApiCall(
      apiCall: () async {
        final response = await GetConnect().put(
          '$_baseUrl$_profileEndpoint/${profile.id}',
          profile.toJson(),
        );
        if (response.status.hasError) {
          throw Exception('Profil güncellenemedi: ${response.statusText}');
        }
      },
      maxAttempts: 3,
    );
  }

  // Yetenek ekle
  Future<void> addSkill(String userId, SkillModel skill) async {
    return await _apiOptimizer.retryApiCall(
      apiCall: () async {
        final response = await GetConnect().post(
          '$_baseUrl$_skillsEndpoint/$userId',
          skill.toJson(),
        );
        if (response.status.hasError) {
          throw Exception('Yetenek eklenemedi: ${response.statusText}');
        }
      },
      maxAttempts: 3,
    );
  }

  // Yetenek sil
  Future<void> removeSkill(String userId, String skillId) async {
    return await _apiOptimizer.retryApiCall(
      apiCall: () async {
        final response = await GetConnect().delete(
          '$_baseUrl$_skillsEndpoint/$userId/$skillId',
        );
        if (response.status.hasError) {
          throw Exception('Yetenek silinemedi: ${response.statusText}');
        }
      },
      maxAttempts: 3,
    );
  }

  // Batch profil verilerini getir
  Future<Map<String, dynamic>> getBatchProfileData(String userId) async {
    return await _apiOptimizer.batchApiCalls(
      calls: {
        'profile': () => getProfile(userId),
        'skills': () => getSkills(userId),
      },
      cacheDuration: const Duration(minutes: 10),
    );
  }
}
