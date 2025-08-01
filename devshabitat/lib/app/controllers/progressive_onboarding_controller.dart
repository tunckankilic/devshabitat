import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/enhanced_user_model.dart';
import '../models/profile_completion_model.dart';
import '../services/progressive_onboarding_service.dart';
import '../services/user_service.dart';
import '../services/profile_completion_service.dart';

/// Controller for managing progressive onboarding state and interactions
class ProgressiveOnboardingController extends GetxController {
  static ProgressiveOnboardingController get to => Get.find();

  final ProgressiveOnboardingService _onboardingService =
      ProgressiveOnboardingService.to;
  final UserService _userService = Get.find<UserService>();
  final ProfileCompletionService _profileService = ProfileCompletionService.to;

  // Reactive state
  final _currentProgress = Rxn<Map<String, dynamic>>();
  final _suggestedFeatures = <String>[].obs;
  final _completedPrompts = <String>[].obs;
  final _availableFeatures = <String>[].obs;
  final _isInitialized = false.obs;

  // Session tracking
  final _sessionPrompts = <String, int>{}.obs;
  final _sessionSkips = <String, int>{}.obs;

  // Getters
  Map<String, dynamic>? get currentProgress => _currentProgress.value;
  List<String> get suggestedFeatures => _suggestedFeatures.toList();
  List<String> get completedPrompts => _completedPrompts.toList();
  List<String> get availableFeatures => _availableFeatures.toList();
  bool get isInitialized => _isInitialized.value;

  @override
  void onInit() {
    super.onInit();
    _initializeOnboarding();
  }

  /// Initialize onboarding state
  void _initializeOnboarding() {
    // Initial state if user is already logged in
    if (_userService.currentUser != null) {
      _updateOnboardingState(_userService.currentUser!);
    }

    // Periodic check for user changes (simple polling approach)
    _startUserWatcher();

    _isInitialized.value = true;
  }

  /// Start watching for user changes
  void _startUserWatcher() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      final currentUser = _userService.currentUser;
      final lastUser = _currentProgress.value?['userId'] as String?;

      if (currentUser?.uid != lastUser) {
        if (currentUser != null) {
          _updateOnboardingState(currentUser);
        } else {
          _resetState();
        }
      }
    });
  }

  /// Update onboarding state when user changes
  void _updateOnboardingState(EnhancedUserModel user) {
    try {
      // Get comprehensive progress data
      final progress = _onboardingService.getOnboardingProgress(user);

      // Add user ID for tracking
      progress['userId'] = user.uid;
      _currentProgress.value = progress;

      // Update reactive lists
      _completedPrompts.value =
          List<String>.from(progress['completedPrompts'] ?? []);
      _availableFeatures.value =
          List<String>.from(progress['accessibleFeatures'] ?? []);

      // Update suggested features based on next steps
      final nextSteps =
          progress['suggestedNextSteps'] as List<Map<String, dynamic>>? ?? [];
      _suggestedFeatures.value = nextSteps
          .take(3) // Top 3 suggestions
          .map((step) => step['feature'] as String)
          .toList();
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Onboarding durumu güncellenirken hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Reset onboarding state
  void _resetState() {
    _currentProgress.value = null;
    _suggestedFeatures.clear();
    _completedPrompts.clear();
    _availableFeatures.clear();
    _sessionPrompts.clear();
    _sessionSkips.clear();
  }

  /// Trigger contextual prompt for a feature
  Future<bool> triggerFeaturePrompt(
    String feature, {
    String? customContext,
    bool bypassFrequencyCheck = false,
  }) async {
    final user = _userService.currentUser;
    if (user == null) {
      _showLoginPrompt();
      return false;
    }

    // Check if user already has access
    if (_availableFeatures.contains(feature)) {
      return true;
    }

    // Session frequency check
    if (!bypassFrequencyCheck && _shouldSkipSessionPrompt(feature)) {
      return false;
    }

    // Track session prompt
    _sessionPrompts[feature] = (_sessionPrompts[feature] ?? 0) + 1;

    // Show prompt
    final result = await ProgressiveOnboardingService.showUpgradePrompt(
      feature,
      user,
      customContext: customContext,
    );

    if (result == null) {
      // Prompt was not shown (e.g., already seen recently)
      return false;
    }

    if (result == true) {
      // User chose to complete profile
      await _navigateToProfileCompletion(feature);
      return true;
    } else {
      // User skipped
      _sessionSkips[feature] = (_sessionSkips[feature] ?? 0) + 1;
      return false;
    }
  }

  /// Show quick setup for rapid completion
  Future<bool> showQuickSetup({
    String? targetFeature,
    List<ProfileField>? focusFields,
  }) async {
    final user = _userService.currentUser;
    if (user == null) {
      _showLoginPrompt();
      return false;
    }

    final result = await ProgressiveOnboardingService.showQuickSetup(
      user,
      targetFeature: targetFeature,
      focusFields: focusFields,
    );

    if (result == true) {
      // Refresh state after completion
      await refreshOnboardingState();
      return true;
    }

    return false;
  }

  /// Navigate to appropriate profile completion screen
  Future<void> _navigateToProfileCompletion(String feature) async {
    final user = _userService.currentUser;
    if (user == null) return;

    // Determine the best completion method
    final requiredLevel =
        ProgressiveOnboardingService.featureRequirements[feature] ??
            ProfileCompletionLevel.complete;
    final missingFields =
        _profileService.getMissingFieldsWithDetails(user, requiredLevel);

    if (missingFields.length <= 4) {
      // Use quick setup for few missing fields
      await showQuickSetup(
        targetFeature: feature,
        focusFields: missingFields,
      );
    } else {
      // Navigate to full profile edit
      Get.toNamed('/profile/edit', arguments: {
        'targetFeature': feature,
        'missingFields': missingFields,
      });
    }
  }

  /// Check if we should skip showing prompt in this session
  bool _shouldSkipSessionPrompt(String feature) {
    final promptCount = _sessionPrompts[feature] ?? 0;
    final skipCount = _sessionSkips[feature] ?? 0;

    // Limit prompts per session
    if (promptCount >= 2) return true;
    if (skipCount >= 1) return true;

    return false;
  }

  /// Show login prompt for unauthenticated users
  void _showLoginPrompt() {
    Get.snackbar(
      'Giriş Gerekli',
      'Bu özelliği kullanmak için giriş yapmalısın',
      snackPosition: SnackPosition.BOTTOM,
      mainButton: TextButton(
        onPressed: () => Get.toNamed('/auth'),
        child: const Text('Giriş Yap'),
      ),
    );
  }

  /// Get completion percentage for a specific feature
  double getFeatureCompletionPercentage(String feature) {
    final user = _userService.currentUser;
    if (user == null) return 0.0;

    final requiredLevel =
        ProgressiveOnboardingService.featureRequirements[feature] ??
            ProfileCompletionLevel.complete;
    final currentStatus = _profileService.calculateCompletionLevel(user);

    return (currentStatus.percentage / requiredLevel.percentage * 100)
        .clamp(0.0, 100.0);
  }

  /// Get missing fields for a feature
  List<ProfileField> getMissingFieldsForFeature(String feature) {
    final user = _userService.currentUser;
    if (user == null) return [];

    final requiredLevel =
        ProgressiveOnboardingService.featureRequirements[feature] ??
            ProfileCompletionLevel.complete;
    return _profileService.getMissingFieldsWithDetails(user, requiredLevel);
  }

  /// Get time estimate for feature completion
  String getFeatureTimeEstimate(String feature) {
    final user = _userService.currentUser;
    if (user == null) return '0 dakika';

    final requiredLevel =
        ProgressiveOnboardingService.featureRequirements[feature] ??
            ProfileCompletionLevel.complete;
    final missingFields =
        _profileService.getMissingFieldsWithDetails(user, requiredLevel);

    return _calculateTimeNeeded(missingFields);
  }

  /// Calculate time needed to complete missing fields (local implementation)
  String _calculateTimeNeeded(List<ProfileField> missingFields) {
    if (missingFields.isEmpty) return '0 dakika';

    var minutes = 0;
    for (final field in missingFields) {
      switch (field.name) {
        case 'bio':
          minutes += 60; // 1 minute for bio
          break;
        case 'skills':
          minutes += 90; // 1.5 minutes for skills
          break;
        case 'githubUsername':
          minutes += 30; // 30 seconds
          break;
        case 'workExperience':
          minutes += 120; // 2 minutes
          break;
        case 'education':
          minutes += 90; // 1.5 minutes
          break;
        case 'location':
          minutes += 30; // 30 seconds
          break;
        case 'projects':
          minutes += 180; // 3 minutes
          break;
        case 'socialLinks':
          minutes += 60; // 1 minute
          break;
        default:
          minutes += 30; // Default 30 seconds
      }
    }

    final totalMinutes = (minutes / 60).ceil();

    if (totalMinutes <= 1) return '1 dakika';
    if (totalMinutes <= 2) return '2 dakika';
    if (totalMinutes <= 5) return '3-5 dakika';
    return '5+ dakika';
  }

  /// Check if feature is accessible
  bool isFeatureAccessible(String feature) {
    return _availableFeatures.contains(feature);
  }

  /// Get feature display name
  String getFeatureDisplayName(String feature) {
    const displayNames = {
      'community_join': 'Topluluk Katılımı',
      'project_sharing': 'Proje Paylaşımı',
      'video_calling': 'Video Görüşme',
      'messaging': 'Mesajlaşma',
      'event_creation': 'Etkinlik Oluşturma',
      'mentorship': 'Mentorluk',
      'networking': 'Ağ Oluşturma',
      'portfolio_showcase': 'Portföy Sergileme',
    };

    return displayNames[feature] ?? feature;
  }

  /// Get next suggested feature for user
  String? getNextSuggestedFeature() {
    if (_suggestedFeatures.isEmpty) return null;

    // Return the highest priority feature that hasn't been completed
    for (final feature in _suggestedFeatures) {
      if (!_completedPrompts.contains(feature)) {
        return feature;
      }
    }

    return _suggestedFeatures.first;
  }

  /// Get onboarding statistics
  Map<String, dynamic> getOnboardingStats() {
    final progress = _currentProgress.value;
    if (progress == null) {
      return {
        'completionPercentage': 0.0,
        'completedFeatures': 0,
        'totalFeatures':
            ProgressiveOnboardingService.featureRequirements.length,
        'nextFeatures': <String>[],
        'estimatedTime': '0 dakika',
      };
    }

    final totalFeatures =
        ProgressiveOnboardingService.featureRequirements.length;
    final completedFeatures = _availableFeatures.length;
    final nextSteps =
        progress['suggestedNextSteps'] as List<Map<String, dynamic>>? ?? [];

    // Calculate estimated time for all next steps
    var totalEstimatedMinutes = 0;
    for (final step in nextSteps.take(3)) {
      final timeStr = step['timeEstimate'] as String;
      totalEstimatedMinutes += _parseTimeEstimate(timeStr);
    }

    return {
      'completionPercentage': progress['completionPercentage'] ?? 0.0,
      'completedFeatures': completedFeatures,
      'totalFeatures': totalFeatures,
      'nextFeatures': nextSteps.take(3).map((s) => s['feature']).toList(),
      'estimatedTime': _formatTimeEstimate(totalEstimatedMinutes),
      'currentLevel': progress['completionLevel'] ?? 'minimal',
    };
  }

  /// Parse time estimate string to minutes
  int _parseTimeEstimate(String timeStr) {
    if (timeStr.contains('1 dakika')) return 1;
    if (timeStr.contains('2 dakika')) return 2;
    if (timeStr.contains('3-5 dakika')) return 4;
    if (timeStr.contains('5+ dakika')) return 6;
    return 1;
  }

  /// Format time estimate from minutes
  String _formatTimeEstimate(int minutes) {
    if (minutes <= 1) return '1 dakika';
    if (minutes <= 2) return '2 dakika';
    if (minutes <= 5) return '3-5 dakika';
    return '5+ dakika';
  }

  /// Refresh onboarding state manually
  Future<void> refreshOnboardingState() async {
    final user = _userService.currentUser;
    if (user != null) {
      _updateOnboardingState(user);
    }
  }

  /// Mark feature as manually completed (for testing)
  void markFeatureCompleted(String feature) {
    if (!_completedPrompts.contains(feature)) {
      _completedPrompts.add(feature);
    }
  }

  /// Reset session tracking (for testing)
  void resetSessionTracking() {
    _sessionPrompts.clear();
    _sessionSkips.clear();
  }

  /// Force show prompt (for testing)
  Future<bool> forceShowPrompt(String feature, {String? context}) async {
    return await triggerFeaturePrompt(
      feature,
      customContext: context,
      bypassFrequencyCheck: true,
    );
  }

  /// Get debug information
  Map<String, dynamic> getDebugInfo() {
    return {
      'sessionPrompts': Map<String, int>.from(_sessionPrompts),
      'sessionSkips': Map<String, int>.from(_sessionSkips),
      'suggestedFeatures': _suggestedFeatures.toList(),
      'completedPrompts': _completedPrompts.toList(),
      'availableFeatures': _availableFeatures.toList(),
      'isInitialized': _isInitialized.value,
    };
  }
}
