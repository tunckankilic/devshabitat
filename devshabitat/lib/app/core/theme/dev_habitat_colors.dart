import 'package:flutter/material.dart';

class DevHabitatColors {
  // Primary Colors
  static const primary = Color(0xFF6C63FF);
  static const primaryLight = Color(0xFF8A84FF);
  static const primaryDark = Color(0xFF4A45B3);

  // Secondary Colors
  static const secondary = Color(0xFF00D4FF);
  static const secondaryLight = Color(0xFF33DDFF);
  static const secondaryDark = Color(0xFF0094B3);

  // Primary Brand Colors - Tech & Professional
  static const Color primaryBlue = Color(0xFF0066FF);
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color primaryGreen = Color(0xFF00D9FF);

  // Background Colors
  static const background = Color(0xFF1A1A1A);
  static const surface = Color(0xFF2A2A2A);
  static const glassBackground = Color(0x1AFFFFFF);
  static const glassBorder = Color(0x33FFFFFF);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0A0A0F);
  static const Color darkSurface = Color(0xFF1A1A24);
  static const Color darkCard = Color(0xFF252538);
  static const Color darkBorder = Color(0xFF2A2A3E);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFAFAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF8F9FA);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Text Colors
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xB3FFFFFF);
  static const textTertiary = Color(0x80FFFFFF);
  static const Color textDark = Color(0xFF1A1A24);
  static const Color textGray = Color(0xFF64748B);

  // Status Colors
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFE53935);
  static const warning = Color(0xFFFFA726);
  static const info = Color(0xFF29B6F6);

  // Accent Colors
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentPink = Color(0xFFEC4899);

  // Glass Effect Colors
  static const Color glassHighlight = Color(0x0DFFFFFF);

  // Shadow Colors
  static const shadowDark = Color(0x00000000);
  static const shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);

  // Developer Specific Colors
  static const Color codeBackground = Color(0xFF1E1E2E);
  static const Color codeBorder = Color(0xFF2A2A3E);
  static const Color skillTagBackground = Color(0x1A7C3AED);
  static const Color skillTagBorder = Color(0x337C3AED);

  // Online Status
  static const Color online = Color(0xFF10B981);
  static const Color away = Color(0xFFF59E0B);
  static const Color busy = Color(0xFFEF4444);
  static const Color offline = Color(0xFF64748B);

  // Gradients
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [background, surface],
  );

  static const glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1AFFFFFF),
      Color(0x0DFFFFFF),
    ],
  );

  static const secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPurple, primaryGreen],
  );

  static const neonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00F5FF), Color(0xFF00D9FF), Color(0xFF7C3AED)],
  );
}
