class GitHubConfig {
  static String get clientId =>
      'YOUR_GITHUB_CLIENT_ID'; // GitHub Developer Settings'den alınacak
  static String get clientSecret =>
      'YOUR_GITHUB_CLIENT_SECRET'; // GitHub Developer Settings'den alınacak

  // Firebase Auth handler URL'i
  static String get redirectUrl =>
      'devshabitat://oauth/github'; // iOS URL scheme ile eşleşmeli

  // İhtiyaç duyulan yetkileri genişletelim
  static String get scope => 'read:user,user:email,user:follow,repo,gist';

  static bool get isConfigured =>
      clientId.isNotEmpty && clientSecret.isNotEmpty && redirectUrl.isNotEmpty;
}
