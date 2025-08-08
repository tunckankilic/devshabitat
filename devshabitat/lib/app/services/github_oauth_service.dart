// ignore_for_file: unused_field

import 'dart:convert';
import 'dart:async';
import 'package:get/get.dart';
import '../core/services/logger_service.dart';
import '../core/services/error_handler_service.dart';
import '../core/config/github_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../packages/github_signin_promax/github_signin_promax.dart';
import 'package:url_launcher/url_launcher.dart';

class GitHubOAuthService extends GetxService {
  final LoggerService _logger;
  final ErrorHandlerService _errorHandler;
  late final GithubSignInParams _githubSignInParams;
  final StreamController<String> _authCodeController =
      StreamController<String>();

  GitHubOAuthService({
    required LoggerService logger,
    required ErrorHandlerService errorHandler,
  }) : _logger = logger,
       _errorHandler = errorHandler {
    _githubSignInParams = GithubSignInParams(
      clientId: GitHubConfig.clientId,
      clientSecret: GitHubConfig.clientSecret,
      redirectUrl: GitHubConfig.redirectUrl,
      scopes: GitHubConfig.scope,
    );

    _logger.i(
      'GitHub Service initialized with redirect URL: ${GitHubConfig.redirectUrl}',
    );
  }

  Future<String?> getGithubAccessToken() async {
    if (!GitHubConfig.isConfigured) {
      _logger.e('GitHub configuration is missing');
      _errorHandler.handleError(
        'GitHub yapılandırması eksik',
        ErrorHandlerService.AUTH_ERROR,
      );
      return null;
    }

    try {
      _logger.i('Starting GitHub authorization process...');
      final result = await _showGitHubSignInScreen();
      if (result == null) {
        _logger.w('GitHub authorization was cancelled by user');
        return null;
      }

      if (result.status == SignInStatus.success) {
        // ✅ Burada code'u token'a çeviriyoruz
        final accessToken = await _getAccessToken(result.accessToken ?? '');
        if (accessToken != null) {
          _logger.i('GitHub authorization successful, access token obtained');
          return accessToken;
        } else {
          throw Exception('Access token alınamadı');
        }
      } else {
        _logger.e('GitHub authorization failed: ${result.error}');
        throw Exception(
          result.error ?? 'GitHub yetkilendirmesi başarısız oldu',
        );
      }
    } catch (e) {
      _logger.e('GitHub authorization error: $e');
      _errorHandler.handleError(
        'GitHub yetkilendirmesi başarısız oldu: $e',
        ErrorHandlerService.AUTH_ERROR,
      );
      return null;
    }
  }

  Future<String?> _getAccessToken(String code) async {
    try {
      _logger.i('Getting access token for code: $code');
      final response = await http.post(
        Uri.parse('https://github.com/login/oauth/access_token'),
        headers: {'Accept': 'application/json'},
        body: {
          'client_id': GitHubConfig.clientId,
          'client_secret': GitHubConfig.clientSecret,
          'code': code,
          'redirect_uri': GitHubConfig.redirectUrl,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access_token'];

        if (accessToken != null) {
          _logger.i('Access token successfully obtained');
          return accessToken;
        } else {
          _logger.e('Access token is null in response: ${response.body}');
          throw Exception('Access token not found in response');
        }
      } else {
        _logger.e(
          'Failed to get access token: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Failed to get access token: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error getting access token: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserInfo(String token) async {
    try {
      _logger.i('Fetching GitHub user info...');
      final response = await http.get(
        Uri.parse('https://api.github.com/user'),
        headers: {
          'Authorization': 'Bearer $token', // ✅ Bearer prefix kullanıyoruz
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'DevsHabitat-App', // ✅ User-Agent ekliyoruz
        },
      );

      if (response.statusCode == 200) {
        final userInfo = json.decode(response.body);
        _logger.i('GitHub user info fetched successfully');
        return userInfo;
      } else {
        _logger.e(
          'Failed to get GitHub user info: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Failed to get user info: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('GitHub user info error: $e');
      _errorHandler.handleError(
        'GitHub kullanıcı bilgileri alınamadı: $e',
        ErrorHandlerService.AUTH_ERROR,
      );
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getUserRepositories(
    String accessToken,
  ) async {
    try {
      _logger.i('Fetching GitHub repositories...');
      final response = await http.get(
        Uri.parse('https://api.github.com/user/repos?sort=updated&per_page=10'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'DevsHabitat-App',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> repos = json.decode(response.body);
        _logger.i('GitHub repositories fetched successfully');
        return repos.cast<Map<String, dynamic>>();
      } else {
        _logger.e(
          'Failed to get repositories: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Failed to get repositories: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('GitHub repositories error: $e');
      _errorHandler.handleError(
        'GitHub depoları alınamadı: $e',
        ErrorHandlerService.AUTH_ERROR,
      );
      return null;
    }
  }

  Future<List<String>?> getUserEmails(String accessToken) async {
    try {
      _logger.i('Fetching GitHub email addresses...');
      final response = await http.get(
        Uri.parse('https://api.github.com/user/emails'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'DevsHabitat-App',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> emails = json.decode(response.body);
        _logger.i('GitHub emails fetched successfully');
        return emails
            .where((email) => email['primary'] == true)
            .map((email) => email['email'] as String)
            .toList();
      } else {
        _logger.e(
          'Failed to get emails: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Failed to get emails: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('GitHub emails error: $e');
      _errorHandler.handleError(
        'GitHub email adresleri alınamadı: $e',
        ErrorHandlerService.AUTH_ERROR,
      );
      return null;
    }
  }

  Future<GithubSignInResponse?> _showGitHubSignInScreen() async {
    try {
      _logger.i('Opening GitHub authorization screen with params:');
      _logger.i('Client ID: ${_githubSignInParams.clientId}');
      _logger.i('Redirect URL: ${_githubSignInParams.redirectUrl}');
      _logger.i('Scopes: ${_githubSignInParams.scopes}');

      // GitHub OAuth URL'ini oluştur
      final authUrl = Uri.https('github.com', '/login/oauth/authorize', {
        'client_id': _githubSignInParams.clientId,
        'redirect_uri': GitHubConfig.redirectUrl,
        'scope': _githubSignInParams.scopes,
        'allow_signup': 'true',
        'state': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      _logger.i('Auth URL: $authUrl');

      // URL'i varsayılan tarayıcıda aç
      if (await canLaunchUrl(authUrl)) {
        await launchUrl(authUrl, mode: LaunchMode.externalApplication);

        // Auth code'u bekle
        try {
          final code = await _authCodeController.stream.first.timeout(
            const Duration(minutes: 5),
            onTimeout: () {
              throw TimeoutException(
                'GitHub yetkilendirme zaman aşımına uğradı',
              );
            },
          );

          return GithubSignInResponse(
            status: SignInStatus.success,
            accessToken: code,
          );
        } on TimeoutException catch (e) {
          _logger.e('GitHub authorization timeout: $e');
          Get.snackbar(
            'Zaman Aşımı',
            'GitHub yetkilendirme işlemi zaman aşımına uğradı. Lütfen tekrar deneyin.',
            backgroundColor: Colors.orange.withOpacity(0.8),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4),
            icon: const Icon(Icons.timer_off, color: Colors.white),
          );
          return GithubSignInResponse(
            status: SignInStatus.failed,
            error: 'Yetkilendirme zaman aşımına uğradı',
          );
        }
      } else {
        throw 'GitHub yetkilendirme URL\'i açılamadı';
      }
    } catch (e) {
      _logger.e('GitHub authorization error: $e');

      Get.snackbar(
        'GitHub Bağlantı Hatası',
        'GitHub hesabınıza bağlanırken bir hata oluştu. Lütfen tekrar deneyin.',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error, color: Colors.white),
      );

      return GithubSignInResponse(
        status: SignInStatus.failed,
        error: e.toString(),
      );
    }
  }
}
