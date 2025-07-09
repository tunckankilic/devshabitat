import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/github_stats_model.dart';
import '../repositories/auth_repository.dart';
import '../core/services/api_optimization_service.dart';

class GithubService extends GetxService {
  final AuthRepository _authRepository = Get.find();
  final ApiOptimizationService _apiOptimizer =
      Get.find<ApiOptimizationService>();
  static const String _baseUrl = 'https://api.github.com';
  static const String _token =
      'YOUR_GITHUB_TOKEN'; // GitHub Personal Access Token

  // GitHub kullanıcı bilgilerini getir
  Future<Map<String, dynamic>> getUserInfo(String username) async {
    return await _apiOptimizer.optimizeApiCall(
      apiCall: () async {
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
      },
      cacheKey: 'github_user_info_$username',
      cacheDuration: const Duration(minutes: 10),
    );
  }

  // Kullanıcının repolarını getir
  Future<List<Map<String, dynamic>>> getUserRepos(String username) async {
    return await _apiOptimizer.optimizeApiCall(
      apiCall: () async {
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
      },
      cacheKey: 'github_user_repos_$username',
      cacheDuration: const Duration(minutes: 15),
    );
  }

  // Kullanıcının katkıda bulunduğu repoları getir
  Future<List<Map<String, dynamic>>> getContributedRepos(
      String username) async {
    return await _apiOptimizer.optimizeApiCall(
      apiCall: () async {
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
      },
      cacheKey: 'github_contributed_repos_$username',
      cacheDuration: const Duration(minutes: 20),
    );
  }

  // Kullanıcının yıldızladığı repoları getir
  Future<List<Map<String, dynamic>>> getStarredRepos(String username) async {
    return await _apiOptimizer.optimizeApiCall(
      apiCall: () async {
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
      },
      cacheKey: 'github_starred_repos_$username',
      cacheDuration: const Duration(minutes: 30),
    );
  }

  // Kullanıcının commit istatistiklerini getir
  Future<Map<String, dynamic>> getCommitStats(String username) async {
    return await _apiOptimizer.optimizeApiCall(
      apiCall: () async {
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
      },
      cacheKey: 'github_commit_stats_$username',
      cacheDuration: const Duration(minutes: 5),
    );
  }

  Future<Map<String, dynamic>> getRepositoryStats(String username) async {
    return await _apiOptimizer.optimizeApiCall(
      apiCall: () async {
        final repos = await getUserRepos(username);

        int totalStars = 0;
        int totalForks = 0;
        Map<String, int> languages = {};

        for (var repo in repos) {
          totalStars += repo['stargazers_count'] as int;
          totalForks += repo['forks_count'] as int;

          if (repo['language'] != null) {
            languages[repo['language']] =
                (languages[repo['language']] ?? 0) + 1;
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
      },
      cacheKey: 'github_repo_stats_$username',
      cacheDuration: const Duration(minutes: 15),
    );
  }

  Future<int> _getContributionsCount(String username) async {
    return await _apiOptimizer.optimizeApiCall(
      apiCall: () async {
        final events = await getUserRepos(username);
        return events.length;
      },
      cacheKey: 'github_contributions_$username',
      cacheDuration: const Duration(minutes: 10),
    );
  }

  Future<GithubStatsModel> getGithubStats(String username) async {
    return await _apiOptimizer.optimizeApiCall(
      apiCall: () async {
        final userInfo = await getUserInfo(username);
        final repoStats = await getRepositoryStats(username);

        return GithubStatsModel(
          username: username,
          totalRepositories: userInfo['public_repos'] ?? 0,
          totalContributions: repoStats['contributions'] ?? 0,
          languageStats:
              Map<String, int>.from(repoStats['languageStats'] ?? {}),
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
      },
      cacheKey: 'github_stats_$username',
      cacheDuration: const Duration(minutes: 20),
    );
  }

  Future<List<Map<String, dynamic>>> getUserActivities(String username) async {
    return await _apiOptimizer.optimizeApiCall(
      apiCall: () async {
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
      },
      cacheKey: 'github_activities_$username',
      cacheDuration: const Duration(minutes: 5),
    );
  }

  Future<String?> getCurrentUsername() async {
    final user = _authRepository.currentUser;
    return user?.providerData
        .firstWhereOrNull((info) => info.providerId == 'github.com')
        ?.displayName;
  }

  Future<List<String>> getTechStack(String username) async {
    return await _apiOptimizer.optimizeApiCall(
      apiCall: () async {
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
      },
      cacheKey: 'github_tech_stack_$username',
      cacheDuration: const Duration(minutes: 30),
    );
  }

  Future<Map<String, int>> getContributionData(String username) async {
    return await _apiOptimizer.retryApiCall(
      apiCall: () async {
        final response = await http
            .get(Uri.parse('$_baseUrl/users/$username/contributions'));
        if (response.statusCode == 200) {
          return Map<String, int>.from(json.decode(response.body));
        }
        throw Exception('GitHub katkı verisi alınamadı');
      },
      maxAttempts: 3,
    );
  }

  // Batch API çağrıları için yeni metod
  Future<Map<String, dynamic>> getBatchGithubData(String username) async {
    return await _apiOptimizer.batchApiCalls(
      calls: {
        'userInfo': () => getUserInfo(username),
        'repos': () => getUserRepos(username),
        'stats': () => getRepositoryStats(username),
        'activities': () => getUserActivities(username),
      },
      cacheDuration: const Duration(minutes: 15),
    );
  }
}
