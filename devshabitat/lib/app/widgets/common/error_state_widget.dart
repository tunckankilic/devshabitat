import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? imageAsset;
  final double? width;
  final double? height;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.imageAsset = AppAssets.errorImage,
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
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.broken_image,
                    size: 48,
                    color: Colors.red[300],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text(AppStrings.retry),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.errorContainer,
                  foregroundColor: theme.colorScheme.onErrorContainer,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      message: AppStrings.networkError,
      onRetry: onRetry,
      imageAsset: AppAssets.noConnectionImage,
    );
  }
}

class ServerErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const ServerErrorWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      message: AppStrings.serverError,
      onRetry: onRetry,
      imageAsset: AppAssets.serverErrorImage,
    );
  }
}
