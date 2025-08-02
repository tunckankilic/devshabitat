// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'dev_habitat_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'responsive_theme_helper.dart';

class DevHabitatTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: DevHabitatColors.primary,
        secondary: DevHabitatColors.secondary,
        surface: DevHabitatColors.darkSurface,
        error: DevHabitatColors.error,
      ),
      scaffoldBackgroundColor: DevHabitatColors.darkBackground,
      cardTheme: CardThemeData(
        color: DevHabitatColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: DevHabitatColors.darkBorder, width: 1),
        ),
        margin: EdgeInsets.all(16),
        elevation: 2,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: DevHabitatColors.darkBackground,
        elevation: 0,
        centerTitle: ResponsiveThemeHelper.appBarCenterTitle,
        iconTheme: const IconThemeData(color: DevHabitatColors.textPrimary),
        titleTextStyle: TextStyle(
          color: DevHabitatColors.textPrimary,
          fontSize: ResponsiveThemeHelper.appBarTitleSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: DevHabitatColors.textPrimary,
          fontSize: ResponsiveThemeHelper.displayLarge,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: DevHabitatColors.textPrimary,
          fontSize: ResponsiveThemeHelper.displayMedium,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: DevHabitatColors.textPrimary,
          fontSize: ResponsiveThemeHelper.displaySmall,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: DevHabitatColors.textPrimary,
          fontSize: ResponsiveThemeHelper.headlineMedium,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: DevHabitatColors.textPrimary,
          fontSize: ResponsiveThemeHelper.headlineSmall,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: DevHabitatColors.textPrimary,
          fontSize: ResponsiveThemeHelper.titleLarge,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: DevHabitatColors.textPrimary,
          fontSize: ResponsiveThemeHelper.bodyLarge,
        ),
        bodyMedium: TextStyle(
          color: DevHabitatColors.textSecondary,
          fontSize: ResponsiveThemeHelper.bodyMedium,
        ),
        bodySmall: TextStyle(
          color: DevHabitatColors.textTertiary,
          fontSize: ResponsiveThemeHelper.bodySmall,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DevHabitatColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: DevHabitatColors.darkBorder,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: DevHabitatColors.darkBorder,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: DevHabitatColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DevHabitatColors.error, width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DevHabitatColors.primary,
          foregroundColor: Colors.white,
          padding: ResponsiveThemeHelper.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DevHabitatColors.primary,
          side: const BorderSide(color: DevHabitatColors.primary),
          padding: ResponsiveThemeHelper.outlinedButtonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DevHabitatColors.primary,
          padding: ResponsiveThemeHelper.textButtonPadding,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      iconTheme: IconThemeData(
        color: DevHabitatColors.textPrimary,
        size: ResponsiveThemeHelper.iconSize,
      ),
      dividerTheme: DividerThemeData(
        color: DevHabitatColors.darkBorder,
        thickness: 1,
        space: 24,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: DevHabitatColors.darkBackground,
        selectedItemColor: DevHabitatColors.primary,
        unselectedItemColor: DevHabitatColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 1 <= 600 ? 12 : 14),
        unselectedLabelStyle: TextStyle(fontSize: 1 <= 600 ? 12 : 14),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: DevHabitatColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        sizeConstraints: BoxConstraints(
          minWidth: 1 <= 600 ? 40 : 56,
          minHeight: 1 <= 600 ? 40 : 56,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DevHabitatColors.darkCard,
        contentTextStyle: TextStyle(
          color: DevHabitatColors.textPrimary,
          fontSize: 1 <= 600 ? 14 : 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: DevHabitatColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: TextStyle(
          color: DevHabitatColors.textPrimary,
          fontSize: 1 <= 600 ? 18 : 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: DevHabitatColors.textSecondary,
          fontSize: 1 <= 600 ? 14 : 16,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: DevHabitatColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: TextStyle(
          color: DevHabitatColors.textPrimary,
          fontSize: 1 <= 600 ? 14 : 16,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: DevHabitatColors.darkCard,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          color: DevHabitatColors.textPrimary,
          fontSize: 1 <= 600 ? 12 : 14,
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ResponsiveThemeHelper.getPlatformTheme(isDark: false);
  }

  // Glass Effect Decorations
  static BoxDecoration get glassDecoration => BoxDecoration(
    color: DevHabitatColors.glassBackground,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: DevHabitatColors.glassBorder, width: 1),
    boxShadow: const [
      BoxShadow(
        color: DevHabitatColors.shadowDark,
        blurRadius: 10,
        spreadRadius: 0,
      ),
    ],
  );

  static BoxDecoration get glassCardDecoration => BoxDecoration(
    color: DevHabitatColors.glassBackground,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: DevHabitatColors.glassBorder, width: 1),
    boxShadow: const [
      BoxShadow(
        color: DevHabitatColors.shadowLight,
        blurRadius: 20,
        spreadRadius: 0,
      ),
    ],
  );

  // Neumorphism Decorations
  static BoxDecoration get neumorphismDecoration => BoxDecoration(
    color: DevHabitatColors.darkBackground,
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [
      BoxShadow(
        color: DevHabitatColors.shadowDark,
        offset: Offset(4, 4),
        blurRadius: 8,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: DevHabitatColors.shadowLight,
        offset: Offset(-4, -4),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ],
  );

  // Custom Text Styles
  static TextStyle get codeTextStyle => GoogleFonts.jetBrainsMono(
    fontSize: 1 <= 600
        ? 12
        : 1 <= 900
        ? 14
        : 16,
    color: DevHabitatColors.textPrimary,
    backgroundColor: DevHabitatColors.codeBackground,
  );

  static TextStyle get skillTagTextStyle => GoogleFonts.roboto(
    fontSize: 1 <= 600
        ? 10
        : 1 <= 900
        ? 12
        : 14,
    fontWeight: FontWeight.w500,
    color: DevHabitatColors.primary,
  );

  static TextStyle get usernameTextStyle => GoogleFonts.roboto(
    fontSize: 1 <= 600
        ? 14
        : 1 <= 900
        ? 16
        : 18,
    fontWeight: FontWeight.bold,
    color: DevHabitatColors.textPrimary,
  );

  static TextStyle get statusTextStyle => GoogleFonts.roboto(
    fontSize: 1 <= 600
        ? 10
        : 1 <= 900
        ? 12
        : 14,
    color: DevHabitatColors.textSecondary,
  );

  static TextStyle get titleLarge => GoogleFonts.roboto(
    fontSize: 1 <= 600
        ? 20
        : 1 <= 900
        ? 24
        : 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle get titleMedium => GoogleFonts.roboto(
    fontSize: 1 <= 600
        ? 18
        : 1 <= 900
        ? 20
        : 24,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get titleSmall => GoogleFonts.roboto(
    fontSize: 1 <= 600
        ? 14
        : 1 <= 900
        ? 16
        : 18,
    fontWeight: FontWeight.w200,
    color: Colors.white,
  );

  static TextStyle get bodyLarge => GoogleFonts.roboto(
    fontSize: 1 <= 600
        ? 14
        : 1 <= 900
        ? 16
        : 18,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );

  static TextStyle get bodyMedium => GoogleFonts.roboto(
    fontSize: 1 <= 600
        ? 12
        : 1 <= 900
        ? 14
        : 16,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );

  static TextStyle get bodySmall => GoogleFonts.roboto(
    fontSize: 1 <= 600
        ? 10
        : 1 <= 900
        ? 12
        : 14,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );

  static TextStyle get labelLarge => GoogleFonts.roboto(
    fontSize: 1 <= 600
        ? 14
        : 1 <= 900
        ? 16
        : 18,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static TextStyle get labelMedium => GoogleFonts.roboto(
    fontSize: 1 <= 600
        ? 12
        : 1 <= 900
        ? 14
        : 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static TextStyle get labelSmall => GoogleFonts.roboto(
    fontSize: 1 <= 600
        ? 10
        : 1 <= 900
        ? 12
        : 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  // Headline Styles
  static TextStyle get headlineLarge => GoogleFonts.roboto(
    fontSize: 1 <= 600
        ? 28
        : 1 <= 900
        ? 32
        : 36,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: Colors.white,
  );

  static TextStyle get headlineMedium => GoogleFonts.roboto(
    fontSize: 1 <= 600
        ? 24
        : 1 <= 900
        ? 28
        : 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    color: Colors.white,
  );

  static TextStyle get headlineSmall => GoogleFonts.roboto(
    fontSize: 1 <= 600
        ? 20
        : 1 <= 900
        ? 24
        : 28,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: Colors.white,
  );

  // Platform özel renk paleti
  static final _PlatformColors platformColors = _PlatformColors();

  // Platform özel metin stilleri
  static final _PlatformTextStyles platformTextStyles = _PlatformTextStyles();

  // Platform özel dekorasyon stilleri
  static final _PlatformDecorations platformDecorations =
      _PlatformDecorations();
}

class _PlatformColors {
  // Ana renkler
  Color get primary =>
      Platform.isIOS ? CupertinoColors.systemBlue : Colors.blue;

  Color get secondary =>
      Platform.isIOS ? CupertinoColors.systemGrey : Colors.grey;

  Color get success =>
      Platform.isIOS ? CupertinoColors.systemGreen : Colors.green;

  Color get warning =>
      Platform.isIOS ? CupertinoColors.systemYellow : Colors.orange;

  Color get error => Platform.isIOS ? CupertinoColors.systemRed : Colors.red;

  Color get info =>
      Platform.isIOS ? CupertinoColors.systemBlue : Colors.lightBlue;

  // Metin renkleri
  Color get textPrimary =>
      Platform.isIOS ? CupertinoColors.label : Colors.black87;

  Color get textSecondary =>
      Platform.isIOS ? CupertinoColors.secondaryLabel : Colors.black54;

  Color get textDisabled =>
      Platform.isIOS ? CupertinoColors.tertiaryLabel : Colors.black38;

  // Arka plan renkleri
  Color get background =>
      Platform.isIOS ? CupertinoColors.systemBackground : Colors.white;

  Color get surface => Platform.isIOS
      ? CupertinoColors.secondarySystemBackground
      : Colors.grey[50]!;

  Color get divider =>
      Platform.isIOS ? CupertinoColors.separator : Colors.grey[300]!;
}

class _PlatformTextStyles {
  // Başlık stilleri
  TextStyle get headline1 => Platform.isIOS
      ? const TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.25,
        )
      : const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.5,
        );

  TextStyle get headline2 => Platform.isIOS
      ? const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.25,
        )
      : const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        );

  // Gövde metni stilleri
  TextStyle get body1 => Platform.isIOS
      ? const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.normal,
          letterSpacing: -0.24,
        )
      : const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5,
        );

  TextStyle get body2 => Platform.isIOS
      ? const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          letterSpacing: -0.24,
        )
      : const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
        );

  // Buton metni stilleri
  TextStyle get button => Platform.isIOS
      ? const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
        )
      : const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.25,
        );
}

class _PlatformDecorations {
  // Kart dekorasyonu
  BoxDecoration get card => Platform.isIOS
      ? BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        )
      : BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );

  // Input dekorasyonu
  BoxDecoration get input => Platform.isIOS
      ? BoxDecoration(
          color: CupertinoColors.systemBackground,
          border: Border.all(color: CupertinoColors.systemGrey4, width: 0.5),
          borderRadius: BorderRadius.circular(8),
        )
      : BoxDecoration(
          color: Colors.grey[50],
          border: Border.all(color: Colors.grey[300]!, width: 1),
          borderRadius: BorderRadius.circular(4),
        );

  // Dialog dekorasyonu
  BoxDecoration get dialog => Platform.isIOS
      ? BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(14),
        )
      : BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 24),
          ],
        );
}

// Cam efektli container widget'ı
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double blurRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.blurRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: DevHabitatColors.glassBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: DevHabitatColors.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: DevHabitatColors.shadowDark,
            blurRadius: blurRadius,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}

// Responsive boşluk widget'ı
class AdaptiveSpacing extends StatelessWidget {
  final double mobile;
  final double tablet;
  final double desktop;
  final bool isVertical;

  const AdaptiveSpacing({
    super.key,
    this.mobile = 8,
    this.tablet = 16,
    this.desktop = 24,
    this.isVertical = true,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = 1 <= 600
        ? mobile
        : 1 <= 900
        ? tablet
        : desktop;
    return isVertical ? SizedBox(height: spacing) : SizedBox(width: spacing);
  }
}
