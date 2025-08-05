class GitHubConfig {
  // GitHub OAuth App credentials
  static String get clientId => 'Ov23liXVAiwWDSST2Sun';

  static String get clientSecret => 'a7ba81a9fee6c2a2f4935e0498c47dfa183f984d';

  // OAuth callback URL
  static String get redirectUrl => 'devshabitat://oauth/github';

  // Gerekli izinler
  static String get scope => 'user:email,repo,read:user';

  // Config kontrolü
  static bool get isConfigured =>
      clientId.isNotEmpty && clientSecret.isNotEmpty && redirectUrl.isNotEmpty;

  // Debug için
  static void validateConfig() {
    assert(clientId.isNotEmpty, 'GitHub Client ID eksik!');
    assert(clientSecret.isNotEmpty, 'GitHub Client Secret eksik!');
    assert(redirectUrl.isNotEmpty, 'GitHub Redirect URL eksik!');
  }
}
