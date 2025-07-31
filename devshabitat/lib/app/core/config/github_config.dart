class GitHubConfig {
  static String get clientId => 'Ov23liXVAiwWDSST2Sun';
  static String get clientSecret => 'a7ba81a9fee6c2a2f4935e0498c47dfa183f984d';
  static String get redirectUrl =>
      'https://devshabitat-23119.firebaseapp.com/__/auth/handler';
  static String get scope => 'read:user,user:email';

  static bool get isConfigured =>
      clientId.isNotEmpty && clientSecret.isNotEmpty && redirectUrl.isNotEmpty;
}
