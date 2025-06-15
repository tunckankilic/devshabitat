import 'package:flutter/material.dart';
import 'dev_habitat_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DevHabitatTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: DevHabitatColors.primary,
        secondary: DevHabitatColors.secondary,
        background: DevHabitatColors.darkBackground,
        surface: DevHabitatColors.darkSurface,
        error: DevHabitatColors.error,
      ),
      scaffoldBackgroundColor: DevHabitatColors.darkBackground,
      cardTheme: CardThemeData(
        color: DevHabitatColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: const BorderSide(
            color: DevHabitatColors.darkBorder,
            width: 1,
          ),
        ),
        margin: EdgeInsets.all(16.w),
        elevation: 2,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: DevHabitatColors.darkBackground,
        elevation: 0,
        centerTitle: 1.sw <= 600,
        iconTheme: const IconThemeData(color: DevHabitatColors.textPrimary),
        titleTextStyle: TextStyle(
          color: DevHabitatColors.textPrimary,
          fontSize: 1.sw <= 600 ? 20.sp : 24.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: DevHabitatColors.textPrimary,
          fontSize: 1.sw <= 600
              ? 32.sp
              : 1.sw <= 900
                  ? 36.sp
                  : 40.sp,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: DevHabitatColors.textPrimary,
          fontSize: 1.sw <= 600
              ? 28.sp
              : 1.sw <= 900
                  ? 32.sp
                  : 36.sp,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: DevHabitatColors.textPrimary,
          fontSize: 1.sw <= 600
              ? 24.sp
              : 1.sw <= 900
                  ? 28.sp
                  : 32.sp,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: DevHabitatColors.textPrimary,
          fontSize: 1.sw <= 600
              ? 20.sp
              : 1.sw <= 900
                  ? 24.sp
                  : 28.sp,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: DevHabitatColors.textPrimary,
          fontSize: 1.sw <= 600
              ? 18.sp
              : 1.sw <= 900
                  ? 20.sp
                  : 24.sp,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: DevHabitatColors.textPrimary,
          fontSize: 1.sw <= 600
              ? 16.sp
              : 1.sw <= 900
                  ? 18.sp
                  : 20.sp,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: DevHabitatColors.textPrimary,
          fontSize: 1.sw <= 600
              ? 16.sp
              : 1.sw <= 900
                  ? 18.sp
                  : 20.sp,
        ),
        bodyMedium: TextStyle(
          color: DevHabitatColors.textSecondary,
          fontSize: 1.sw <= 600
              ? 14.sp
              : 1.sw <= 900
                  ? 16.sp
                  : 18.sp,
        ),
        bodySmall: TextStyle(
          color: DevHabitatColors.textTertiary,
          fontSize: 1.sw <= 600
              ? 12.sp
              : 1.sw <= 900
                  ? 14.sp
                  : 16.sp,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DevHabitatColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(
            color: DevHabitatColors.darkBorder,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(
            color: DevHabitatColors.darkBorder,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(
            color: DevHabitatColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(
            color: DevHabitatColors.error,
            width: 1,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DevHabitatColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: 1.sw <= 600 ? 16.w : 24.w,
            vertical: 1.sw <= 600 ? 12.h : 16.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DevHabitatColors.primary,
          side: const BorderSide(color: DevHabitatColors.primary),
          padding: EdgeInsets.symmetric(
            horizontal: 1.sw <= 600 ? 16.w : 24.w,
            vertical: 1.sw <= 600 ? 12.h : 16.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DevHabitatColors.primary,
          padding: EdgeInsets.symmetric(
            horizontal: 1.sw <= 600 ? 12.w : 16.w,
            vertical: 1.sw <= 600 ? 8.h : 12.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
      iconTheme: IconThemeData(
        color: DevHabitatColors.textPrimary,
        size: 1.sw <= 600 ? 20.sp : 24.sp,
      ),
      dividerTheme: DividerThemeData(
        color: DevHabitatColors.darkBorder,
        thickness: 1,
        space: 24.h,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: DevHabitatColors.darkBackground,
        selectedItemColor: DevHabitatColors.primary,
        unselectedItemColor: DevHabitatColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 1.sw <= 600 ? 12.sp : 14.sp),
        unselectedLabelStyle: TextStyle(fontSize: 1.sw <= 600 ? 12.sp : 14.sp),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: DevHabitatColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        sizeConstraints: BoxConstraints(
          minWidth: 1.sw <= 600 ? 40.w : 56.w,
          minHeight: 1.sw <= 600 ? 40.h : 56.h,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DevHabitatColors.darkCard,
        contentTextStyle: TextStyle(
          color: DevHabitatColors.textPrimary,
          fontSize: 1.sw <= 600 ? 14.sp : 16.sp,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: DevHabitatColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        titleTextStyle: TextStyle(
          color: DevHabitatColors.textPrimary,
          fontSize: 1.sw <= 600 ? 18.sp : 20.sp,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: DevHabitatColors.textSecondary,
          fontSize: 1.sw <= 600 ? 14.sp : 16.sp,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: DevHabitatColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        textStyle: TextStyle(
          color: DevHabitatColors.textPrimary,
          fontSize: 1.sw <= 600 ? 14.sp : 16.sp,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: DevHabitatColors.darkCard,
          borderRadius: BorderRadius.circular(8.r),
        ),
        textStyle: TextStyle(
          color: DevHabitatColors.textPrimary,
          fontSize: 1.sw <= 600 ? 12.sp : 14.sp,
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: DevHabitatColors.primary,
        secondary: DevHabitatColors.secondary,
        background: DevHabitatColors.lightBackground,
        surface: DevHabitatColors.lightSurface,
        error: DevHabitatColors.error,
      ),
      scaffoldBackgroundColor: DevHabitatColors.lightBackground,
      cardTheme: CardThemeData(
        color: DevHabitatColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: const BorderSide(
            color: DevHabitatColors.lightBorder,
            width: 1,
          ),
        ),
        margin: EdgeInsets.all(16.w),
        elevation: 2,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: DevHabitatColors.lightBackground,
        elevation: 0,
        centerTitle: 1.sw <= 600,
        iconTheme: const IconThemeData(color: DevHabitatColors.textDark),
        titleTextStyle: TextStyle(
          color: DevHabitatColors.textDark,
          fontSize: 1.sw <= 600 ? 20.sp : 24.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: DevHabitatColors.textDark,
          fontSize: 1.sw <= 600
              ? 32.sp
              : 1.sw <= 900
                  ? 36.sp
                  : 40.sp,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: DevHabitatColors.textDark,
          fontSize: 1.sw <= 600
              ? 28.sp
              : 1.sw <= 900
                  ? 32.sp
                  : 36.sp,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: DevHabitatColors.textDark,
          fontSize: 1.sw <= 600
              ? 24.sp
              : 1.sw <= 900
                  ? 28.sp
                  : 32.sp,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: DevHabitatColors.textDark,
          fontSize: 1.sw <= 600
              ? 20.sp
              : 1.sw <= 900
                  ? 24.sp
                  : 28.sp,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: DevHabitatColors.textDark,
          fontSize: 1.sw <= 600
              ? 18.sp
              : 1.sw <= 900
                  ? 20.sp
                  : 24.sp,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: DevHabitatColors.textDark,
          fontSize: 1.sw <= 600
              ? 16.sp
              : 1.sw <= 900
                  ? 18.sp
                  : 20.sp,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: DevHabitatColors.textDark,
          fontSize: 1.sw <= 600
              ? 16.sp
              : 1.sw <= 900
                  ? 18.sp
                  : 20.sp,
        ),
        bodyMedium: TextStyle(
          color: DevHabitatColors.textGray,
          fontSize: 1.sw <= 600
              ? 14.sp
              : 1.sw <= 900
                  ? 16.sp
                  : 18.sp,
        ),
        bodySmall: TextStyle(
          color: DevHabitatColors.textGray.withOpacity(0.7),
          fontSize: 1.sw <= 600
              ? 12.sp
              : 1.sw <= 900
                  ? 14.sp
                  : 16.sp,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DevHabitatColors.lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(
            color: DevHabitatColors.lightBorder,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(
            color: DevHabitatColors.lightBorder,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(
            color: DevHabitatColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(
            color: DevHabitatColors.error,
            width: 1,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DevHabitatColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: 1.sw <= 600 ? 16.w : 24.w,
            vertical: 1.sw <= 600 ? 12.h : 16.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DevHabitatColors.primary,
          side: const BorderSide(color: DevHabitatColors.primary),
          padding: EdgeInsets.symmetric(
            horizontal: 1.sw <= 600 ? 16.w : 24.w,
            vertical: 1.sw <= 600 ? 12.h : 16.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DevHabitatColors.primary,
          padding: EdgeInsets.symmetric(
            horizontal: 1.sw <= 600 ? 12.w : 16.w,
            vertical: 1.sw <= 600 ? 8.h : 12.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
      iconTheme: IconThemeData(
        color: DevHabitatColors.textDark,
        size: 1.sw <= 600 ? 20.sp : 24.sp,
      ),
      dividerTheme: DividerThemeData(
        color: DevHabitatColors.lightBorder,
        thickness: 1,
        space: 24.h,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: DevHabitatColors.lightBackground,
        selectedItemColor: DevHabitatColors.primary,
        unselectedItemColor: DevHabitatColors.textGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 1.sw <= 600 ? 12.sp : 14.sp),
        unselectedLabelStyle: TextStyle(fontSize: 1.sw <= 600 ? 12.sp : 14.sp),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: DevHabitatColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        sizeConstraints: BoxConstraints(
          minWidth: 1.sw <= 600 ? 40.w : 56.w,
          minHeight: 1.sw <= 600 ? 40.h : 56.h,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DevHabitatColors.lightCard,
        contentTextStyle: TextStyle(
          color: DevHabitatColors.textDark,
          fontSize: 1.sw <= 600 ? 14.sp : 16.sp,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: DevHabitatColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        titleTextStyle: TextStyle(
          color: DevHabitatColors.textDark,
          fontSize: 1.sw <= 600 ? 18.sp : 20.sp,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: DevHabitatColors.textGray,
          fontSize: 1.sw <= 600 ? 14.sp : 16.sp,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: DevHabitatColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        textStyle: TextStyle(
          color: DevHabitatColors.textDark,
          fontSize: 1.sw <= 600 ? 14.sp : 16.sp,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: DevHabitatColors.lightCard,
          borderRadius: BorderRadius.circular(8.r),
        ),
        textStyle: TextStyle(
          color: DevHabitatColors.textDark,
          fontSize: 1.sw <= 600 ? 12.sp : 14.sp,
        ),
      ),
    );
  }

  // Glass Effect Decorations
  static BoxDecoration get glassDecoration => BoxDecoration(
        color: DevHabitatColors.glassBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: DevHabitatColors.glassBorder,
          width: 1,
        ),
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
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: DevHabitatColors.glassBorder,
          width: 1,
        ),
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
        borderRadius: BorderRadius.circular(16.r),
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
        fontSize: 1.sw <= 600
            ? 12.sp
            : 1.sw <= 900
                ? 14.sp
                : 16.sp,
        color: DevHabitatColors.textPrimary,
        backgroundColor: DevHabitatColors.codeBackground,
      );

  static TextStyle get skillTagTextStyle => GoogleFonts.roboto(
        fontSize: 1.sw <= 600
            ? 10.sp
            : 1.sw <= 900
                ? 12.sp
                : 14.sp,
        fontWeight: FontWeight.w500,
        color: DevHabitatColors.primary,
      );

  static TextStyle get usernameTextStyle => GoogleFonts.roboto(
        fontSize: 1.sw <= 600
            ? 14.sp
            : 1.sw <= 900
                ? 16.sp
                : 18.sp,
        fontWeight: FontWeight.bold,
        color: DevHabitatColors.textPrimary,
      );

  static TextStyle get statusTextStyle => GoogleFonts.roboto(
        fontSize: 1.sw <= 600
            ? 10.sp
            : 1.sw <= 900
                ? 12.sp
                : 14.sp,
        color: DevHabitatColors.textSecondary,
      );

  static TextStyle get titleLarge => GoogleFonts.roboto(
        fontSize: 1.sw <= 600
            ? 20.sp
            : 1.sw <= 900
                ? 24.sp
                : 28.sp,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

  static TextStyle get titleMedium => GoogleFonts.roboto(
        fontSize: 1.sw <= 600
            ? 18.sp
            : 1.sw <= 900
                ? 20.sp
                : 24.sp,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get titleSmall => GoogleFonts.roboto(
        fontSize: 1.sw <= 600
            ? 14.sp
            : 1.sw <= 900
                ? 16.sp
                : 18.sp,
        fontWeight: FontWeight.w200,
        color: Colors.white,
      );

  static TextStyle get bodyLarge => GoogleFonts.roboto(
        fontSize: 1.sw <= 600
            ? 14.sp
            : 1.sw <= 900
                ? 16.sp
                : 18.sp,
        fontWeight: FontWeight.normal,
        color: Colors.white,
      );

  static TextStyle get bodyMedium => GoogleFonts.roboto(
        fontSize: 1.sw <= 600
            ? 12.sp
            : 1.sw <= 900
                ? 14.sp
                : 16.sp,
        fontWeight: FontWeight.normal,
        color: Colors.white,
      );

  static TextStyle get bodySmall => GoogleFonts.roboto(
        fontSize: 1.sw <= 600
            ? 10.sp
            : 1.sw <= 900
                ? 12.sp
                : 14.sp,
        fontWeight: FontWeight.normal,
        color: Colors.white,
      );

  static TextStyle get labelLarge => GoogleFonts.roboto(
        fontSize: 1.sw <= 600
            ? 14.sp
            : 1.sw <= 900
                ? 16.sp
                : 18.sp,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      );

  static TextStyle get labelMedium => GoogleFonts.roboto(
        fontSize: 1.sw <= 600
            ? 12.sp
            : 1.sw <= 900
                ? 14.sp
                : 16.sp,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      );

  static TextStyle get labelSmall => GoogleFonts.roboto(
        fontSize: 1.sw <= 600
            ? 10.sp
            : 1.sw <= 900
                ? 12.sp
                : 14.sp,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      );

  // Headline Styles
  static TextStyle get headlineLarge => GoogleFonts.roboto(
        fontSize: 1.sw <= 600
            ? 28.sp
            : 1.sw <= 900
                ? 32.sp
                : 36.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        color: Colors.white,
      );

  static TextStyle get headlineMedium => GoogleFonts.roboto(
        fontSize: 1.sw <= 600
            ? 24.sp
            : 1.sw <= 900
                ? 28.sp
                : 32.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        color: Colors.white,
      );

  static TextStyle get headlineSmall => GoogleFonts.roboto(
        fontSize: 1.sw <= 600
            ? 20.sp
            : 1.sw <= 900
                ? 24.sp
                : 28.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: Colors.white,
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
        borderRadius: BorderRadius.circular(borderRadius.r),
        border: Border.all(
          color: DevHabitatColors.glassBorder,
          width: 1,
        ),
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
    final spacing = 1.sw <= 600
        ? mobile
        : 1.sw <= 900
            ? tablet
            : desktop;
    return isVertical
        ? SizedBox(height: spacing.h)
        : SizedBox(width: spacing.w);
  }
}
