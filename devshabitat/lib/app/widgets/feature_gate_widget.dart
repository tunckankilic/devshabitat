import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/feature_gate_controller.dart';
import '../controllers/progressive_onboarding_controller.dart';
import '../models/profile_completion_model.dart';

/// Widget that wraps features with access control and upgrade prompts
class FeatureGateWidget extends StatelessWidget {
  final String feature;
  final Widget child;
  final Widget? fallback;
  final VoidCallback? onUpgrade;
  final bool showUpgradePrompt;
  final bool showLockIcon;
  final String? customMessage;
  final FeatureGateDisplayMode displayMode;
  final bool enableContextualOnboarding;

  const FeatureGateWidget({
    super.key,
    required this.feature,
    required this.child,
    this.fallback,
    this.onUpgrade,
    this.showUpgradePrompt = true,
    this.showLockIcon = true,
    this.customMessage,
    this.displayMode = FeatureGateDisplayMode.card,
    this.enableContextualOnboarding = false,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FeatureGateController>(
      init: FeatureGateController(),
      builder: (controller) {
        if (controller.canAccessFeature(feature)) {
          return child;
        }

        if (!showUpgradePrompt) {
          return fallback ?? const SizedBox.shrink();
        }

        switch (displayMode) {
          case FeatureGateDisplayMode.card:
            return _buildUpgradeCard(controller);
          case FeatureGateDisplayMode.banner:
            return _buildUpgradeBanner(controller);
          case FeatureGateDisplayMode.dialog:
            return _buildDialogTrigger(controller);
          case FeatureGateDisplayMode.overlay:
            return _buildOverlay(controller);
          case FeatureGateDisplayMode.inline:
            return _buildInlinePrompt(controller);
        }
      },
    );
  }

  /// Build upgrade card widget
  Widget _buildUpgradeCard(FeatureGateController controller) {
    final requiredLevel = controller.getRequiredLevel(feature);
    final missingFields = controller.getMissingFieldsForFeature(feature);
    final featureName = controller.getFeatureDisplayName(feature);
    final levelName = controller.getCompletionLevelDisplayName(requiredLevel);
    final timeEstimate = controller.getCompletionTimeEstimate(feature);
    final isCloseToUnlock = controller.isCloseToUnlocking(feature);

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
        border: Border.all(
          color: isCloseToUnlock
              ? Get.theme.colorScheme.secondary.withOpacity(0.5)
              : Get.theme.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLockIcon) ...[
            Icon(
              isCloseToUnlock ? Icons.lock_open_outlined : Icons.lock_outline,
              size: 48,
              color: isCloseToUnlock
                  ? Get.theme.colorScheme.secondary
                  : Get.theme.primaryColor,
            ),
            const SizedBox(height: 12),
          ],
          Text(
            customMessage ?? '$featureName Özelliği',
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
          if (isCloseToUnlock) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Kilidi açmaya çok yakınsınız! 🎉',
                style: Get.textTheme.bodySmall?.copyWith(
                  color: Get.theme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
              spacing: 6,
              runSpacing: 4,
              children: missingFields.take(4).map((field) {
                return Chip(
                  label: Text(
                    field.displayName,
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
                  side: BorderSide(
                    color: Get.theme.primaryColor.withOpacity(0.3),
                  ),
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
            if (missingFields.length > 4) ...[
              const SizedBox(height: 4),
              Text(
                '+${missingFields.length - 4} tane daha',
                style: Get.textTheme.bodySmall?.copyWith(
                  color: Get.theme.hintColor,
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => controller.showFeatureInfo(feature),
                child: const Text('Detaylar'),
              ),
              ElevatedButton.icon(
                onPressed: onUpgrade ?? () => _handleUpgradeAction(controller),
                icon: const Icon(Icons.upgrade, size: 18),
                label: Text('$timeEstimate\'de tamamla'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isCloseToUnlock ? Get.theme.colorScheme.secondary : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Handle upgrade action with contextual onboarding support
  Future<void> _handleUpgradeAction(FeatureGateController controller) async {
    if (enableContextualOnboarding) {
      try {
        final progressiveController = ProgressiveOnboardingController.to;
        final success = await progressiveController.triggerFeaturePrompt(
          feature,
          customContext: customMessage,
        );

        if (!success) {
          // Fallback to standard profile completion
          controller.navigateToProfileCompletion(feature);
        }
      } catch (e) {
        // If progressive onboarding fails, fallback to standard
        controller.navigateToProfileCompletion(feature);
      }
    } else {
      // Standard profile completion navigation
      controller.navigateToProfileCompletion(feature);
    }
  }

  /// Build upgrade banner widget
  Widget _buildUpgradeBanner(FeatureGateController controller) {
    final featureName = controller.getFeatureDisplayName(feature);
    final timeEstimate = controller.getCompletionTimeEstimate(feature);
    final isCloseToUnlock = controller.isCloseToUnlocking(feature);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCloseToUnlock
            ? Get.theme.colorScheme.secondary.withOpacity(0.1)
            : Get.theme.primaryColor.withOpacity(0.1),
        border: Border(
          left: BorderSide(
            color: isCloseToUnlock
                ? Get.theme.colorScheme.secondary
                : Get.theme.primaryColor,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCloseToUnlock ? Icons.lock_open_outlined : Icons.lock_outline,
            color: isCloseToUnlock
                ? Get.theme.colorScheme.secondary
                : Get.theme.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$featureName özelliği kilitli',
                  style: Get.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Profilinizi $timeEstimate\'de tamamlayarak kilidi açın',
                  style: Get.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onUpgrade ?? () => _handleUpgradeAction(controller),
            icon: const Icon(Icons.upgrade, size: 16),
            label: const Text('Aç'),
          ),
        ],
      ),
    );
  }

  /// Build dialog trigger widget
  Widget _buildDialogTrigger(FeatureGateController controller) {
    return InkWell(
      onTap: () => controller.showFeatureInfo(feature),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Get.theme.dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 16,
              color: Get.theme.primaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              'Kilitli',
              style: Get.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  /// Build overlay widget
  Widget _buildOverlay(FeatureGateController controller) {
    return Stack(
      children: [
        Opacity(
          opacity: 0.3,
          child: child,
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kilitli Özellik',
                    style: Get.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed:
                        onUpgrade ?? () => _handleUpgradeAction(controller),
                    child: const Text('Kilidi Aç'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build inline prompt widget
  Widget _buildInlinePrompt(FeatureGateController controller) {
    final featureName = controller.getFeatureDisplayName(feature);
    final timeEstimate = controller.getCompletionTimeEstimate(feature);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Get.theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Get.theme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_outline,
            size: 16,
            color: Get.theme.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            '$featureName kilitli',
            style: Get.textTheme.bodySmall,
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onUpgrade ?? () => _handleUpgradeAction(controller),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
            ),
            child: Text(
              '$timeEstimate\'de aç',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Feature gate display modes
enum FeatureGateDisplayMode {
  card, // Full card with details
  banner, // Banner at top/bottom
  dialog, // Clickable element that shows dialog
  overlay, // Overlay on top of the original widget
  inline, // Inline small prompt
}

/// Convenient static methods for common use cases
class FeatureGate {
  /// Wrap a widget with feature gating
  static Widget wrap({
    required String feature,
    required Widget child,
    Widget? fallback,
    VoidCallback? onUpgrade,
    bool showUpgradePrompt = true,
    FeatureGateDisplayMode displayMode = FeatureGateDisplayMode.card,
    bool enableContextualOnboarding = true,
  }) {
    return FeatureGateWidget(
      feature: feature,
      displayMode: displayMode,
      showUpgradePrompt: showUpgradePrompt,
      onUpgrade: onUpgrade,
      fallback: fallback,
      enableContextualOnboarding: enableContextualOnboarding,
      child: child,
    );
  }

  /// Create a card-style feature gate
  static Widget card({
    required String feature,
    required Widget child,
    Widget? fallback,
    VoidCallback? onUpgrade,
    String? customMessage,
    bool enableContextualOnboarding = true,
  }) {
    return FeatureGateWidget(
      feature: feature,
      displayMode: FeatureGateDisplayMode.card,
      customMessage: customMessage,
      onUpgrade: onUpgrade,
      fallback: fallback,
      enableContextualOnboarding: enableContextualOnboarding,
      child: child,
    );
  }

  /// Create a banner-style feature gate
  static Widget banner({
    required String feature,
    required Widget child,
    VoidCallback? onUpgrade,
    bool enableContextualOnboarding = true,
  }) {
    return FeatureGateWidget(
      feature: feature,
      displayMode: FeatureGateDisplayMode.banner,
      onUpgrade: onUpgrade,
      enableContextualOnboarding: enableContextualOnboarding,
      child: child,
    );
  }

  /// Create an overlay-style feature gate
  static Widget overlay({
    required String feature,
    required Widget child,
    VoidCallback? onUpgrade,
    bool enableContextualOnboarding = true,
  }) {
    return FeatureGateWidget(
      feature: feature,
      displayMode: FeatureGateDisplayMode.overlay,
      onUpgrade: onUpgrade,
      enableContextualOnboarding: enableContextualOnboarding,
      child: child,
    );
  }

  /// Create an inline-style feature gate
  static Widget inline({
    required String feature,
    required Widget child,
    VoidCallback? onUpgrade,
    bool enableContextualOnboarding = true,
  }) {
    return FeatureGateWidget(
      feature: feature,
      displayMode: FeatureGateDisplayMode.inline,
      onUpgrade: onUpgrade,
      enableContextualOnboarding: enableContextualOnboarding,
      child: child,
    );
  }

  /// Check if a feature is accessible (for conditional rendering)
  static bool canAccess(String feature) {
    try {
      final controller = FeatureGateController.to;
      return controller.canAccessFeature(feature);
    } catch (e) {
      // Controller not initialized, assume no access
      return false;
    }
  }

  /// Get missing fields for a feature
  static List<ProfileField> getMissingFields(String feature) {
    try {
      final controller = FeatureGateController.to;
      return controller.getMissingFieldsForFeature(feature);
    } catch (e) {
      return [];
    }
  }

  /// Show feature info dialog
  static void showInfo(String feature) {
    try {
      final controller = FeatureGateController.to;
      controller.showFeatureInfo(feature);
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Özellik bilgisi yüklenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
