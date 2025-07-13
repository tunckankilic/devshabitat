class AppAssets {
  // Görsel varlıklar
  static const String _imagesPath = 'assets/images';
  static const String _iconsPath = 'assets/icons';
  static const String _animationsPath = 'assets/animations';
  static const String _mapStylesPath = 'assets/map_styles';

  // Logo ve marka
  static const String logo = '$_imagesPath/logo.png';
  static const String logoSvg = '$_imagesPath/logo.svg';

  // Sosyal medya logoları (giriş butonları için)
  static const String googleLogo = '$_imagesPath/google_logo.png';
  static const String githubLogo = '$_imagesPath/github_logo.png';
  static const String facebookLogo = '$_imagesPath/facebook_logo.png';
  static const String appleLogo = '$_imagesPath/apple_logo.png';

  // Sosyal medya ikonları (küçük boyutlu)
  static const String googleIcon = '$_iconsPath/google.png';
  static const String githubIcon = '$_iconsPath/github.png';
  static const String facebookIcon = '$_iconsPath/facebook.png';
  static const String appleIcon = '$_iconsPath/apple.png';

  // Harita marker ikonları
  static const String userMarker = '$_iconsPath/user_marker.png';
  static const String eventMarker = '$_iconsPath/event_marker.png';
  static const String communityMarker = '$_iconsPath/community_marker.png';
  static const String placeMarker = '$_iconsPath/place_marker.png';

  // Lottie animasyonları - Boş durum
  static const String emptyAnimation = '$_animationsPath/empty.json';
  static const String noEventsAnimation = '$_animationsPath/no_events.json';
  static const String noCommunityAnimation =
      '$_animationsPath/no_community.json';

  // Lottie animasyonları - Hata durumu
  static const String errorAnimation = '$_animationsPath/error.json';
  static const String noConnectionAnimation =
      '$_animationsPath/no_connection.json';
  static const String serverErrorAnimation =
      '$_animationsPath/server_error.json';

  // Lottie animasyonları - Başarı durumu
  static const String successAnimation = '$_animationsPath/success.json';
  static const String saveSuccessAnimation =
      '$_animationsPath/save_success.json';
  static const String updateSuccessAnimation =
      '$_animationsPath/update_success.json';

  // Harita stilleri
  static const String darkMapStyle = '$_mapStylesPath/dark_style.json';
  static const String lightMapStyle = '$_mapStylesPath/light_style.json';

  // Splash ve launcher ikonları
  static const String splashImage = '$_imagesPath/splash.png';
  static const String splashAndroid12 = '$_imagesPath/splash_android12.png';
  static const String appIcon = '$_iconsPath/app_icon.png';
  static const String appIconAdaptive = '$_iconsPath/app_icon_adaptive.png';
}
