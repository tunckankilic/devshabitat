import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import '../core/config/facebook_config.dart';
import '../core/services/error_handler_service.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FacebookOAuthService extends GetxService {
  final Logger _logger;
  final ErrorHandlerService _errorHandler;
  final FacebookAuth _facebookAuth;

  FacebookOAuthService({
    required Logger logger,
    required ErrorHandlerService errorHandler,
    FacebookAuth? facebookAuth,
  })  : _logger = logger,
        _errorHandler = errorHandler,
        _facebookAuth = facebookAuth ?? FacebookAuth.instance;

  Future<Map<String, dynamic>?> signInWithFacebook() async {
    if (!FacebookConfig.isConfigured) {
      _errorHandler.handleError('Facebook yapılandırması eksik');
      return null;
    }

    try {
      // Facebook ile giriş yap
      final LoginResult result = await _facebookAuth.login(
        permissions: FacebookConfig.scope.split(','),
      );

      if (result.status == LoginStatus.success) {
        // Access token al
        final accessToken = result.accessToken!;

        // Kullanıcı bilgilerini al
        final userData = await _facebookAuth.getUserData(
          fields: "name,email,picture.width(200)",
        );

        // Access token'ı doğrula
        final isValid = await _validateAccessToken(accessToken.token);
        if (!isValid) {
          _errorHandler.handleError('Facebook access token doğrulanamadı');
          return null;
        }

        return {
          'accessToken': accessToken.token,
          'userData': userData,
        };
      } else if (result.status == LoginStatus.cancelled) {
        _errorHandler.handleInfo('Facebook girişi iptal edildi');
        return null;
      } else {
        _errorHandler.handleError('Facebook girişi başarısız oldu');
        return null;
      }
    } catch (e) {
      _logger.e('Facebook ile giriş hatası: $e');
      _errorHandler
          .handleError('Facebook ile giriş yapılırken bir hata oluştu');
      return null;
    }
  }

  Future<bool> _validateAccessToken(String accessToken) async {
    try {
      final response = await http.get(Uri.parse(
          'https://graph.facebook.com/debug_token?input_token=$accessToken&access_token=${FacebookConfig.appId}|${FacebookConfig.appSecret}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['is_valid'] ?? false;
      }
      return false;
    } catch (e) {
      _logger.e('Access token doğrulama hatası: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _facebookAuth.logOut();
    } catch (e) {
      _logger.e('Facebook çıkış hatası: $e');
      _errorHandler.handleError('Facebook çıkış yapılırken bir hata oluştu');
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final accessToken = await _facebookAuth.accessToken;
      return accessToken != null;
    } catch (e) {
      _logger.e('Facebook oturum kontrolü hatası: $e');
      return false;
    }
  }
}
