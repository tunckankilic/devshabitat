class AppAssets {
  // Temel dosya yolları
  static const String _imagesPath = 'assets/images';
  static const String _iconsPath = 'assets/icons';
  static const String _animationsPath = 'assets/animations';
  static const String _mapStylesPath = 'assets/map_styles';
  static const String _soundsPath = 'assets/sounds';

  // Logo ve marka (Login/Auth ekranlarında kullanılıyor)
  static const String logo = '$_imagesPath/logo.svg';

  // Sosyal medya ikonları (Auth ekranlarında kullanılıyor)
  static const String googleIcon = '$_iconsPath/baseline_google_black_48dp.png';
  static const String appleIcon = '$_iconsPath/apple-logo.png';

  // Harita marker ikonları (MapMarkerService'de kullanılıyor)
  static const String userMarker = '$_iconsPath/user_marker.png';
  static const String eventMarker = '$_iconsPath/event_marker.png';
  static const String communityMarker = '$_iconsPath/community_marker.png';
  static const String placeMarker = '$_iconsPath/place_marker.png';

  // Lottie animasyonları - Boş durum (EmptyStateWidget'ta kullanılıyor)
  static const String emptyAnimation = '$_animationsPath/empty.json';
  static const String noEventsAnimation = '$_animationsPath/no_events.json';
  static const String noCommunityAnimation =
      '$_animationsPath/no_community.json';

  // Lottie animasyonları - Hata durumu (ErrorStateWidget'ta kullanılıyor)
  static const String errorAnimation = '$_animationsPath/error.json';
  static const String noConnectionAnimation =
      '$_animationsPath/no_connection.json';
  static const String serverErrorAnimation =
      '$_animationsPath/server_error.json';

  // Lottie animasyonları - Başarı durumu (SuccessAnimationWidget'ta kullanılıyor)
  static const String successAnimation = '$_animationsPath/success.json';
  static const String saveSuccessAnimation =
      '$_animationsPath/save_success.json';
  static const String updateSuccessAnimation =
      '$_animationsPath/update_success.json';

  // Harita stilleri (MapController ve MapTheme'de kullanılıyor)
  static const String darkMapStyle = '$_mapStylesPath/dark_style.json';
  static const String lightMapStyle = '$_mapStylesPath/light_style.json';

  // Ses dosyaları (Messaging ve Notification için)
  static const String messageSound = '$_soundsPath/message.mp3';
  static const String notificationSound = '$_soundsPath/notification.mp3';
}
