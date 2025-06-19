import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:webview_flutter/webview_flutter.dart';
import '../core/config/github_config.dart';
import '../core/services/error_handler_service.dart';
import 'package:logger/logger.dart';

class GitHubOAuthService extends GetxService {
  final Logger _logger;
  final ErrorHandlerService _errorHandler;

  static const String _authorizationEndpoint =
      'https://github.com/login/oauth/authorize';
  static const String _tokenEndpoint =
      'https://github.com/login/oauth/access_token';

  GitHubOAuthService({
    required Logger logger,
    required ErrorHandlerService errorHandler,
  })  : _logger = logger,
        _errorHandler = errorHandler;

  Future<String?> getAccessToken() async {
    try {
      final grant = _createGrant();
      final authorizationUrl = _createAuthorizationUrl(grant);
      final authorizationCode =
          await _showAuthorizationDialog(authorizationUrl);

      if (authorizationCode == null) {
        throw Exception('GitHub yetkilendirmesi iptal edildi');
      }

      final client = await grant.handleAuthorizationCode(authorizationCode);
      return client.credentials.accessToken;
    } catch (e) {
      _logger.e('GitHub OAuth hatası: $e');
      _errorHandler.handleError(e);
      return null;
    }
  }

  oauth2.AuthorizationCodeGrant _createGrant() {
    return oauth2.AuthorizationCodeGrant(
      GitHubConfig.clientId,
      Uri.parse(_authorizationEndpoint),
      Uri.parse(_tokenEndpoint),
      secret: GitHubConfig.clientSecret,
    );
  }

  Uri _createAuthorizationUrl(oauth2.AuthorizationCodeGrant grant) {
    return grant.getAuthorizationUrl(
      Uri.parse(GitHubConfig.redirectUrl),
      scopes: GitHubConfig.scope.split(' '),
    );
  }

  Future<String?> _showAuthorizationDialog(Uri authorizationUrl) async {
    return Navigator.of(Get.context!).push<String>(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('GitHub ile Bağlan'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: WebViewWidget(
            controller: WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..setNavigationDelegate(
                NavigationDelegate(
                  onNavigationRequest: (NavigationRequest request) {
                    if (request.url.startsWith(GitHubConfig.redirectUrl)) {
                      final uri = Uri.parse(request.url);
                      final code = uri.queryParameters['code'];
                      Navigator.of(context).pop(code);
                      return NavigationDecision.prevent;
                    }
                    return NavigationDecision.navigate;
                  },
                ),
              )
              ..loadRequest(Uri.parse(authorizationUrl.toString())),
          ),
        ),
      ),
    );
  }
}
