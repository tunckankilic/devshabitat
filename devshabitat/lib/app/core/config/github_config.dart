class GitHubConfig {
  static const String clientId = 'YOUR_GITHUB_CLIENT_ID';
  static const String clientSecret = 'YOUR_GITHUB_CLIENT_SECRET';
  static const String redirectUrl =
      'com.tunckankilic.devshabitat://oauth/redirect';
  static const String scope = 'read:user user:email';

  static bool get isConfigured =>
      clientId.isNotEmpty && clientSecret.isNotEmpty && redirectUrl.isNotEmpty;
}
