import 'package:get/get.dart';
import '../models/enhanced_user_model.dart';
import '../models/profile_completion_model.dart';
import '../services/profile_completion_service.dart';
import '../services/feature_gate_service.dart';
import '../services/user_service.dart';
import '../services/analytics_service.dart';
import '../widgets/onboarding/profile_upgrade_dialog.dart';
import '../views/onboarding/quick_setup_view.dart';

/// Service for managing progressive contextual onboarding
class ProgressiveOnboardingService extends GetxService {
  static ProgressiveOnboardingService get to => Get.find();

  final ProfileCompletionService _profileCompletionService =
      ProfileCompletionService.to;
  final FeatureGateService _featureGateService = FeatureGateService.to;
  final UserService _userService = Get.find<UserService>();
  final AnalyticsService _analytics = AnalyticsService.to;

  // Onboarding state tracking
  final _lastPromptTime = <String, DateTime>{}.obs;
  final _promptCount = <String, int>{}.obs;
  final _skipCount = <String, int>{}.obs;
  final _completedPrompts = <String>[].obs;

  // Feature requirements mapping
  static const Map<String, ProfileCompletionLevel> featureRequirements = {
    'community_join': ProfileCompletionLevel.basic, // Bio + Skills
    'project_sharing': ProfileCompletionLevel.standard, // GitHub + Experience
    'video_calling': ProfileCompletionLevel.complete, // Full profile
    'messaging': ProfileCompletionLevel.basic, // Basic info
    'event_creation': ProfileCompletionLevel.standard,
    'mentorship': ProfileCompletionLevel.complete,
    'networking': ProfileCompletionLevel.basic,
    'portfolio_showcase': ProfileCompletionLevel.standard,
  };

  // Context-based messaging
  static const Map<String, Map<String, String>> contextMessages = {
    'community_join': {
      'title': 'Topluluğa Katıl',
      'subtitle': 'Kendini tanıt ve yeteneklerini paylaş',
      'description':
          'Topluluğa katılmak için profil bilgilerini tamamlaman gerekiyor. Bu sayede diğer geliştiriciler seni daha iyi tanıyabilir.',
      'cta': 'Hızlıca Tamamla',
      'skipText': 'Sonra Yaparım',
    },
    'project_sharing': {
      'title': 'Projen Harika Görünüyor!',
      'subtitle': 'GitHub profilini bağlayıp deneyimini ekle',
      'description':
          'Projelerin daha güvenilir görünmesi için GitHub profilini ve iş deneyimini eklemelisin.',
      'cta': '2 Dakikada Tamamla',
      'skipText': 'Daha Sonra',
    },
    'video_calling': {
      'title': 'Video Görüşmeye Hazır mısın?',
      'subtitle': 'Tam profil gerekli',
      'description':
          'Video görüşmeler için eksiksiz bir profile ihtiyacın var. Bu güven ve profesyonellik sağlar.',
      'cta': 'Profili Tamamla',
      'skipText': 'İptal Et',
    },
    'messaging': {
      'title': 'Mesajlaşmaya Başla',
      'subtitle': 'Temel bilgilerini ekle',
      'description':
          'Diğer geliştiricilerle mesajlaşabilmek için temel profil bilgilerini tamamlaman yeterli.',
      'cta': '1 Dakikada Bitir',
      'skipText': 'Geç',
    },
  };

  /// Show contextual upgrade prompt for a feature
  static Future<bool?> showUpgradePrompt(
    String feature,
    EnhancedUserModel user, {
    String? customContext,
  }) async {
    final service = ProgressiveOnboardingService.to;

    // Check if prompt should be shown
    if (!service._shouldShowPrompt(feature, user)) {
      return null;
    }

    final requiredLevel =
        featureRequirements[feature] ?? ProfileCompletionLevel.complete;
    final missing = service._profileCompletionService
        .getMissingFieldsWithDetails(user, requiredLevel);
    final timeEstimate = service._calculateTimeNeeded(missing);
    final currentStatus =
        service._profileCompletionService.calculateCompletionLevel(user);

    // Track prompt display
    service._trackPromptDisplay(feature);

    final result = await Get.dialog<bool>(
      ProfileUpgradeDialog(
        feature: feature,
        missingFields: missing,
        timeEstimate: timeEstimate,
        currentLevel: currentStatus.level,
        requiredLevel: requiredLevel,
        contextMessages: contextMessages[feature],
        customContext: customContext,
      ),
      barrierDismissible: false,
    );

    // Track user action
    if (result == true) {
      service._trackPromptCompletion(feature);
    } else if (result == false) {
      service._trackPromptSkip(feature);
    }

    return result;
  }

  /// Show quick setup for minimal completion
  static Future<bool?> showQuickSetup(
    EnhancedUserModel user, {
    String? targetFeature,
    List<ProfileField>? focusFields,
  }) async {
    final service = ProgressiveOnboardingService.to;

    final result = await Get.to<bool>(
      () => QuickSetupView(
        user: user,
        targetFeature: targetFeature,
        focusFields: focusFields,
      ),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );

    if (result == true && targetFeature != null) {
      service._trackPromptCompletion(targetFeature);
    }

    return result;
  }

  /// Check if user should see onboarding prompt for feature
  bool _shouldShowPrompt(String feature, EnhancedUserModel user) {
    // Check if user can already access the feature
    if (_featureGateService.canAccess(feature, user)) {
      return false;
    }

    // Check if prompt was shown recently (24h cooldown)
    final lastShown = _lastPromptTime[feature];
    if (lastShown != null) {
      final timeSince = DateTime.now().difference(lastShown);
      if (timeSince.inHours < 24) {
        return false;
      }
    }

    // Check prompt frequency limits
    final promptsShown = _promptCount[feature] ?? 0;
    final promptsSkipped = _skipCount[feature] ?? 0;

    // Stop showing after 3 skips or 5 total prompts
    if (promptsSkipped >= 3 || promptsShown >= 5) {
      return false;
    }

    // Check if user is close to unlocking (encourage completion)
    final isCloseToUnlocking =
        _featureGateService.isCloseToUnlocking(feature, user);
    if (!isCloseToUnlocking && promptsShown >= 2) {
      return false;
    }

    return true;
  }

  /// Calculate time needed to complete missing fields
  String _calculateTimeNeeded(List<ProfileField> missingFields) {
    if (missingFields.isEmpty) return '0 dakika';

    // Estimate based on field complexity
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

  /// Track prompt display
  void _trackPromptDisplay(String feature) {
    _lastPromptTime[feature] = DateTime.now();
    _promptCount[feature] = (_promptCount[feature] ?? 0) + 1;

    _logOnboardingEvent('prompt_displayed', {
      'feature': feature,
      'prompt_count': _promptCount[feature],
    });
  }

  /// Track prompt completion
  void _trackPromptCompletion(String feature) {
    _completedPrompts.add(feature);

    _logOnboardingEvent('prompt_completed', {
      'feature': feature,
      'completion_time': DateTime.now().toIso8601String(),
    });
  }

  /// Track prompt skip
  void _trackPromptSkip(String feature) {
    _skipCount[feature] = (_skipCount[feature] ?? 0) + 1;

    _logOnboardingEvent('prompt_skipped', {
      'feature': feature,
      'skip_count': _skipCount[feature],
    });
  }

  /// Log onboarding events for analytics tracking
  void _logOnboardingEvent(String eventName, Map<String, dynamic> parameters) {
    final userId = _userService.currentUser?.uid ?? 'anonymous';

    _analytics.logEvent('onboarding_$eventName', {
      'user_id': userId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      ...parameters,
    });
  }

  /// Get onboarding progress for user
  Map<String, dynamic> getOnboardingProgress(EnhancedUserModel user) {
    final currentStatus =
        _profileCompletionService.calculateCompletionLevel(user);
    final accessibleFeatures = _featureGateService.getAccessibleFeatures(user);
    final lockedFeatures = _featureGateService.getLockedFeatures(user);

    return {
      'completionLevel': currentStatus.level.name,
      'completionPercentage': currentStatus.percentage,
      'accessibleFeatures': accessibleFeatures,
      'lockedFeatures': lockedFeatures,
      'completedPrompts': _completedPrompts.toList(),
      'promptCounts': Map<String, int>.from(_promptCount),
      'skipCounts': Map<String, int>.from(_skipCount),
      'suggestedNextSteps': _getSuggestedNextSteps(user),
    };
  }

  /// Get suggested next steps for user
  List<Map<String, dynamic>> _getSuggestedNextSteps(EnhancedUserModel user) {
    final nextSteps = <Map<String, dynamic>>[];

    for (final entry in featureRequirements.entries) {
      final feature = entry.key;
      final requiredLevel = entry.value;

      if (!_featureGateService.canAccess(feature, user)) {
        final missingFields = _profileCompletionService
            .getMissingFieldsWithDetails(user, requiredLevel);
        final timeEstimate = _calculateTimeNeeded(missingFields);

        nextSteps.add({
          'feature': feature,
          'featureName': _featureGateService.getFeatureDisplayName(feature),
          'requiredLevel': requiredLevel.name,
          'missingFields': missingFields.length,
          'timeEstimate': timeEstimate,
          'priority': _calculateStepPriority(feature, user),
        });
      }
    }

    // Sort by priority
    nextSteps
        .sort((a, b) => (b['priority'] as int).compareTo(a['priority'] as int));

    return nextSteps;
  }

  /// Calculate priority for a completion step
  int _calculateStepPriority(String feature, EnhancedUserModel user) {
    int priority = 0;

    // Base priority by feature importance
    switch (feature) {
      case 'messaging':
        priority += 100; // High priority
        break;
      case 'networking':
        priority += 90;
        break;
      case 'project_sharing':
        priority += 80;
        break;
      case 'community_join':
        priority += 70;
        break;
      default:
        priority += 50;
    }

    // Boost if close to unlocking
    if (_featureGateService.isCloseToUnlocking(feature, user)) {
      priority += 30;
    }

    // Reduce if user has skipped multiple times
    final skipCount = _skipCount[feature] ?? 0;
    priority -= skipCount * 10;

    return priority;
  }

  /// Reset onboarding state for a feature (for testing)
  void resetFeatureState(String feature) {
    _lastPromptTime.remove(feature);
    _promptCount.remove(feature);
    _skipCount.remove(feature);
    _completedPrompts.removeWhere((f) => f == feature);
  }

  /// Reset all onboarding state (for testing)
  void resetAllState() {
    _lastPromptTime.clear();
    _promptCount.clear();
    _skipCount.clear();
    _completedPrompts.clear();
  }
}
