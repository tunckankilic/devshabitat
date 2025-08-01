import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/enhanced_user_model.dart';
import '../models/profile_completion_model.dart';
import 'user_service.dart';
import 'profile_completion_service.dart';

/// Service for managing feature access control based on profile completion
class FeatureGateService extends GetxService {
  static FeatureGateService get to => Get.find();

  final ProfileCompletionService _profileCompletionService =
      ProfileCompletionService.to;
  final UserService _userService = Get.find<UserService>();

  /// Feature requirements mapping with Turkish names
  static const Map<String, ProfileCompletionLevel> featureRequirements = {
    'browsing': ProfileCompletionLevel.minimal,
    'liking': ProfileCompletionLevel.minimal,
    'commenting': ProfileCompletionLevel.basic,
    'posting': ProfileCompletionLevel.standard,
    'project_sharing': ProfileCompletionLevel.standard,
    'community_creation': ProfileCompletionLevel.complete,
    'video_calling': ProfileCompletionLevel.standard,
    'messaging': ProfileCompletionLevel.basic,
    'event_creation': ProfileCompletionLevel.standard,
    'networking': ProfileCompletionLevel.basic,
    'portfolio_showcase': ProfileCompletionLevel.standard,
    'mentorship': ProfileCompletionLevel.complete,
  };

  /// Feature display names in Turkish
  static const Map<String, String> featureDisplayNames = {
    'browsing': 'Gezinme',
    'liking': 'Beğenme',
    'commenting': 'Yorum Yapma',
    'posting': 'Gönderi Paylaşma',
    'project_sharing': 'Proje Paylaşımı',
    'community_creation': 'Topluluk Oluşturma',
    'video_calling': 'Video Görüşme',
    'messaging': 'Mesajlaşma',
    'event_creation': 'Etkinlik Oluşturma',
    'networking': 'Ağ Oluşturma',
    'portfolio_showcase': 'Portföy Sergileme',
    'mentorship': 'Mentorluk',
  };

  /// Check if current user can access a feature
  bool canAccess(String feature, [EnhancedUserModel? user]) {
    final currentUser = user ?? _userService.currentUser;
    if (currentUser == null) return false;

    final userLevel =
        _profileCompletionService.calculateCompletionLevel(currentUser);
    final requiredLevel =
        featureRequirements[feature] ?? ProfileCompletionLevel.complete;

    return userLevel.level.percentage >= requiredLevel.percentage;
  }

  /// Get required completion level for a feature
  ProfileCompletionLevel getRequiredLevel(String feature) {
    return featureRequirements[feature] ?? ProfileCompletionLevel.complete;
  }

  /// Get missing fields to access a feature
  List<ProfileField> getMissingFieldsForFeature(String feature,
      [EnhancedUserModel? user]) {
    final currentUser = user ?? _userService.currentUser;
    if (currentUser == null) return [];

    final requiredLevel = getRequiredLevel(feature);
    return _profileCompletionService.getMissingFieldsWithDetails(
        currentUser, requiredLevel);
  }

  /// Get feature display name
  String getFeatureDisplayName(String feature) {
    return featureDisplayNames[feature] ?? feature;
  }

  /// Get completion level display name
  String getCompletionLevelDisplayName(ProfileCompletionLevel level) {
    switch (level) {
      case ProfileCompletionLevel.minimal:
        return 'Temel';
      case ProfileCompletionLevel.basic:
        return 'Basit';
      case ProfileCompletionLevel.standard:
        return 'Standart';
      case ProfileCompletionLevel.complete:
        return 'Tam';
    }
  }

  /// Create a gated widget that wraps features with access control
  Widget gateFeature({
    required String feature,
    required Widget child,
    Widget? fallback,
    VoidCallback? onUpgrade,
    bool showUpgradePrompt = true,
  }) {
    final currentUser = _userService.currentUser;

    if (currentUser == null) {
      return fallback ?? _buildLoginPrompt();
    }

    if (canAccess(feature, currentUser)) {
      return child;
    }

    if (showUpgradePrompt) {
      return fallback ??
          _buildUpgradePrompt(
            feature: feature,
            user: currentUser,
            onUpgrade: onUpgrade,
          );
    }

    return fallback ?? const SizedBox.shrink();
  }

  /// Build login prompt widget
  Widget _buildLoginPrompt() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Get.theme.dividerColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.login,
            size: 48,
            color: Get.theme.primaryColor,
          ),
          const SizedBox(height: 12),
          Text(
            'Bu özellik için giriş yapmanız gerekiyor',
            style: Get.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Devam etmek için lütfen giriş yapın',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Get.theme.hintColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Get.toNamed('/auth'),
            child: const Text('Giriş Yap'),
          ),
        ],
      ),
    );
  }

  /// Build upgrade prompt widget
  Widget _buildUpgradePrompt({
    required String feature,
    required EnhancedUserModel user,
    VoidCallback? onUpgrade,
  }) {
    final requiredLevel = getRequiredLevel(feature);
    final missingFields = getMissingFieldsForFeature(feature, user);
    final currentStatus =
        _profileCompletionService.calculateCompletionLevel(user);
    final featureName = getFeatureDisplayName(feature);
    final levelName = getCompletionLevelDisplayName(requiredLevel);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Get.theme.primaryColor.withOpacity(0.1),
            Get.theme.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Get.theme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_outline,
            size: 48,
            color: Get.theme.primaryColor,
          ),
          const SizedBox(height: 12),
          Text(
            '$featureName Özelliği',
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Bu özellik $levelName profil tamamlama seviyesi gerektirir',
            style: Get.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Mevcut seviyeniz: ${getCompletionLevelDisplayName(currentStatus.level)} (${currentStatus.percentage.toInt()}%)',
            style: Get.textTheme.bodySmall?.copyWith(
              color: Get.theme.hintColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (missingFields.isNotEmpty) ...[
            Text(
              'Eksik bilgiler:',
              style: Get.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: missingFields.map((field) {
                return Chip(
                  label: Text(
                    field.displayName,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
                  side: BorderSide(
                      color: Get.theme.primaryColor.withOpacity(0.3)),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Sonra'),
              ),
              ElevatedButton.icon(
                onPressed: onUpgrade ?? () => Get.toNamed('/profile/edit'),
                icon: const Icon(Icons.upgrade, size: 18),
                label: const Text('2 dakikada tamamla'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Get completion time estimate for a feature
  String getCompletionTimeEstimate(String feature, [EnhancedUserModel? user]) {
    final missingFields = getMissingFieldsForFeature(feature, user);

    if (missingFields.isEmpty) {
      return 'Erişilebilir';
    }

    final fieldCount = missingFields.length;
    if (fieldCount <= 2) {
      return '1 dakika';
    } else if (fieldCount <= 4) {
      return '2 dakika';
    } else {
      return '3-5 dakika';
    }
  }

  /// Check if user is close to unlocking a feature (within 1 level)
  bool isCloseToUnlocking(String feature, [EnhancedUserModel? user]) {
    final currentUser = user ?? _userService.currentUser;
    if (currentUser == null) return false;

    final currentStatus =
        _profileCompletionService.calculateCompletionLevel(currentUser);
    final requiredLevel = getRequiredLevel(feature);

    // If already accessible, return false
    if (currentStatus.level.percentage >= requiredLevel.percentage) {
      return false;
    }

    // Check if within one level
    final currentIndex =
        ProfileCompletionLevel.values.indexOf(currentStatus.level);
    final requiredIndex = ProfileCompletionLevel.values.indexOf(requiredLevel);

    return (requiredIndex - currentIndex) <= 1;
  }

  /// Get all locked features for current user
  List<String> getLockedFeatures([EnhancedUserModel? user]) {
    return featureRequirements.keys
        .where((feature) => !canAccess(feature, user))
        .toList();
  }

  /// Get all accessible features for current user
  List<String> getAccessibleFeatures([EnhancedUserModel? user]) {
    return featureRequirements.keys
        .where((feature) => canAccess(feature, user))
        .toList();
  }
}
