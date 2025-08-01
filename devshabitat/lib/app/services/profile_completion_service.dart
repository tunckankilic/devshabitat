import 'package:get/get.dart';
import '../models/enhanced_user_model.dart';
import '../models/profile_completion_model.dart';
import '../models/user_profile_model.dart';

/// Service for managing profile completion levels and feature access
class ProfileCompletionService extends GetxService {
  static ProfileCompletionService get to => Get.find();

  /// Feature gates mapping features to minimum required completion levels
  static const Map<String, ProfileCompletionLevel> featureGates = {
    'browsing': ProfileCompletionLevel.minimal,
    'commenting': ProfileCompletionLevel.basic,
    'messaging': ProfileCompletionLevel.basic,
    'project_sharing': ProfileCompletionLevel.standard,
    'community_creation': ProfileCompletionLevel.complete,
    'event_creation': ProfileCompletionLevel.standard,
    'advanced_search': ProfileCompletionLevel.basic,
    'networking': ProfileCompletionLevel.basic,
    'portfolio_showcase': ProfileCompletionLevel.standard,
    'mentorship': ProfileCompletionLevel.complete,
  };

  /// Calculate profile completion level and percentage for Enhanced User Model
  ProfileCompletionStatus calculateCompletionLevel(EnhancedUserModel user) {
    var completedWeight = 0;
    final completedFields = <String>[];
    final missingFields = <String>[];

    // Check each field against the user data
    for (final field in ProfileCompletionRequirements.allFields) {
      final isCompleted = _isFieldCompleted(user, field.name);

      if (isCompleted) {
        completedWeight += field.weight;
        completedFields.add(field.name);
      } else {
        missingFields.add(field.name);
      }
    }

    final percentage = completedWeight.toDouble();
    final level = ProfileCompletionLevel.fromPercentage(percentage);

    return ProfileCompletionStatus(
      level: level,
      percentage: percentage,
      completedFields: completedFields,
      missingFields: missingFields,
    );
  }

  /// Calculate profile completion level for User Profile Model
  ProfileCompletionStatus calculateCompletionLevelForProfile(
      UserProfile profile) {
    var completedWeight = 0;
    final completedFields = <String>[];
    final missingFields = <String>[];

    for (final field in ProfileCompletionRequirements.allFields) {
      final isCompleted = _isProfileFieldCompleted(profile, field.name);

      if (isCompleted) {
        completedWeight += field.weight;
        completedFields.add(field.name);
      } else {
        missingFields.add(field.name);
      }
    }

    final percentage = completedWeight.toDouble();
    final level = ProfileCompletionLevel.fromPercentage(percentage);

    return ProfileCompletionStatus(
      level: level,
      percentage: percentage,
      completedFields: completedFields,
      missingFields: missingFields,
    );
  }

  /// Get required fields for a specific completion level
  List<String> getRequiredFields(ProfileCompletionLevel level) {
    return ProfileCompletionRequirements.getRequiredFields(level)
        .map((field) => field.name)
        .toList();
  }

  /// Get missing fields to reach target level from current user status
  List<String> getMissingFields(
      EnhancedUserModel user, ProfileCompletionLevel targetLevel) {
    final currentStatus = calculateCompletionLevel(user);
    return ProfileCompletionRequirements.getMissingFieldsForLevel(
      currentStatus.level,
      targetLevel,
    ).map((field) => field.name).toList();
  }

  /// Get missing fields with display names for UI
  List<ProfileField> getMissingFieldsWithDetails(
    EnhancedUserModel user,
    ProfileCompletionLevel targetLevel,
  ) {
    final currentStatus = calculateCompletionLevel(user);
    return ProfileCompletionRequirements.getMissingFieldsForLevel(
      currentStatus.level,
      targetLevel,
    );
  }

  /// Check if user can access a specific feature
  bool canAccessFeature(String featureName, ProfileCompletionLevel userLevel) {
    final requiredLevel = featureGates[featureName];
    if (requiredLevel == null) {
      // If feature is not in the gates map, allow access
      return true;
    }

    return userLevel.percentage >= requiredLevel.percentage;
  }

  /// Check if user can access feature with user object
  bool canUserAccessFeature(String featureName, EnhancedUserModel user) {
    final status = calculateCompletionLevel(user);
    return canAccessFeature(featureName, status.level);
  }

  /// Get next completion steps for user
  List<ProfileField> getNextCompletionSteps(EnhancedUserModel user) {
    final currentStatus = calculateCompletionLevel(user);
    final nextLevel = currentStatus.level.nextLevel;

    if (nextLevel == null) {
      return []; // Already at maximum level
    }

    return getMissingFieldsWithDetails(user, nextLevel);
  }

  /// Get completion progress summary
  Map<String, dynamic> getCompletionSummary(EnhancedUserModel user) {
    final status = calculateCompletionLevel(user);
    final nextSteps = getNextCompletionSteps(user);

    return {
      'currentLevel': status.level.name,
      'percentage': status.percentage,
      'nextLevel': status.level.nextLevel?.name,
      'completedFields': status.completedFields.length,
      'totalFields': ProfileCompletionRequirements.allFields.length,
      'nextSteps': nextSteps
          .map((field) => {
                'name': field.name,
                'displayName': field.displayName,
                'weight': field.weight,
              })
          .toList(),
      'availableFeatures': _getAvailableFeatures(status.level),
      'lockedFeatures': _getLockedFeatures(status.level),
    };
  }

  /// Check if field is completed in Enhanced User Model
  bool _isFieldCompleted(EnhancedUserModel user, String fieldName) {
    switch (fieldName) {
      case 'uid':
        return user.uid.isNotEmpty;
      case 'email':
        return user.email.isNotEmpty;
      case 'displayName':
        return user.displayName?.isNotEmpty == true;
      case 'bio':
        return user.bio?.isNotEmpty == true;
      case 'skills':
        return user.skills?.isNotEmpty == true &&
            (user.skills?.length ?? 0) >= 3;
      case 'githubUsername':
        return user.githubUsername?.isNotEmpty == true;
      case 'workExperience':
        return user.workExperience?.isNotEmpty == true;
      case 'location':
        return user.location != null;
      case 'projects':
        return false; // EnhancedUserModel doesn't have projects, would need UserProfile
      case 'education':
        return user.education?.isNotEmpty == true;
      case 'socialLinks':
        return false; // EnhancedUserModel doesn't have social links directly
      default:
        return false;
    }
  }

  /// Check if field is completed in User Profile Model
  bool _isProfileFieldCompleted(UserProfile profile, String fieldName) {
    switch (fieldName) {
      case 'uid':
        return profile.id.isNotEmpty;
      case 'email':
        return profile.email.isNotEmpty;
      case 'displayName':
        return profile.fullName.isNotEmpty;
      case 'bio':
        return profile.bio?.isNotEmpty == true;
      case 'skills':
        return profile.skills.isNotEmpty && profile.skills.length >= 3;
      case 'githubUsername':
        return profile.githubUsername?.isNotEmpty == true;
      case 'workExperience':
        return profile.workExperience.isNotEmpty;
      case 'location':
        return profile.location != null ||
            profile.locationName?.isNotEmpty == true;
      case 'projects':
        return profile.projects.isNotEmpty;
      case 'education':
        return profile.education.isNotEmpty;
      case 'socialLinks':
        return profile.socialLinks.isNotEmpty;
      default:
        return false;
    }
  }

  /// Get available features for a completion level
  List<String> _getAvailableFeatures(ProfileCompletionLevel level) {
    return featureGates.entries
        .where((entry) => level.percentage >= entry.value.percentage)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get locked features for a completion level
  List<String> _getLockedFeatures(ProfileCompletionLevel level) {
    return featureGates.entries
        .where((entry) => level.percentage < entry.value.percentage)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get feature access info with required levels
  Map<String, Map<String, dynamic>> getFeatureAccessInfo() {
    return featureGates.map((feature, requiredLevel) => MapEntry(
          feature,
          {
            'requiredLevel': requiredLevel.name,
            'requiredPercentage': requiredLevel.percentage,
            'displayName': _getFeatureDisplayName(feature),
          },
        ));
  }

  /// Get localized display name for feature
  String _getFeatureDisplayName(String featureName) {
    const displayNames = {
      'browsing': 'Gezinme',
      'commenting': 'Yorum Yapma',
      'messaging': 'Mesajlaşma',
      'project_sharing': 'Proje Paylaşımı',
      'community_creation': 'Topluluk Oluşturma',
      'event_creation': 'Etkinlik Oluşturma',
      'advanced_search': 'Gelişmiş Arama',
      'networking': 'Ağ Oluşturma',
      'portfolio_showcase': 'Portföy Sergileme',
      'mentorship': 'Mentorluk',
    };

    return displayNames[featureName] ?? featureName;
  }
}
