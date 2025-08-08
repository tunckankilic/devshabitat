class AppAssets {
  // Temel dosya yolları
  static const String _imagesPath = 'assets/images';
  static const String _iconsPath = 'assets/icons';
  static const String _mapStylesPath = 'assets/map_styles';

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

  // Boş durum görselleri (EmptyStateWidget'ta kullanılıyor)
  static const String emptyImage = '$_imagesPath/empty.png';
  static const String noEventsImage = '$_imagesPath/no_events.png';
  static const String noCommunityImage = '$_imagesPath/no_community.png';

  // Hata durumu görselleri (ErrorStateWidget'ta kullanılıyor)
  static const String errorImage = '$_imagesPath/error.png';
  static const String noConnectionImage = '$_imagesPath/no_connection.png';
  static const String serverErrorImage = '$_imagesPath/server_error.png';

  // Başarı durumu görselleri (SuccessStateWidget'ta kullanılıyor)
  static const String successImage = '$_imagesPath/success.png';
  static const String saveSuccessImage = '$_imagesPath/save_success.png';
  static const String updateSuccessImage = '$_imagesPath/update_success.png';

  // Harita stilleri (MapController ve MapTheme'de kullanılıyor)
  static const String darkMapStyle = '$_mapStylesPath/dark_style.json';
  static const String lightMapStyle = '$_mapStylesPath/light_style.json';
}
