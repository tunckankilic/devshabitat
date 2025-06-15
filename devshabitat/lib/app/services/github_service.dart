import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/github_stats_model.dart';

class GithubService extends GetxService {
  static const String _baseUrl = 'https://api.github.com';
  static const String _token =
      'YOUR_GITHUB_TOKEN'; // GitHub Personal Access Token

  // GitHub kullanıcı bilgilerini getir
  Future<Map<String, dynamic>> getUserInfo(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$username'),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'GitHub kullanıcı bilgileri alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(
          'GitHub kullanıcı bilgileri alınırken bir hata oluştu: $e');
    }
  }

  // GitHub repo istatistiklerini getir
  Future<List<Map<String, dynamic>>> getRepositories(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$username/repos'),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception(
            'GitHub repo bilgileri alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('GitHub repo bilgileri alınırken bir hata oluştu: $e');
    }
  }

  // GitHub katkı grafiğini getir
  Future<Map<String, int>> getContributionGraph(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$username/contributions'),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        // GitHub katkı grafiği HTML formatında döner
        // Burada HTML'i parse edip Map'e çevirmeniz gerekiyor
        // Örnek bir implementasyon:
        final Map<String, int> contributions = {};
        // HTML parsing işlemleri...
        return contributions;
      } else {
        throw Exception(
            'GitHub katkı grafiği alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('GitHub katkı grafiği alınırken bir hata oluştu: $e');
    }
  }

  // GitHub dil istatistiklerini getir
  Future<Map<String, int>> getLanguageStats(String username) async {
    try {
      final repos = await getRepositories(username);
      final Map<String, int> languageStats = {};

      for (var repo in repos) {
        final response = await http.get(
          Uri.parse('$_baseUrl/repos/$username/${repo['name']}/languages'),
          headers: {
            'Accept': 'application/vnd.github.v3+json',
            'Authorization': 'Bearer $_token',
          },
        );

        if (response.statusCode == 200) {
          final Map<String, int> repoLanguages =
              Map<String, int>.from(json.decode(response.body));
          repoLanguages.forEach((language, bytes) {
            languageStats[language] = (languageStats[language] ?? 0) + bytes;
          });
        }
      }

      return languageStats;
    } catch (e) {
      throw Exception(
          'GitHub dil istatistikleri alınırken bir hata oluştu: $e');
    }
  }

  // GitHub istatistiklerini getir
  Future<GithubStatsModel> getGithubStats(String username) async {
    try {
      final userInfo = await getUserInfo(username);
      final repos = await getRepositories(username);
      final languageStats = await getLanguageStats(username);
      final contributionGraph = await getContributionGraph(username);

      return GithubStatsModel(
        username: username,
        totalRepositories: repos.length,
        totalContributions: userInfo['public_repos'] ?? 0,
        languageStats: languageStats,
        recentRepositories: repos
            .take(5)
            .map((repo) => {
                  'name': repo['name'],
                  'description': repo['description'],
                  'stars': repo['stargazers_count'],
                  'forks': repo['forks_count'],
                  'language': repo['language'],
                })
            .toList(),
        contributionGraph: contributionGraph,
        followers: userInfo['followers'] ?? 0,
        following: userInfo['following'] ?? 0,
        avatarUrl: userInfo['avatar_url'],
        bio: userInfo['bio'],
        location: userInfo['location'],
        website: userInfo['blog'],
        company: userInfo['company'],
      );
    } catch (e) {
      throw Exception('GitHub istatistikleri alınırken bir hata oluştu: $e');
    }
  }
}
