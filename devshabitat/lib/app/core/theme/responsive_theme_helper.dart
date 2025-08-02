import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import '../../controllers/responsive_controller.dart';
import 'package:get/get.dart';

class ResponsiveThemeHelper {
  static final ResponsiveController _responsive =
      Get.find<ResponsiveController>();

  // AppBar özellikleri
  static bool get appBarCenterTitle => _responsive.isMobile;
  static double get appBarTitleSize =>
      _responsive.responsiveValue(mobile: 20, tablet: 24);

  // Font boyutları
  static double get displayLarge =>
      _responsive.responsiveValue(mobile: 32, tablet: 48);
  static double get displayMedium =>
      _responsive.responsiveValue(mobile: 28, tablet: 40);
  static double get displaySmall =>
      _responsive.responsiveValue(mobile: 24, tablet: 32);
  static double get headlineMedium =>
      _responsive.responsiveValue(mobile: 20, tablet: 28);
  static double get headlineSmall =>
      _responsive.responsiveValue(mobile: 18, tablet: 24);
  static double get titleLarge =>
      _responsive.responsiveValue(mobile: 16, tablet: 20);
  static double get bodyLarge =>
      _responsive.responsiveValue(mobile: 16, tablet: 18);
  static double get bodyMedium =>
      _responsive.responsiveValue(mobile: 14, tablet: 16);
  static double get bodySmall =>
      _responsive.responsiveValue(mobile: 12, tablet: 14);

  // Padding değerleri
  static EdgeInsets get buttonPadding => _responsive.responsiveValue(
    mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    tablet: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  );
  static EdgeInsets get outlinedButtonPadding => buttonPadding;
  static EdgeInsets get textButtonPadding => _responsive.responsiveValue(
    mobile: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    tablet: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  // İkon boyutu
  static double get iconSize =>
      _responsive.responsiveValue(mobile: 20, tablet: 24);

  // Platform bazlı tema ayarları
  static ThemeData getPlatformTheme({required bool isDark}) {
    if (Platform.isIOS) {
      return _getIOSTheme(isDark);
    }
    return _getAndroidTheme(isDark);
  }

  // iOS teması
  static ThemeData _getIOSTheme(bool isDark) {
    final base = ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primaryColor: CupertinoColors.systemBlue,
        barBackgroundColor: isDark
            ? CupertinoColors.systemBackground.darkColor
            : CupertinoColors.systemBackground.color,
        scaffoldBackgroundColor: isDark
            ? CupertinoColors.systemBackground.darkColor
            : CupertinoColors.systemBackground.color,
      ),
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDark
            ? CupertinoColors.systemBackground.darkColor
            : CupertinoColors.systemBackground.color,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? CupertinoColors.white : CupertinoColors.black,
        ),
        titleTextStyle: TextStyle(
          color: isDark ? CupertinoColors.white : CupertinoColors.black,
          fontSize: _responsive.responsiveValue(mobile: 17, tablet: 20),
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: _getResponsiveTextTheme(base.textTheme),
      cardTheme: CardThemeData(
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(
          _responsive.responsiveValue(mobile: 8, tablet: 12),
        ),
      ),
    );
  }

  // Android teması
  static ThemeData _getAndroidTheme(bool isDark) {
    final base = ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      useMaterial3: true,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: _responsive.responsiveValue(mobile: 20, tablet: 24),
          fontWeight: FontWeight.w500,
        ),
      ),
      textTheme: _getResponsiveTextTheme(base.textTheme),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.all(
          _responsive.responsiveValue(mobile: 8, tablet: 12),
        ),
      ),
    );
  }

  // Responsive metin teması
  static TextTheme _getResponsiveTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: _responsive.responsiveValue(mobile: 32, tablet: 48),
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: _responsive.responsiveValue(mobile: 28, tablet: 40),
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: _responsive.responsiveValue(mobile: 24, tablet: 32),
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: _responsive.responsiveValue(mobile: 22, tablet: 28),
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: _responsive.responsiveValue(mobile: 20, tablet: 24),
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: _responsive.responsiveValue(mobile: 18, tablet: 22),
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: _responsive.responsiveValue(mobile: 16, tablet: 20),
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: _responsive.responsiveValue(mobile: 14, tablet: 18),
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: _responsive.responsiveValue(mobile: 12, tablet: 16),
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: _responsive.responsiveValue(mobile: 16, tablet: 18),
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: _responsive.responsiveValue(mobile: 14, tablet: 16),
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: _responsive.responsiveValue(mobile: 12, tablet: 14),
      ),
    );
  }

  // Platform bazlı padding değerleri
  static EdgeInsets getPlatformPadding({
    required BuildContext context,
    bool isDialog = false,
  }) {
    final double basePadding = _responsive.responsiveValue(
      mobile: isDialog ? 16 : 12,
      tablet: isDialog ? 24 : 16,
    );

    if (Platform.isIOS) {
      return EdgeInsets.symmetric(
        horizontal: basePadding,
        vertical: isDialog ? basePadding * 0.75 : basePadding,
      );
    }

    return EdgeInsets.all(basePadding);
  }

  // Platform bazlı animasyon süreleri
  static Duration getPlatformAnimationDuration({bool isLong = false}) {
    if (Platform.isIOS) {
      return Duration(milliseconds: isLong ? 400 : 250);
    }
    return Duration(milliseconds: isLong ? 300 : 200);
  }

  // Platform bazlı renk paleti
  static Color getPlatformColor({
    required bool isDark,
    required bool isPrimary,
    bool isDestructive = false,
  }) {
    if (Platform.isIOS) {
      if (isDestructive) return CupertinoColors.destructiveRed;
      if (isPrimary) {
        return isDark
            ? CupertinoColors.systemBlue.darkColor
            : CupertinoColors.systemBlue.color;
      }
      return isDark
          ? CupertinoColors.systemGrey.darkColor
          : CupertinoColors.systemGrey.color;
    }

    if (isDestructive) return Colors.red;
    if (isPrimary) return Colors.blue;
    return Colors.grey;
  }
}
