import 'package:flutter/material.dart';

class RegistrationConfig {
  // Validation Constants
  static const Duration validationDebounce = Duration(milliseconds: 800);
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int maxUsernameLength = 30;
  static const int maxBioLength = 500;

  // UI Constants
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const int maxImageSize = 1024 * 1024; // 1MB

  // API Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration locationTimeout = Duration(seconds: 10);

  // Cache Duration
  static const Duration formDataCacheDuration = Duration(hours: 1);

  // Rate Limiting
  static const int maxLoginAttempts = 5;
  static const Duration loginLockoutDuration = Duration(minutes: 15);

  // Security
  static const Duration tokenExpiry = Duration(hours: 1);
  static const int saltRounds = 10;

  // Feature Flags
  static const bool enableGithubIntegration = true;
  static const bool enableLocationServices = true;
  static const bool enableOfflineSupport = true;
}
