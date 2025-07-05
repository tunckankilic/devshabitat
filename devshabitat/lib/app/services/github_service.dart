import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/github_stats_model.dart';
import '../repositories/auth_repository.dart';

class GithubService extends GetxService {
  final AuthRepository _authRepository = Get.find();
  static const String _baseUrl = 'https://api.github.com';
  static const String _token =
      'YOUR_GITHUB_TOKEN'; // GitHub Personal Access Token

  // GitHub kullanıcı bilgilerini getir
  Future<Map<String, dynamic>> getUserInfo(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$username'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw 'GitHub API error: ${response.statusCode}';
      }
    } catch (e) {
      print('GitHub kullanıcı bilgileri alınırken hata: $e');
      rethrow;
    }
  }

  // Kullanıcının repolarını getir
  Future<List<Map<String, dynamic>>> getUserRepos(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$username/repos'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> repos = json.decode(response.body);
        return repos.cast<Map<String, dynamic>>();
      } else {
        throw 'GitHub API error: ${response.statusCode}';
      }
    } catch (e) {
      print('GitHub repoları alınırken hata: $e');
      rethrow;
    }
  }

  // Kullanıcının katkıda bulunduğu repoları getir
  Future<List<Map<String, dynamic>>> getContributedRepos(
      String username) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search/repositories?q=user:$username+fork:true'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> repos = data['items'];
        return repos.cast<Map<String, dynamic>>();
      } else {
        throw 'GitHub API error: ${response.statusCode}';
      }
    } catch (e) {
      print('GitHub katkıda bulunulan repolar alınırken hata: $e');
      rethrow;
    }
  }

  // Kullanıcının yıldızladığı repoları getir
  Future<List<Map<String, dynamic>>> getStarredRepos(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$username/starred'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> repos = json.decode(response.body);
        return repos.cast<Map<String, dynamic>>();
      } else {
        throw 'GitHub API error: ${response.statusCode}';
      }
    } catch (e) {
      print('GitHub yıldızlı repolar alınırken hata: $e');
      rethrow;
    }
  }

  // Kullanıcının commit istatistiklerini getir
  Future<Map<String, dynamic>> getCommitStats(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search/commits?q=author:$username'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/vnd.github.cloak-preview+json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw 'GitHub API error: ${response.statusCode}';
      }
    } catch (e) {
      print('GitHub commit istatistikleri alınırken hata: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getRepositoryStats(String username) async {
    try {
      final repos = await getUserRepos(username);

      int totalStars = 0;
      int totalForks = 0;
      Map<String, int> languages = {};

      for (var repo in repos) {
        totalStars += repo['stargazers_count'] as int;
        totalForks += repo['forks_count'] as int;

        if (repo['language'] != null) {
          languages[repo['language']] = (languages[repo['language']] ?? 0) + 1;
        }
      }

      final languageList = languages.entries.toList();
      languageList.sort((a, b) => b.value.compareTo(a.value));
      final topLanguages = languageList.take(5).map((e) => e.key).toList();

      return {
        'totalStars': totalStars,
        'totalForks': totalForks,
        'topLanguages': topLanguages,
        'contributions': await _getContributionsCount(username),
      };
    } catch (e) {
      print('GitHub repo istatistikleri alınırken hata: $e');
      throw Exception('GitHub repo istatistikleri alınamadı');
    }
  }

  Future<int> _getContributionsCount(String username) async {
    try {
      final now = DateTime.now();
      final oneYearAgo = DateTime(now.year - 1, now.month, now.day);

      final events = await getUserRepos(username);

      return events.length;
    } catch (e) {
      print('GitHub katkı sayısı alınırken hata: $e');
      return 0;
    }
  }

  Future<GithubStatsModel> getGithubStats(String username) async {
    try {
      final userInfo = await getUserInfo(username);
      final repoStats = await getRepositoryStats(username);

      return GithubStatsModel(
        username: username,
        totalRepositories: userInfo['public_repos'] ?? 0,
        totalContributions: repoStats['contributions'] ?? 0,
        languageStats: Map<String, int>.from(repoStats['languageStats'] ?? {}),
        recentRepositories: [],
        contributionGraph: {},
        followers: userInfo['followers'] ?? 0,
        following: userInfo['following'] ?? 0,
        avatarUrl: userInfo['avatar_url'],
        bio: userInfo['bio'],
        location: userInfo['location'],
        website: userInfo['blog'],
        company: userInfo['company'],
      );
    } catch (e) {
      print('GitHub istatistikleri alınırken hata: $e');
      throw Exception('GitHub istatistikleri alınamadı');
    }
  }

  Future<List<Map<String, dynamic>>> getUserActivities(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$username/events'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> events = json.decode(response.body);
        return events.cast<Map<String, dynamic>>();
      } else {
        throw 'GitHub API error: ${response.statusCode}';
      }
    } catch (e) {
      print('GitHub aktiviteleri alınırken hata: $e');
      return [];
    }
  }

  Future<String?> getCurrentUsername() async {
    final user = _authRepository.currentUser;
    return user?.providerData
        .firstWhereOrNull((info) => info.providerId == 'github.com')
        ?.displayName;
  }

  Future<List<String>> getUserTechStack(String username) async {
    final repos = await getUserRepos(username);
    final Set<String> techStack = {};

    for (final repo in repos) {
      if (repo['language'] != null) {
        techStack.add(repo['language'] as String);
      }
      if (repo['topics'] != null) {
        techStack.addAll((repo['topics'] as List).cast<String>());
      }
    }

    return techStack.toList();
  }

  Future<Map<String, int>> getContributionData(String username) async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/users/$username/contributions'));
      if (response.statusCode == 200) {
        return Map<String, int>.from(json.decode(response.body));
      }
      throw Exception('GitHub katkı verisi alınamadı');
    } catch (e) {
      throw Exception('GitHub katkı verisi alınamadı: $e');
    }
  }
}
