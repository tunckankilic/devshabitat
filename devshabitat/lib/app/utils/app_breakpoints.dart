class AppBreakpoints {
  // Ekran boyutu kırılım noktaları
  static const double mobile = 360;
  static const double tablet = 768;
  static const double desktop = 1024;

  // Padding ve margin değerleri
  static const double paddingXS = 4;
  static const double paddingS = 8;
  static const double paddingM = 16;
  static const double paddingL = 24;
  static const double paddingXL = 32;

  // Border radius değerleri
  static const double radiusS = 4;
  static const double radiusM = 8;
  static const double radiusL = 16;
  static const double radiusXL = 24;

  // Font boyutları
  static const double fontSizeXS = 12;
  static const double fontSizeS = 14;
  static const double fontSizeM = 16;
  static const double fontSizeL = 18;
  static const double fontSizeXL = 20;
  static const double fontSizeXXL = 24;

  // Icon boyutları
  static const double iconSizeS = 16;
  static const double iconSizeM = 24;
  static const double iconSizeL = 32;
  static const double iconSizeXL = 48;

  // Responsive değerler
  static double getResponsiveValue({
    required double mobile,
    required double tablet,
    required double desktop,
    required double screenWidth,
  }) {
    if (screenWidth <= AppBreakpoints.mobile) {
      return mobile;
    } else if (screenWidth <= AppBreakpoints.tablet) {
      return tablet;
    } else {
      return desktop;
    }
  }
}
