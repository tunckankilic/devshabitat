import 'dart:convert';
import 'dart:async';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../core/services/error_handler_service.dart';
import '../core/config/github_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../packages/github_signin_promax/github_signin_promax.dart';

class GitHubOAuthService extends GetxService {
  final Logger _logger;
  final ErrorHandlerService _errorHandler;
  final FirebaseAuth _auth;
  late final GithubSignInParams _githubSignInParams;

  GitHubOAuthService({
    required Logger logger,
    required ErrorHandlerService errorHandler,
    required FirebaseAuth auth,
  })  : _logger = logger,
        _errorHandler = errorHandler,
        _auth = auth {
    _githubSignInParams = GithubSignInParams(
      clientId: GitHubConfig.clientId,
      clientSecret: GitHubConfig.clientSecret,
      redirectUrl: GitHubConfig.redirectUrl,
      scopes: GitHubConfig.scope,
    );
  }

  Future<String?> signInWithGitHub() async {
    if (!GitHubConfig.isConfigured) {
      _errorHandler.handleError(
          'GitHub yapılandırması eksik', ErrorHandlerService.AUTH_ERROR);
      return null;
    }

    try {
      final result = await _showGitHubSignInScreen();
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
      final result = await _showGitHubSignInScreen();
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
      final response = await http.get(
        Uri.parse('https://api.github.com/user'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get user info: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('GitHub user info error: $e');
      _errorHandler.handleError('GitHub kullanıcı bilgileri alınamadı',
          ErrorHandlerService.AUTH_ERROR);
      return null;
    }
  }

  Future<GithubSignInResponse?> _showGitHubSignInScreen() async {
    final result = await Get.to<GithubSignInResponse>(
      () => GithubSigninScreen(
        params: _githubSignInParams,
        headerColor: Colors.green,
        title: 'GitHub ile Giriş Yap',
      ),
    );
    return result;
  }
}
