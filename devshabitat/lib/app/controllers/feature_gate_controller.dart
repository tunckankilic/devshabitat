import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/enhanced_user_model.dart';
import '../models/profile_completion_model.dart';
import '../services/feature_gate_service.dart';
import '../services/user_service.dart';
import '../services/profile_completion_service.dart';

/// Controller for managing feature gate state and user interactions
class FeatureGateController extends GetxController {
  static FeatureGateController get to => Get.find();

  final FeatureGateService _featureGateService = FeatureGateService.to;
  final UserService _userService = Get.find<UserService>();
  final ProfileCompletionService _profileCompletionService =
      ProfileCompletionService.to;

  // Reactive variables
  final _currentUserStatus = Rxn<ProfileCompletionStatus>();
  final _isLoading = false.obs;
  final _lockedFeatures = <String>[].obs;
  final _accessibleFeatures = <String>[].obs;

  // Getters
  ProfileCompletionStatus? get currentUserStatus => _currentUserStatus.value;
  bool get isLoading => _isLoading.value;
  List<String> get lockedFeatures => _lockedFeatures;
  List<String> get accessibleFeatures => _accessibleFeatures;

  @override
  void onInit() {
    super.onInit();
    _initializeUserStatusListener();
  }

  /// Initialize user status listener for reactive updates
  void _initializeUserStatusListener() {
    // Listen to user changes
    // Note: We'll need to add a public getter for this or use another approach
    // For now, we'll update manually when needed

    // Initial status update
    _updateUserStatus(_userService.currentUser);
  }

  /// Update user status when user data changes
  void _updateUserStatus(EnhancedUserModel? user) {
    if (user == null) {
      _currentUserStatus.value = null;
      _lockedFeatures.clear();
      _accessibleFeatures.clear();
      return;
    }

    _isLoading.value = true;

    try {
      // Calculate completion status
      final status = _profileCompletionService.calculateCompletionLevel(user);
      _currentUserStatus.value = status;

      // Update feature lists
      _lockedFeatures.value = _featureGateService.getLockedFeatures(user);
      _accessibleFeatures.value =
          _featureGateService.getAccessibleFeatures(user);
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Profil durumu güncellenirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Check if user can access a specific feature
  bool canAccessFeature(String feature) {
    final user = _userService.currentUser;
    if (user == null) return false;
    return _featureGateService.canAccess(feature, user);
  }

  /// Get required level for a feature
  ProfileCompletionLevel getRequiredLevel(String feature) {
    return _featureGateService.getRequiredLevel(feature);
  }

  /// Get missing fields for a feature
  List<ProfileField> getMissingFieldsForFeature(String feature) {
    final user = _userService.currentUser;
    if (user == null) return [];
    return _featureGateService.getMissingFieldsForFeature(feature, user);
  }

  /// Get feature display name
  String getFeatureDisplayName(String feature) {
    return _featureGateService.getFeatureDisplayName(feature);
  }

  /// Get completion level display name
  String getCompletionLevelDisplayName(ProfileCompletionLevel level) {
    return _featureGateService.getCompletionLevelDisplayName(level);
  }

  /// Get completion time estimate for a feature
  String getCompletionTimeEstimate(String feature) {
    final user = _userService.currentUser;
    return _featureGateService.getCompletionTimeEstimate(feature, user);
  }

  /// Check if user is close to unlocking a feature
  bool isCloseToUnlocking(String feature) {
    final user = _userService.currentUser;
    return _featureGateService.isCloseToUnlocking(feature, user);
  }

  /// Navigate to profile completion screen
  void navigateToProfileCompletion([String? targetFeature]) {
    if (targetFeature != null) {
      Get.toNamed('/profile/edit', arguments: {
        'targetFeature': targetFeature,
        'missingFields': getMissingFieldsForFeature(targetFeature),
      });
    } else {
      Get.toNamed('/profile/edit');
    }
  }

  /// Show feature info dialog
  void showFeatureInfo(String feature) {
    final requiredLevel = getRequiredLevel(feature);
    final missingFields = getMissingFieldsForFeature(feature);
    final featureName = getFeatureDisplayName(feature);
    final levelName = getCompletionLevelDisplayName(requiredLevel);
    final timeEstimate = getCompletionTimeEstimate(feature);

    Get.dialog(
      AlertDialog(
        title: Text('$featureName Özelliği'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gerekli seviye: $levelName'),
            const SizedBox(height: 8),
            Text('Tamamlama süresi: $timeEstimate'),
            if (missingFields.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Eksik bilgiler:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              ...missingFields.map((field) => Text('• ${field.displayName}')),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tamam'),
          ),
          if (missingFields.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                Get.back();
                navigateToProfileCompletion(feature);
              },
              child: const Text('Tamamla'),
            ),
        ],
      ),
    );
  }

  /// Get upgrade prompt data for a feature
  Map<String, dynamic> getUpgradePromptData(String feature) {
    final user = _userService.currentUser;
    if (user == null) {
      return {
        'isLoggedIn': false,
        'canAccess': false,
      };
    }

    final canAccess = _featureGateService.canAccess(feature, user);
    final requiredLevel = getRequiredLevel(feature);
    final missingFields = getMissingFieldsForFeature(feature);
    final currentStatus = _currentUserStatus.value;
    final featureName = getFeatureDisplayName(feature);
    final levelName = getCompletionLevelDisplayName(requiredLevel);
    final timeEstimate = getCompletionTimeEstimate(feature);
    final isCloseToUnlock = isCloseToUnlocking(feature);

    return {
      'isLoggedIn': true,
      'canAccess': canAccess,
      'featureName': featureName,
      'requiredLevel': requiredLevel,
      'requiredLevelName': levelName,
      'missingFields': missingFields,
      'currentStatus': currentStatus,
      'timeEstimate': timeEstimate,
      'isCloseToUnlock': isCloseToUnlock,
    };
  }

  /// Refresh user status
  Future<void> refreshUserStatus() async {
    final user = _userService.currentUser;
    if (user != null) {
      _updateUserStatus(_userService.currentUser);
    }
  }

  /// Get all feature access info
  Map<String, bool> getAllFeatureAccess() {
    final user = _userService.currentUser;
    if (user == null) return {};

    final result = <String, bool>{};
    for (final feature in FeatureGateService.featureRequirements.keys) {
      result[feature] = _featureGateService.canAccess(feature, user);
    }
    return result;
  }

  /// Get features unlock order (what gets unlocked at each level)
  Map<ProfileCompletionLevel, List<String>> getFeatureUnlockOrder() {
    final unlockOrder = <ProfileCompletionLevel, List<String>>{};

    for (final level in ProfileCompletionLevel.values) {
      unlockOrder[level] = FeatureGateService.featureRequirements.entries
          .where((entry) => entry.value == level)
          .map((entry) => entry.key)
          .toList();
    }

    return unlockOrder;
  }

  /// Get progress to next level
  Map<String, dynamic> getProgressToNextLevel() {
    final user = _userService.currentUser;
    if (user == null) {
      return {
        'hasNextLevel': false,
        'progress': 0.0,
        'nextFeatures': <String>[],
      };
    }

    final currentStatus = _currentUserStatus.value;
    if (currentStatus == null) {
      return {
        'hasNextLevel': false,
        'progress': 0.0,
        'nextFeatures': <String>[],
      };
    }

    final nextLevel = currentStatus.level.nextLevel;
    if (nextLevel == null) {
      return {
        'hasNextLevel': false,
        'progress': 100.0,
        'nextFeatures': <String>[],
      };
    }

    final nextLevelFeatures = FeatureGateService.featureRequirements.entries
        .where((entry) => entry.value == nextLevel)
        .map((entry) => entry.key)
        .toList();

    final progressPercentage =
        (currentStatus.percentage / nextLevel.percentage) * 100;

    return {
      'hasNextLevel': true,
      'progress': progressPercentage.clamp(0.0, 100.0),
      'nextLevel': nextLevel,
      'nextLevelName': getCompletionLevelDisplayName(nextLevel),
      'nextFeatures': nextLevelFeatures,
      'missingFields': getMissingFieldsForFeature(nextLevelFeatures.first),
    };
  }
}
