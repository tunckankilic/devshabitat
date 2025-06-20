class FacebookConfig {
  static const String appId = 'YOUR_FACEBOOK_APP_ID';
  static const String appSecret = 'YOUR_FACEBOOK_APP_SECRET';
  static const String scope = 'email,public_profile';

  static bool get isConfigured => appId.isNotEmpty && appSecret.isNotEmpty;
}
