import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env.prod', obfuscate: true)
abstract class Env {
  // Firebase Android Configuration
  @EnviedField(varName: 'FIREBASE_ANDROID_API_KEY', obfuscate: true)
  static final String firebaseAndroidApiKey = _Env.firebaseAndroidApiKey;

  @EnviedField(varName: 'FIREBASE_ANDROID_APP_ID', obfuscate: true)
  static final String firebaseAndroidAppId = _Env.firebaseAndroidAppId;

  @EnviedField(varName: 'FIREBASE_ANDROID_MESSAGING_SENDER_ID', obfuscate: true)
  static final String firebaseAndroidMessagingSenderId =
      _Env.firebaseAndroidMessagingSenderId;

  @EnviedField(varName: 'FIREBASE_ANDROID_PROJECT_ID', obfuscate: true)
  static final String firebaseAndroidProjectId = _Env.firebaseAndroidProjectId;

  @EnviedField(varName: 'FIREBASE_ANDROID_STORAGE_BUCKET', obfuscate: true)
  static final String firebaseAndroidStorageBucket =
      _Env.firebaseAndroidStorageBucket;

  @EnviedField(varName: 'FIREBASE_ANDROID_CLIENT_ID', obfuscate: true)
  static final String firebaseAndroidClientId = _Env.firebaseAndroidClientId;

  // Firebase iOS Configuration
  @EnviedField(varName: 'FIREBASE_IOS_API_KEY', obfuscate: true)
  static final String firebaseIosApiKey = _Env.firebaseIosApiKey;

  @EnviedField(varName: 'FIREBASE_IOS_APP_ID', obfuscate: true)
  static final String firebaseIosAppId = _Env.firebaseIosAppId;

  @EnviedField(varName: 'FIREBASE_IOS_MESSAGING_SENDER_ID', obfuscate: true)
  static final String firebaseIosMessagingSenderId =
      _Env.firebaseIosMessagingSenderId;

  @EnviedField(varName: 'FIREBASE_IOS_PROJECT_ID', obfuscate: true)
  static final String firebaseIosProjectId = _Env.firebaseIosProjectId;

  @EnviedField(varName: 'FIREBASE_IOS_STORAGE_BUCKET', obfuscate: true)
  static final String firebaseIosStorageBucket = _Env.firebaseIosStorageBucket;

  @EnviedField(varName: 'FIREBASE_IOS_BUNDLE_ID', obfuscate: true)
  static final String firebaseIosBundleId = _Env.firebaseIosBundleId;

  @EnviedField(varName: 'FIREBASE_IOS_CLIENT_ID', obfuscate: true)
  static final String firebaseIosClientId = _Env.firebaseIosClientId;

  // GitHub Configuration
  @EnviedField(varName: 'GITHUB_CLIENT_ID', obfuscate: true)
  static final String githubClientId = _Env.githubClientId;

  @EnviedField(varName: 'GITHUB_CLIENT_SECRET', obfuscate: true)
  static final String githubClientSecret = _Env.githubClientSecret;

  @EnviedField(varName: 'GITHUB_REDIRECT_URL', obfuscate: true)
  static final String githubRedirectUrl = _Env.githubRedirectUrl;

  @EnviedField(varName: 'GITHUB_SCOPE', obfuscate: true)
  static final String githubScope = _Env.githubScope;

  // Facebook Configuration
  @EnviedField(varName: 'FACEBOOK_APP_ID', obfuscate: true)
  static final String facebookAppId = _Env.facebookAppId;

  @EnviedField(varName: 'FACEBOOK_APP_SECRET', obfuscate: true)
  static final String facebookAppSecret = _Env.facebookAppSecret;

  @EnviedField(varName: 'FACEBOOK_SCOPE', obfuscate: true)
  static final String facebookScope = _Env.facebookScope;

  // Google Maps Configuration
  @EnviedField(varName: 'GOOGLE_MAPS_API_KEY', obfuscate: true)
  static final String googleMapsApiKey = _Env.googleMapsApiKey;

  // Security Configuration
  @EnviedField(varName: 'JWT_SECRET_KEY', obfuscate: true)
  static final String jwtSecretKey = _Env.jwtSecretKey;

  @EnviedField(varName: 'ENCRYPTION_KEY', obfuscate: true)
  static final String encryptionKey = _Env.encryptionKey;

  // API Rate Limiting
  @EnviedField(varName: 'MAX_LOGIN_ATTEMPTS')
  static final int maxLoginAttempts = _Env.maxLoginAttempts;

  @EnviedField(varName: 'LOGIN_LOCKOUT_MINUTES')
  static final int loginLockoutMinutes = _Env.loginLockoutMinutes;

  @EnviedField(varName: 'MAX_API_REQUESTS_PER_MINUTE')
  static final int maxApiRequestsPerMinute = _Env.maxApiRequestsPerMinute;

  // File Upload Configuration
  @EnviedField(varName: 'MAX_FILE_SIZE_MB')
  static final int maxFileSizeMb = _Env.maxFileSizeMb;

  @EnviedField(varName: 'ALLOWED_IMAGE_TYPES')
  static final String allowedImageTypes = _Env.allowedImageTypes;

  @EnviedField(varName: 'ALLOWED_DOCUMENT_TYPES')
  static final String allowedDocumentTypes = _Env.allowedDocumentTypes;

  @EnviedField(varName: 'MAX_FILE_NAME_LENGTH')
  static final int maxFileNameLength = _Env.maxFileNameLength;

  // Session Configuration
  @EnviedField(varName: 'SESSION_TIMEOUT_MINUTES')
  static final int sessionTimeoutMinutes = _Env.sessionTimeoutMinutes;

  @EnviedField(varName: 'FORCE_HTTPS')
  static final bool forceHttps = _Env.forceHttps;
}
