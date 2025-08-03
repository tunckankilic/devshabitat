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

class GitHubOAuthService extends GetxService {
  final Logger _logger;
  final ErrorHandlerService _errorHandler;
  late final GithubSignInParams _githubSignInParams;

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
        _logger.i('GitHub authorization successful, access token obtained');
        return result.accessToken;
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
      _logger.i('Opening GitHub authorization screen...');
      final result = await Get.to<GithubSignInResponse>(
        () => GithubSigninScreen(
          params: _githubSignInParams,
          headerColor: Colors.green,
          title: 'GitHub Hesabına Bağlan',
        ),
      );

      if (result != null) {
        _logger.i('GitHub authorization screen returned: ${result.status}');
      } else {
        _logger.w('GitHub authorization screen returned null');
      }

      return result;
    } catch (e) {
      _logger.e('Error showing GitHub authorization screen: $e');
      rethrow;
    }
  }
}
