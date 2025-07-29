// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../models/github_stats_model.dart';
import '../repositories/auth_repository.dart';
import '../core/services/api_optimization_service.dart';
import 'package:logger/logger.dart';

class GithubService extends GetxService {
  final AuthRepository _authRepository = Get.find();
  final ApiOptimizationService _apiOptimizer =
      Get.find<ApiOptimizationService>();
  final Logger _logger = Get.find<Logger>();
  static const String _baseUrl = 'https://api.github.com';

  // GitHub username validation regex
  static final RegExp _usernameRegex =
      RegExp(r'^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,37}[a-zA-Z0-9])?$');

  // GitHub token'ı güvenli şekilde al
  String? get _token {
    try {
      // GitHubConfig'den token'ı al veya environment'dan
      final token =
          const String.fromEnvironment('GITHUB_TOKEN', defaultValue: '');
      return token.isNotEmpty ? token : null;
    } catch (e) {
      _logger.e('GitHub token alınırken hata: $e');
      return null;
    }
  }

  // Username doğrulama
  bool _isValidUsername(String username) {
    if (username.isEmpty) return false;
    if (username.isEmpty || username.length > 39) return false;
    if (username.startsWith('-') || username.endsWith('-')) return false;
    if (username.contains('--')) return false;
    return _usernameRegex.hasMatch(username);
  }

  // HTTP status code doğrulama
  bool _isSuccessStatusCode(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  // Rate limiting kontrolü
  bool _isRateLimited(int statusCode, Map<String, String> headers) {
    return statusCode == 429 ||
        (statusCode == 403 && headers['x-ratelimit-remaining'] == '0');
  }

  // API response doğrulama
  Map<String, dynamic>? _validateApiResponse(http.Response response) {
    try {
      // Status code kontrolü
      if (!_isSuccessStatusCode(response.statusCode)) {
        _logger.w('GitHub API HTTP hatası: ${response.statusCode}');
        return null;
      }

      // Content-Type kontrolü
      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        _logger.w('GitHub API response content-type beklenmedi: $contentType');
        return null;
      }

      // JSON parse kontrolü
      final Map<String, dynamic> data = json.decode(response.body);

      // Boş response kontrolü
      if (data.isEmpty) {
        _logger.w('GitHub API boş response döndü');
        return null;
      }

      return data;
    } catch (e) {
      _logger.e('GitHub API response validation hatası: $e');
      return null;
    }
  }

  // Rate limiting için retry mekanizması
  Future<T> _retryWithBackoff<T>(
    Future<T> Function() apiCall, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int retryCount = 0;
    Duration delay = initialDelay;

    while (retryCount < maxRetries) {
      try {
        return await apiCall();
      } catch (e) {
        retryCount++;

        if (e.toString().contains('rate limit') ||
            e.toString().contains('429')) {
          if (retryCount >= maxRetries) {
            throw Exception(
                'GitHub API rate limit aşıldı. Lütfen daha sonra tekrar deneyin.');
          }

          _logger.w(
              'GitHub Rate limit aşıldı, ${delay.inSeconds} saniye bekleniyor...');
          await Future.delayed(delay);
          delay = Duration(seconds: delay.inSeconds * 2); // Exponential backoff
        } else {
          rethrow;
        }
      }
    }

    throw Exception('Maksimum deneme sayısı aşıldı');
  }

  // Güvenli API çağrısı wrapper'ı
  Future<Map<String, dynamic>?> _safeApiCall(
    String endpoint, {
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final headers = <String, String>{
        'Accept': 'application/vnd.github.v3+json',
        'User-Agent': 'DevsHabitat-App/1.0',
        ...?additionalHeaders,
      };

      // Token varsa ekle
      if (_token != null && _token!.isNotEmpty) {
        headers['Authorization'] = 'Bearer $_token';
      }

      final response = await http
          .get(
            Uri.parse('$_baseUrl/$endpoint'),
            headers: headers,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException(
                'GitHub API timeout', const Duration(seconds: 30)),
          );

      // Rate limiting kontrolü
      if (_isRateLimited(response.statusCode, response.headers)) {
        final resetTime = response.headers['x-ratelimit-reset'];
        final remaining = response.headers['x-ratelimit-remaining'];
        _logger.w('GitHub Rate limit: remaining=$remaining, reset=$resetTime');
        throw Exception('GitHub API rate limit aşıldı');
      }

      // 404 için özel handling
      if (response.statusCode == 404) {
        _logger.i('GitHub resource bulunamadı: $endpoint');
        return null;
      }

      // Genel response validation
      return _validateApiResponse(response);
    } on TimeoutException catch (e) {
      _logger.e('GitHub API timeout: $e');
      throw Exception('GitHub API isteği zaman aşımına uğradı');
    } catch (e) {
      _logger.e('GitHub API çağrısı hatası: $e');
      rethrow;
    }
  }

  // GitHub kullanıcı bilgilerini getir - geliştirilmiş
  Future<Map<String, dynamic>?> getUserInfo(String username) async {
    // Username doğrulama
    if (!_isValidUsername(username)) {
      _logger.w('Geçersiz GitHub username: $username');
      throw ArgumentError('Geçersiz GitHub kullanıcı adı formatı');
    }

    return await _retryWithBackoff(() async {
      return await _safeApiCall('users/$username');
    });
  }

  // Repository istatistikleri getir - geliştirilmiş
  Future<Map<String, dynamic>> getRepositoryStats(String username) async {
    // Username doğrulama
    if (!_isValidUsername(username)) {
      _logger.w('Geçersiz GitHub username: $username');
      throw ArgumentError('Geçersiz GitHub kullanıcı adı formatı');
    }

    return await _retryWithBackoff(() async {
      try {
        final repos = await _safeApiCall('users/$username/repos?per_page=100');
        if (repos == null) return <String, dynamic>{};

        final repoList = repos as List<dynamic>? ?? [];
        final languageStats = <String, int>{};
        int totalContributions = 0;

        for (final repo in repoList) {
          if (repo is Map<String, dynamic>) {
            // Language statistics
            final language = repo['language'] as String?;
            if (language != null && language.isNotEmpty) {
              languageStats[language] = (languageStats[language] ?? 0) + 1;
            }

            // Contribution estimation (simplified)
            final size = repo['size'] as int? ?? 0;
            totalContributions += size ~/ 1000; // Rough estimation
          }
        }

        return {
          'languageStats': languageStats,
          'contributions': totalContributions,
          'repositoryCount': repoList.length,
        };
      } catch (e) {
        _logger.e('Repository stats alınırken hata: $e');
        return <String, dynamic>{};
      }
    });
  }

  // User repositories getir - geliştirilmiş
  Future<List<Map<String, dynamic>>> getUserRepos(String username) async {
    // Username doğrulama
    if (!_isValidUsername(username)) {
      _logger.w('Geçersiz GitHub username: $username');
      throw ArgumentError('Geçersiz GitHub kullanıcı adı formatı');
    }

    return await _retryWithBackoff(() async {
      try {
        final response = await _safeApiCall(
            'users/$username/repos?per_page=100&sort=updated');
        if (response == null) return <Map<String, dynamic>>[];

        final repos = response as List<dynamic>? ?? [];
        return repos.whereType<Map<String, dynamic>>().toList();
      } catch (e) {
        _logger.e('User repos alınırken hata: $e');
        return <Map<String, dynamic>>[];
      }
    });
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

  // GitHub stats getir - tamamen yeniden yazılmış
  Future<GithubStatsModel?> getGithubStats(String username) async {
    try {
      // Username doğrulama
      if (!_isValidUsername(username)) {
        _logger.w('Geçersiz GitHub username: $username');
        return null;
      }

      return await _retryWithBackoff(() async {
        try {
          // Parallel API çağrıları
          final results = await Future.wait([
            getUserInfo(username),
            getRepositoryStats(username),
          ]);

          final userInfo = results[0] as Map<String, dynamic>?;
          final repoStats = results[1] as Map<String, dynamic>;

          // Kullanıcı bulunamadı
          if (userInfo == null) {
            _logger.i('GitHub kullanıcısı bulunamadı: $username');
            return null;
          }

          // Required fields validation
          final requiredFields = ['login', 'id', 'public_repos'];
          for (final field in requiredFields) {
            if (!userInfo.containsKey(field)) {
              _logger.w('GitHub user response eksik field: $field');
              return null;
            }
          }

          return GithubStatsModel(
            username:
                userInfo['login'] ?? username, // API'den gelen actual username
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
        } catch (e) {
          _logger.e('GitHub stats işleme hatası: $e');
          return null;
        }
      });
    } catch (e) {
      _logger.e('GitHub stats genel hatası: $e');
      return null;
    }
  }

  // User activities - geliştirilmiş
  Future<List<Map<String, dynamic>>> getUserActivities(String username) async {
    // Username doğrulama
    if (!_isValidUsername(username)) {
      _logger.w('Geçersiz GitHub username: $username');
      throw ArgumentError('Geçersiz GitHub kullanıcı adı formatı');
    }

    return await _apiOptimizer.optimizeApiCall(
      apiCall: () async {
        return await _retryWithBackoff(() async {
          final response = await _safeApiCall('users/$username/events');
          if (response == null) return <Map<String, dynamic>>[];

          final events = response as List<dynamic>? ?? [];
          return events.whereType<Map<String, dynamic>>().toList();
        });
      },
      cacheKey: 'github_activities_$username',
      cacheDuration: const Duration(minutes: 5),
    );
  }

  // Current username getir
  Future<String?> getCurrentUsername() async {
    try {
      final user = _authRepository.currentUser;
      if (user == null) {
        _logger.w('Kullanıcı oturum açmamış');
        return null;
      }

      final githubUsername = user.providerData
          .firstWhereOrNull((info) => info.providerId == 'github.com')
          ?.displayName;

      if (githubUsername != null && !_isValidUsername(githubUsername)) {
        _logger.w('Geçersiz GitHub username formatı: $githubUsername');
        return null;
      }

      return githubUsername;
    } catch (e) {
      _logger.e('GitHub username alınırken hata: $e');
      return null;
    }
  }

  // Tech stack getir - geliştirilmiş
  Future<List<String>> getTechStack(String username) async {
    // Username doğrulama
    if (!_isValidUsername(username)) {
      _logger.w('Geçersiz GitHub username: $username');
      return [];
    }

    try {
      return await _apiOptimizer.optimizeApiCall(
        apiCall: () async {
          return await _retryWithBackoff(() async {
            final repos = await getUserRepos(username);
            final Set<String> techStack = {};

            for (final repo in repos) {
              // Primary language
              final language = repo['language'] as String?;
              if (language != null && language.isNotEmpty) {
                techStack.add(language);
              }

              // Topics/tags
              final topics = repo['topics'] as List<dynamic>?;
              if (topics != null) {
                for (final topic in topics) {
                  if (topic is String && topic.isNotEmpty) {
                    techStack.add(topic);
                  }
                }
              }
            }

            // Geçerli tech stack elemanları döndür
            return techStack
                .where((tech) => tech.length >= 2 && tech.length <= 50)
                .take(50) // Max 50 teknoloji
                .toList();
          });
        },
        cacheKey: 'github_tech_stack_$username',
        cacheDuration: const Duration(minutes: 30),
      );
    } catch (e) {
      _logger.e('Tech stack alınırken hata: $e');
      return [];
    }
  }

  // API health check
  Future<bool> checkApiHealth() async {
    try {
      final response = await _safeApiCall('');
      return response != null;
    } catch (e) {
      _logger.e('GitHub API health check failed: $e');
      return false;
    }
  }

  // Rate limit status
  Future<Map<String, dynamic>?> getRateLimitStatus() async {
    try {
      return await _safeApiCall('rate_limit');
    } catch (e) {
      _logger.e('Rate limit status alınırken hata: $e');
      return null;
    }
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
