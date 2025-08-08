import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? imageAsset;
  final double? width;
  final double? height;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.imageAsset = AppAssets.emptyImage,
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
            if (imageAsset != null)
              Image.asset(
                imageAsset!,
                width: width ?? 200,
                height: height ?? 200,
                fit: BoxFit.contain,
                errorBuilder: (context, _, __) => Container(
                  width: width ?? 200,
                  height: height ?? 200,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: Colors.grey[600],
                  ),
                ),
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

  const NoEventsWidget({super.key, this.onCreateEvent});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      message: AppStrings.noEvents,
      actionLabel: AppStrings.createEvent,
      onAction: onCreateEvent,
      imageAsset: AppAssets.noEventsImage,
    );
  }
}

class NoCommunityWidget extends StatelessWidget {
  final VoidCallback? onCreateCommunity;

  const NoCommunityWidget({super.key, this.onCreateCommunity});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      message: AppStrings.noCommunities,
      actionLabel: AppStrings.createCommunity,
      onAction: onCreateCommunity,
      imageAsset: AppAssets.noCommunityImage,
    );
  }
}
