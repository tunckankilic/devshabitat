import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../constants/app_assets.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? lottieAsset;
  final double? width;
  final double? height;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.lottieAsset = AppAssets.emptyAnimation,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (lottieAsset != null)
              Lottie.asset(
                lottieAsset!,
                width: width ?? 200,
                height: height ?? 200,
                repeat: true,
              ),
            const SizedBox(height: 24),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NoEventsWidget extends StatelessWidget {
  final VoidCallback? onCreateEvent;

  const NoEventsWidget({
    super.key,
    this.onCreateEvent,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      message: 'Henüz hiç etkinlik yok.',
      actionLabel: 'Etkinlik Oluştur',
      onAction: onCreateEvent,
      lottieAsset: AppAssets.noEventsAnimation,
    );
  }
}

class NoCommunityWidget extends StatelessWidget {
  final VoidCallback? onCreateCommunity;

  const NoCommunityWidget({
    super.key,
    this.onCreateCommunity,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      message: 'Henüz hiç topluluk yok.',
      actionLabel: 'Topluluk Oluştur',
      onAction: onCreateCommunity,
      lottieAsset: AppAssets.noCommunityAnimation,
    );
  }
}
