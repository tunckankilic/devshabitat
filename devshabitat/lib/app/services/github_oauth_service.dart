import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/config/github_config.dart';
import '../core/services/error_handler_service.dart';
import 'package:logger/logger.dart';

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
      _errorHandler.handleError('GitHub yapılandırması eksik');
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
        throw 'GitHub sayfası açılamadı';
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
      _logger.e('GitHub ile giriş hatası: $e');
      _errorHandler.handleError('GitHub ile giriş yapılırken bir hata oluştu');
      return null;
    }
  }

  Future<String?> getAccessToken() async {
    if (!GitHubConfig.isConfigured) {
      _errorHandler.handleError('GitHub yapılandırması eksik');
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
        throw 'GitHub sayfası açılamadı';
      }

      // Yönlendirme URL'ini bekle
      final code = await _handleRedirect();
      if (code == null) return null;

      // Access token al
      return await _getAccessToken(code);
    } catch (e) {
      _logger.e('GitHub access token alma hatası: $e');
      _errorHandler.handleError('GitHub ile giriş yapılırken bir hata oluştu');
      return null;
    }
  }

  Future<String?> _handleRedirect() async {
    try {
      final Uri? uri = await uriLinkStream.first;
      if (uri == null) return null;

      final code = uri.queryParameters['code'];
      if (code == null) {
        _errorHandler.handleError('GitHub yetkilendirme kodu alınamadı');
        return null;
      }

      return code;
    } on PlatformException catch (e) {
      _logger.e('Platform hatası: $e');
      _errorHandler.handleError('Yönlendirme işlemi başarısız oldu');
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
        _errorHandler.handleError('GitHub token alınamadı');
        return null;
      }

      final data = jsonDecode(response.body);
      return data['access_token'];
    } catch (e) {
      _logger.e('Token alma hatası: $e');
      _errorHandler.handleError('Access token alınırken hata oluştu');
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
        _errorHandler.handleError('GitHub kullanıcı bilgileri alınamadı');
        return null;
      }

      final List<dynamic> emails = jsonDecode(response.body);
      final primaryEmail = emails.firstWhere(
        (email) => email['primary'] == true,
        orElse: () => emails.first,
      );

      return primaryEmail['email'];
    } catch (e) {
      _logger.e('Kullanıcı email alma hatası: $e');
      _errorHandler.handleError('Kullanıcı bilgileri alınırken hata oluştu');
      return null;
    }
  }
}
