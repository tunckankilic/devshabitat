import 'package:devshabitat/app/core/config/env.dart';

class GitHubConfig {
  static String get clientId => Env.githubClientId;
  static String get clientSecret => Env.githubClientSecret;
  static String get redirectUrl => Env.githubRedirectUrl;
  static String get scope => Env.githubScope;

  static bool get isConfigured =>
      clientId.isNotEmpty && clientSecret.isNotEmpty && redirectUrl.isNotEmpty;
}
