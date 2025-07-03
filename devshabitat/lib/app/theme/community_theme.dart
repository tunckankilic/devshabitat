import 'package:flutter/material.dart';

class CommunityTheme {
  static const double cardBorderRadius = 16.0;
  static const double avatarSize = 48.0;
  static const double spacing = 16.0;
  static const double padding = 16.0;

  static ThemeData getTheme(bool isDarkMode) {
    final baseTheme = isDarkMode ? ThemeData.dark() : ThemeData.light();
    final colorScheme = isDarkMode
        ? const ColorScheme.dark(
            primary: Color(0xFF9C27B0),
            secondary: Color(0xFFBA68C8),
            surface: Color(0xFF1E1E1E),
            background: Color(0xFF121212),
            error: Color(0xFFCF6679),
          )
        : const ColorScheme.light(
            primary: Color(0xFF9C27B0),
            secondary: Color(0xFFBA68C8),
            surface: Color(0xFFFFFFFF),
            background: Color(0xFFF5F5F5),
            error: Color(0xFFB00020),
          );

    return baseTheme.copyWith(
      colorScheme: colorScheme,
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
        ),
        color: colorScheme.surface,
      ),
      textTheme: baseTheme.textTheme.copyWith(
        titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: baseTheme.textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.8),
          fontSize: 16,
        ),
        bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.7),
          fontSize: 14,
        ),
      ),
    );
  }

  static BoxDecoration communityCardDecoration(bool isDarkMode) {
    return BoxDecoration(
      color: isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(cardBorderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration memberCountChipDecoration(bool isDarkMode) {
    return BoxDecoration(
      color: isDarkMode ? const Color(0xFF3C3C3C) : const Color(0xFFF0F0F0),
      borderRadius: BorderRadius.circular(20),
    );
  }

  static TextStyle memberCountStyle(bool isDarkMode) {
    return TextStyle(
      color: isDarkMode
          ? const Color(0xFFFFFFFF).withOpacity(0.7)
          : const Color(0xFF000000).withOpacity(0.7),
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle descriptionStyle(bool isDarkMode) {
    return TextStyle(
      color: isDarkMode
          ? const Color(0xFFFFFFFF).withOpacity(0.7)
          : const Color(0xFF000000).withOpacity(0.7),
      fontSize: 14,
      height: 1.5,
    );
  }

  static TextStyle categoryStyle(bool isDarkMode) {
    return TextStyle(
      color: isDarkMode ? const Color(0xFFBA68C8) : const Color(0xFF9C27B0),
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
  }
}
