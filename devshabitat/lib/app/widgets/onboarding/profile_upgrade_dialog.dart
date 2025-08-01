import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/profile_completion_model.dart';
import '../../core/theme/dev_habitat_colors.dart';

/// Smart contextual dialog for profile upgrade prompts
class ProfileUpgradeDialog extends StatelessWidget {
  final String feature;
  final List<ProfileField> missingFields;
  final String timeEstimate;
  final ProfileCompletionLevel currentLevel;
  final ProfileCompletionLevel requiredLevel;
  final Map<String, String>? contextMessages;
  final String? customContext;

  const ProfileUpgradeDialog({
    super.key,
    required this.feature,
    required this.missingFields,
    required this.timeEstimate,
    required this.currentLevel,
    required this.requiredLevel,
    this.contextMessages,
    this.customContext,
  });

  @override
  Widget build(BuildContext context) {
    final messages = contextMessages ?? _getDefaultMessages();
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Stack(
          children: [
            // Main content
            Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  _buildHeader(messages, theme),
                  const SizedBox(height: 20),

                  // Progress indicator
                  _buildProgressIndicator(theme),
                  const SizedBox(height: 20),

                  // Missing fields
                  if (missingFields.isNotEmpty) ...[
                    _buildMissingFields(theme),
                    const SizedBox(height: 20),
                  ],

                  // Time estimate
                  _buildTimeEstimate(theme),
                  const SizedBox(height: 24),

                  // Action buttons
                  _buildActionButtons(messages, theme),
                ],
              ),
            ),

            // Feature icon at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildFeatureIcon(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(ThemeData theme) {
    final icon = _getFeatureIcon();

    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              DevHabitatColors.primary,
              DevHabitatColors.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: DevHabitatColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, String> messages, ThemeData theme) {
    return Column(
      children: [
        Text(
          messages['title'] ?? 'Profili Tamamla',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          messages['subtitle'] ?? 'Bu özelliği kullanmak için',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        if (customContext != null) ...[
          const SizedBox(height: 8),
          Text(
            customContext!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: DevHabitatColors.primary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 12),
        Text(
          messages['description'] ?? 'Lütfen profil bilgilerinizi tamamlayın',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    final currentPercentage = currentLevel.percentage;
    final targetPercentage = requiredLevel.percentage;
    final progressToTarget = currentPercentage / targetPercentage;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mevcut Seviye',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                _getLevelDisplayName(currentLevel),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progressToTarget.clamp(0.0, 1.0),
            backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              progressToTarget >= 1.0
                  ? DevHabitatColors.success
                  : DevHabitatColors.primary,
            ),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${currentPercentage.toInt()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                'Hedef: ${targetPercentage.toInt()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: DevHabitatColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMissingFields(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DevHabitatColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DevHabitatColors.warning.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: DevHabitatColors.warning,
              ),
              const SizedBox(width: 8),
              Text(
                'Tamamlanması Gereken Bilgiler',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: DevHabitatColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: missingFields.map((field) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: DevHabitatColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getFieldIcon(field.name),
                      size: 16,
                      color: DevHabitatColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      field.displayName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeEstimate(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DevHabitatColors.success.withOpacity(0.1),
            DevHabitatColors.success.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DevHabitatColors.success.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DevHabitatColors.success.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.schedule,
              color: DevHabitatColors.success,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tahmini Süre',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  timeEstimate,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: DevHabitatColors.success,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.flash_on,
            color: DevHabitatColors.warning,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, String> messages, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Get.back(result: false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              foregroundColor: theme.colorScheme.onSurfaceVariant,
            ),
            child: Text(
              messages['skipText'] ?? 'Sonra',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: DevHabitatColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.upgrade, size: 18),
                const SizedBox(width: 8),
                Text(
                  messages['cta'] ?? 'Tamamla',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Map<String, String> _getDefaultMessages() {
    return {
      'title': 'Özellik Kilidini Aç',
      'subtitle': 'Bu özelliği kullanmak için',
      'description':
          'Profil bilgilerinizi tamamlayarak bu özelliğe erişebilirsiniz.',
      'cta': 'Profili Tamamla',
      'skipText': 'Sonra',
    };
  }

  String _getLevelDisplayName(ProfileCompletionLevel level) {
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

  IconData _getFeatureIcon() {
    switch (feature) {
      case 'community_join':
        return Icons.groups;
      case 'project_sharing':
        return Icons.share;
      case 'video_calling':
        return Icons.video_call;
      case 'messaging':
        return Icons.message;
      case 'event_creation':
        return Icons.event;
      case 'mentorship':
        return Icons.school;
      case 'networking':
        return Icons.connect_without_contact;
      case 'portfolio_showcase':
        return Icons.work;
      default:
        return Icons.lock_open;
    }
  }

  IconData _getFieldIcon(String fieldName) {
    switch (fieldName) {
      case 'bio':
        return Icons.info;
      case 'skills':
        return Icons.psychology;
      case 'githubUsername':
        return Icons.code;
      case 'workExperience':
        return Icons.work_history;
      case 'education':
        return Icons.school;
      case 'location':
        return Icons.location_on;
      case 'projects':
        return Icons.folder;
      case 'socialLinks':
        return Icons.link;
      default:
        return Icons.edit;
    }
  }
}
