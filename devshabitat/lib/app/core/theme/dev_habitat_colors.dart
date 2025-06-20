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
  static const primaryBlue = Color(0xFF0066FF);
  static const primaryPurple = Color(0xFF7C3AED);
  static const primaryGreen = Color(0xFF00D9FF);

  // Background Colors
  static const darkBackground = Color(0xFF1A1A1A);
  static const darkSurface = Color(0xFF2A2A2A);
  static const darkCard = Color(0xFF2A2A2A);
  static const darkBorder = Color(0xFF3A3A3A);

  static const lightBackground = Color(0xFFF5F5F5);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE0E0E0);

  // Text Colors
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xB3FFFFFF);
  static const textTertiary = Color(0x80FFFFFF);
  static const textDark = Color(0xFF1A1A24);
  static const textGray = Color(0xFF64748B);

  // Status Colors
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFE53935);
  static const warning = Color(0xFFFFA726);
  static const info = Color(0xFF29B6F6);

  // Accent Colors
  static const accentGreen = Color(0xFF10B981);
  static const accentOrange = Color(0xFFF59E0B);
  static const accentPurple = Color(0xFF8B5CF6);
  static const accentPink = Color(0xFFEC4899);
  static const accentYellow = Color(0xFFFACC15);
  static const accentTeal = Color(0xFF14B8A6);
  static const accentIndigo = Color(0xFF6366F1);
  static const accentRed = Color(0xFFEF4444);

  // Glass Effect Colors
  static const glassBackground = Color(0x1AFFFFFF);
  static const glassBorder = Color(0x33FFFFFF);

  // Shadow Colors
  static const shadowDark = Color(0x40000000);
  static const shadowLight = Color(0x1A000000);
  static const shadowMedium = Color(0x33000000);

  // Developer Specific Colors
  static const codeBackground = Color(0xFF1E1E2E);
  static const codeBorder = Color(0xFF2A2A3E);
  static const skillTagBackground = Color(0x1A7C3AED);
  static const skillTagBorder = Color(0x337C3AED);

  // Online Status
  static const online = Color(0xFF10B981);
  static const away = Color(0xFFF59E0B);
  static const busy = Color(0xFFEF4444);
  static const offline = Color(0xFF64748B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C63FF), Color(0xFF4A45B3)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00D4FF), Color(0xFF0094B3)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00F5FF), Color(0xFF00D9FF), Color(0xFF7C3AED)],
  );

  // New colors from the code block
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color divider = Color(0xFFBDBDBD);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x1F000000);
  static const Color buttonBackground = Color(0xFF2196F3);
  static const Color buttonText = Color(0xFFFFFFFF);
  static const Color buttonDisabled = Color(0xFFBDBDBD);
  static const Color inputBackground = Color(0xFFF5F5F5);
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputFocused = Color(0xFF2196F3);
  static const Color inputError = Color(0xFFF44336);
  static const Color snackbarBackground = Color(0xFF323232);
  static const Color snackbarText = Color(0xFFFFFFFF);
  static const Color dialogBackground = Color(0xFFFFFFFF);
  static const Color dialogText = Color(0xFF212121);
  static const Color dialogButton = Color(0xFF2196F3);
  static const Color bottomSheetBackground = Color(0xFFFFFFFF);
  static const Color bottomSheetHandle = Color(0xFFBDBDBD);
  static const Color chipBackground = Color(0xFFE0E0E0);
  static const Color chipText = Color(0xFF212121);
  static const Color chipSelected = Color(0xFF2196F3);
  static const Color chipSelectedText = Color(0xFFFFFFFF);
  static const Color badgeBackground = Color(0xFFF44336);
  static const Color badgeText = Color(0xFFFFFFFF);
  static const Color iconPrimary = Color(0xFF212121);
  static const Color iconSecondary = Color(0xFF757575);
  static const Color iconDisabled = Color(0xFFBDBDBD);
  static const Color progressBackground = Color(0xFFE0E0E0);
  static const Color progressIndicator = Color(0xFF2196F3);
  static const Color switchTrackEnabled = Color(0xFF2196F3);
  static const Color switchTrackDisabled = Color(0xFFBDBDBD);
  static const Color switchThumbEnabled = Color(0xFFFFFFFF);
  static const Color switchThumbDisabled = Color(0xFFFFFFFF);
  static const Color checkboxEnabled = Color(0xFF2196F3);
  static const Color checkboxDisabled = Color(0xFFBDBDBD);
  static const Color checkboxCheck = Color(0xFFFFFFFF);
  static const Color radioEnabled = Color(0xFF2196F3);
  static const Color radioDisabled = Color(0xFFBDBDBD);
  static const Color radioCheck = Color(0xFFFFFFFF);
  static const Color sliderTrackEnabled = Color(0xFF2196F3);
  static const Color sliderTrackDisabled = Color(0xFFBDBDBD);
  static const Color sliderThumbEnabled = Color(0xFF2196F3);
  static const Color sliderThumbDisabled = Color(0xFFBDBDBD);
  static const Color tabBarBackground = Color(0xFFFFFFFF);
  static const Color tabBarIndicator = Color(0xFF2196F3);
  static const Color tabBarLabel = Color(0xFF2196F3);
  static const Color tabBarUnselected = Color(0xFF757575);
  static const Color navigationBarBackground = Color(0xFFFFFFFF);
  static const Color navigationBarSelected = Color(0xFF2196F3);
  static const Color navigationBarUnselected = Color(0xFF757575);
  static const Color drawerBackground = Color(0xFFFFFFFF);
  static const Color drawerSelected = Color(0xFFE3F2FD);
  static const Color drawerUnselected = Color(0xFF757575);
  static const Color tooltipBackground = Color(0xFF616161);
  static const Color tooltipText = Color(0xFFFFFFFF);
  static const Color overlayLight = Color(0x1F000000);
  static const Color overlayDark = Color(0x1FFFFFFF);
}
