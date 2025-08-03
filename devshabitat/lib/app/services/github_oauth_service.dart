// ignore_for_file: unused_field

import 'dart:convert';
import 'dart:async';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../core/services/error_handler_service.dart';
import '../core/config/github_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../packages/github_signin_promax/github_signin_promax.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/widgets.dart';

class GitHubOAuthService extends GetxService {
  final Logger _logger;
  final ErrorHandlerService _errorHandler;
  late final GithubSignInParams _githubSignInParams;
  bool _isRedirecting = false;

  GitHubOAuthService({
    required Logger logger,
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
          'redirect_uri': GitHubConfig
              .redirectUrl, // ⚠️ Bu URL'nin WebView'daki ile aynı olması gerekiyor
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
        'redirect_uri': GitHubConfig.redirectUrl, // ✅ Config'den alıyoruz
        'scope': _githubSignInParams.scopes,
        'allow_signup': 'true',
        'state': DateTime.now().millisecondsSinceEpoch
            .toString(), // ✅ Güvenlik için state ekliyoruz
      });
      _logger.i('Auth URL: $authUrl');

      // GitHub OAuth ekranını göster
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (request) async {
              _logger.i('Navigation request to: ${request.url}');

              // Hata kontrolü
              if (request.url.contains('error=')) {
                _logger.e('GitHub OAuth error: ${request.url}');
                Get.back(
                  result: GithubSignInResponse(
                    status: SignInStatus.failed,
                    error:
                        Uri.parse(
                          request.url,
                        ).queryParameters['error_description'] ??
                        'OAuth hatası',
                  ),
                );
                return NavigationDecision.prevent;
              }

              // Success kontrolü - code parametresi varlığını kontrol et
              if (request.url.contains('code=') && !_isRedirecting) {
                _isRedirecting = true;
                _logger.i('GitHub OAuth success, extracting code');
                final uri = Uri.parse(request.url);
                final code = uri.queryParameters['code'];

                if (code != null && code.isNotEmpty) {
                  _logger.i(
                    'Extracted authorization code: ${code.substring(0, 8)}...',
                  ); // Güvenlik için sadece ilk 8 karakteri logla

                  // ✅ Code'u döndürüyoruz, token olarak değil!
                  Future.delayed(const Duration(milliseconds: 100), () {
                    Navigator.of(Get.context!).pop(
                      GithubSignInResponse(
                        status: SignInStatus.success,
                        accessToken:
                            code, // Bu aslında code, sonra token'a çevrilecek
                      ),
                    );
                  });
                } else {
                  _logger.e('Authorization code is empty');
                  Get.back(
                    result: GithubSignInResponse(
                      status: SignInStatus.failed,
                      error: 'Authorization code alınamadı',
                    ),
                  );
                }
                return NavigationDecision.prevent;
              }

              _logger.d('Allowing navigation to: ${request.url}');
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(authUrl.toString()))
        ..setUserAgent(
          'Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.2 Mobile/15E148 Safari/604.1',
        );

      final result = await Get.to<GithubSignInResponse>(
        () => Scaffold(
          appBar: AppBar(
            title: const Text('GitHub Login'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Get.back(),
            ),
          ),
          body: WebViewWidget(controller: controller),
        ),
      );

      // Reset redirect flag
      _isRedirecting = false;

      // Sonucu logla ve döndür
      if (result != null) {
        if (result.status == SignInStatus.success) {
          _logger.i('GitHub authorization successful');
        } else {
          _logger.w('GitHub authorization failed: ${result.error}');
        }
      } else {
        _logger.w('GitHub authorization cancelled by user');
      }

      return result;
    } catch (e) {
      _logger.e('GitHub authorization error: $e');
      _isRedirecting = false; // Reset flag on error

      // Kullanıcıya hata göster
      Get.snackbar(
        'GitHub Bağlantı Hatası',
        'GitHub hesabınıza bağlanırken bir hata oluştu. Lütfen tekrar deneyin.',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error, color: Colors.white),
      );

      rethrow;
    }
  }
}
