import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/config/github_config.dart';
import '../core/services/error_handler_service.dart';
import 'package:logger/logger.dart';
import '../constants/app_strings.dart';

class GitHubOAuthService extends GetxService {
  final Logger _logger;
  final ErrorHandlerService _errorHandler;

  GitHubOAuthService({
    required Logger logger,
    required ErrorHandlerService errorHandler,
  })  : _logger = logger,
        _errorHandler = errorHandler;

  Future<String?> signInWithGitHub() async {
    if (!GitHubConfig.isConfigured) {
      _errorHandler.handleError(AppStrings.errorOperationNotAllowed);
      return null;
    }

    try {
      // GitHub OAuth URL'ini oluştur
      final authUrl = Uri.https('github.com', '/login/oauth/authorize', {
        'client_id': GitHubConfig.clientId,
        'scope': GitHubConfig.scope,
        'redirect_uri': GitHubConfig.redirectUrl,
      });

      // Tarayıcıyı aç
      if (await canLaunchUrl(authUrl)) {
        await launchUrl(authUrl, mode: LaunchMode.externalApplication);
      } else {
        throw AppStrings.githubLoginFailed;
      }

      // Yönlendirme URL'ini bekle
      final result = await _handleRedirect();
      if (result == null) return null;

      // Access token al
      final accessToken = await _getAccessToken(result);
      if (accessToken == null) return null;

      // Kullanıcı bilgilerini al
      return await _getUserEmail(accessToken);
    } catch (e) {
      _logger.e('GitHub login error: $e');
      _errorHandler.handleError(AppStrings.githubLoginFailed);
      return null;
    }
  }

  Future<String?> getAccessToken() async {
    if (!GitHubConfig.isConfigured) {
      _errorHandler.handleError(AppStrings.errorOperationNotAllowed);
      return null;
    }

    try {
      // GitHub OAuth URL'ini oluştur
      final authUrl = Uri.https('github.com', '/login/oauth/authorize', {
        'client_id': GitHubConfig.clientId,
        'scope': GitHubConfig.scope,
        'redirect_uri': GitHubConfig.redirectUrl,
      });

      // Tarayıcıyı aç
      if (await canLaunchUrl(authUrl)) {
        await launchUrl(authUrl, mode: LaunchMode.externalApplication);
      } else {
        throw AppStrings.githubLoginFailed;
      }

      // Yönlendirme URL'ini bekle
      final code = await _handleRedirect();
      if (code == null) return null;

      // Access token al
      return await _getAccessToken(code);
    } catch (e) {
      _logger.e('GitHub access token error: $e');
      _errorHandler.handleError(AppStrings.githubLoginFailed);
      return null;
    }
  }

  Future<String?> _handleRedirect() async {
    try {
      final Uri? uri = await uriLinkStream.first;
      if (uri == null) return null;

      final code = uri.queryParameters['code'];
      if (code == null) {
        _errorHandler.handleError(AppStrings.githubLoginFailed);
        return null;
      }

      return code;
    } on PlatformException catch (e) {
      _logger.e('Platform error: $e');
      _errorHandler.handleError(AppStrings.errorGeneric);
      return null;
    }
  }

  Future<String?> _getAccessToken(String code) async {
    try {
      final response = await http.post(
        Uri.parse('https://github.com/login/oauth/access_token'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'client_id': GitHubConfig.clientId,
          'client_secret': GitHubConfig.clientSecret,
          'code': code,
        }),
      );

      if (response.statusCode != 200) {
        _errorHandler.handleError(AppStrings.githubLoginFailed);
        return null;
      }

      final data = jsonDecode(response.body);
      return data['access_token'];
    } catch (e) {
      _logger.e('Token error: $e');
      _errorHandler.handleError(AppStrings.githubLoginFailed);
      return null;
    }
  }

  Future<String?> _getUserEmail(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/user/emails'),
        headers: {
          'Authorization': 'token $accessToken',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode != 200) {
        _errorHandler.handleError(AppStrings.githubUserInfoFailed);
        return null;
      }

      final List<dynamic> emails = jsonDecode(response.body);
      final primaryEmail = emails.firstWhere(
        (email) => email['primary'] == true,
        orElse: () => emails.first,
      );

      return primaryEmail['email'];
    } catch (e) {
      _logger.e('User email error: $e');
      _errorHandler.handleError(AppStrings.githubUserInfoFailed);
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserInfo(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/user'),
        headers: {
          'Authorization': 'token $accessToken',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode != 200) {
        _errorHandler.handleError(AppStrings.githubUserInfoFailed);
        return null;
      }

      final userData = jsonDecode(response.body);

      // Email bilgisini al
      final emailResponse = await http.get(
        Uri.parse('https://api.github.com/user/emails'),
        headers: {
          'Authorization': 'token $accessToken',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (emailResponse.statusCode == 200) {
        final List<dynamic> emails = jsonDecode(emailResponse.body);
        final primaryEmail = emails.firstWhere(
          (email) => email['primary'] == true,
          orElse: () => emails.first,
        );
        userData['email'] = primaryEmail['email'];
      }

      return userData;
    } catch (e) {
      _logger.e('GitHub user info error: $e');
      _errorHandler.handleError(AppStrings.githubUserInfoFailed);
      return null;
    }
  }
}
