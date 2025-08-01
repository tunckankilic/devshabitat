// ignore_for_file: unused_field

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

    _logger.i(
        'GitHub OAuth Service initialized with redirect URL: ${GitHubConfig.redirectUrl}');
  }

  Future<String?> signInWithGitHub() async {
    if (!GitHubConfig.isConfigured) {
      _logger.e('GitHub configuration is missing');
      _errorHandler.handleError(
          'GitHub yapılandırması eksik', ErrorHandlerService.AUTH_ERROR);
      return null;
    }

    try {
      _logger.i('Starting GitHub sign in process...');
      final result = await _showGitHubSignInScreen();
      if (result == null) {
        _logger.w('GitHub sign in was cancelled by user');
        return null;
      }

      if (result.status == SignInStatus.success) {
        _logger.i('GitHub sign in successful, access token obtained');
        return result.accessToken;
      } else {
        _logger.e('GitHub sign in failed: ${result.error}');
        throw Exception(result.error ?? 'GitHub girişi başarısız oldu');
      }
    } catch (e) {
      _logger.e('GitHub login error: $e');
      _errorHandler.handleError(
          'GitHub girişi başarısız oldu: $e', ErrorHandlerService.AUTH_ERROR);
      return null;
    }
  }

  Future<String?> getAccessToken() async {
    try {
      _logger.i('Getting GitHub access token...');
      final result = await _showGitHubSignInScreen();

      if (result == null) {
        _logger.w('GitHub sign in was cancelled');
        return null;
      }

      if (result.status == SignInStatus.success) {
        _logger.i('GitHub access token obtained successfully');
        return result.accessToken;
      } else if (result.status == SignInStatus.canceled) {
        _logger.i('GitHub sign in was cancelled by user');
        return null;
      } else {
        _logger.e('GitHub sign in failed: ${result.error}');
        throw Exception(result.error ?? 'GitHub token alınamadı');
      }
    } catch (e) {
      _logger.e('GitHub access token error: $e');
      _errorHandler.handleError(
          'GitHub token alınamadı: $e', ErrorHandlerService.AUTH_ERROR);
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserInfo(String accessToken) async {
    try {
      _logger.i('Fetching GitHub user info...');
      final response = await http.get(
        Uri.parse('https://api.github.com/user'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 200) {
        final userInfo = json.decode(response.body);
        _logger.i('GitHub user info fetched successfully');
        return userInfo;
      } else {
        _logger.e(
            'Failed to get GitHub user info: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to get user info: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('GitHub user info error: $e');
      _errorHandler.handleError('GitHub kullanıcı bilgileri alınamadı: $e',
          ErrorHandlerService.AUTH_ERROR);
      return null;
    }
  }

  Future<GithubSignInResponse?> _showGitHubSignInScreen() async {
    try {
      _logger.i('Opening GitHub sign in screen...');
      final result = await Get.to<GithubSignInResponse>(
        () => GithubSigninScreen(
          params: _githubSignInParams,
          headerColor: Colors.green,
          title: 'GitHub ile Giriş Yap',
        ),
      );

      if (result != null) {
        _logger.i('GitHub sign in screen returned: ${result.status}');
      } else {
        _logger.w('GitHub sign in screen returned null');
      }

      return result;
    } catch (e) {
      _logger.e('Error showing GitHub sign in screen: $e');
      rethrow;
    }
  }
}
