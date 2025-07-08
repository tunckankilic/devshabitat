import 'package:devshabitat/app/core/config/env.dart';

class FacebookConfig {
  static String get appId => Env.facebookAppId;
  static String get appSecret => Env.facebookAppSecret;
  static String get scope => Env.facebookScope;

  static bool get isConfigured => appId.isNotEmpty && appSecret.isNotEmpty;
}
