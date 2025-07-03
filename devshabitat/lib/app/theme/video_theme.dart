import 'package:flutter/material.dart';

class VideoTheme {
  static const double controlBarHeight = 60.0;
  static const double buttonSize = 48.0;
  static const double iconSize = 24.0;
  static const double borderRadius = 12.0;

  static ThemeData getTheme(bool isDarkMode) {
    final baseTheme = isDarkMode ? ThemeData.dark() : ThemeData.light();
    final colorScheme = isDarkMode
        ? const ColorScheme.dark(
            primary: Color(0xFF2196F3),
            secondary: Color(0xFF64B5F6),
            surface: Color(0xFF1E1E1E),
            background: Color(0xFF121212),
            error: Color(0xFFCF6679),
          )
        : const ColorScheme.light(
            primary: Color(0xFF2196F3),
            secondary: Color(0xFF64B5F6),
            surface: Color(0xFFFFFFFF),
            background: Color(0xFFF5F5F5),
            error: Color(0xFFB00020),
          );

    return baseTheme.copyWith(
      colorScheme: colorScheme,
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: iconSize,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(buttonSize, buttonSize),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }

  static BoxDecoration controlBarDecoration(bool isDarkMode) {
    return BoxDecoration(
      color: isDarkMode
          ? const Color(0xFF1E1E1E).withOpacity(0.8)
          : const Color(0xFFFFFFFF).withOpacity(0.8),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration participantContainerDecoration(bool isDarkMode) {
    return BoxDecoration(
      color: isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: isDarkMode ? const Color(0xFF3C3C3C) : const Color(0xFFE0E0E0),
      ),
    );
  }

  static TextStyle participantNameStyle(bool isDarkMode) {
    return TextStyle(
      color: isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle durationStyle(bool isDarkMode) {
    return TextStyle(
      color: isDarkMode
          ? const Color(0xFFFFFFFF).withOpacity(0.7)
          : const Color(0xFF000000).withOpacity(0.7),
      fontSize: 12,
    );
  }
}
