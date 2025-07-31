import 'dart:convert';
import 'dart:async';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:github_signin_promax/github_signin_promax.dart';
import '../core/services/error_handler_service.dart';
import '../core/config/github_config.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GitHubOAuthService extends GetxService {
  final Logger _logger;
  final ErrorHandlerService _errorHandler;
  final FirebaseAuth _auth;
  late final GithubSignInPzz _githubSignIn;

  GitHubOAuthService({
    required Logger logger,
    required ErrorHandlerService errorHandler,
    required FirebaseAuth auth,
  })  : _logger = logger,
        _errorHandler = errorHandler,
        _auth = auth {
    _githubSignIn = GithubSignInPromax(
      clientId: GitHubConfig.clientId,
      clientSecret: GitHubConfig.clientSecret,
      redirectUrl: GitHubConfig.redirectUrl,
      scope: GitHubConfig.scope,
    );
  }

  Future<String?> signInWithGitHub() async {
    if (!GitHubConfig.isConfigured) {
      _errorHandler.handleError(
          'GitHub yapılandırması eksik', ErrorHandlerService.AUTH_ERROR);
      return null;
    }

    try {
      final result = await _githubSignIn.signIn();
      if (result == null) return null;

      return result.accessToken;
    } catch (e) {
      _logger.e('GitHub login error: $e');
      _errorHandler.handleError(
          'GitHub girişi başarısız oldu', ErrorHandlerService.AUTH_ERROR);
      return null;
    }
  }

  Future<String?> getAccessToken() async {
    try {
      final result = await _githubSignIn.signIn();
      return result?.accessToken;
    } catch (e) {
      _logger.e('GitHub access token error: $e');
      _errorHandler.handleError(
          'GitHub token alınamadı', ErrorHandlerService.AUTH_ERROR);
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserInfo(String accessToken) async {
    try {
      final userInfo = await _githubSignIn.getUserData(accessToken);
      return userInfo;
    } catch (e) {
      _logger.e('GitHub user info error: $e');
      _errorHandler.handleError('GitHub kullanıcı bilgileri alınamadı',
          ErrorHandlerService.AUTH_ERROR);
      return null;
    }
  }
}
