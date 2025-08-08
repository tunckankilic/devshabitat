import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_assets.dart';

class SuccessAnimationWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onAnimationEnd;
  final String? imageAsset;
  final double? width;
  final double? height;
  final Duration displayDuration;
  final bool autoHide;

  const SuccessAnimationWidget({
    super.key,
    required this.message,
    this.onAnimationEnd,
    this.imageAsset = AppAssets.successImage,
    this.width,
    this.height,
    this.displayDuration = const Duration(seconds: 2),
    this.autoHide = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Material(
        color: Colors.transparent,
        child:
            Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (imageAsset != null)
                        Image.asset(
                          imageAsset!,
                          width: width ?? 150,
                          height: height ?? 150,
                          fit: BoxFit.contain,
                          errorBuilder: (context, _, __) => Container(
                            width: width ?? 150,
                            height: height ?? 150,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.check_circle,
                              size: 48,
                              color: Colors.green[400],
                            ),
                          ),
                        ).animate(
                          onComplete: (controller) {
                            if (autoHide) {
                              Future.delayed(displayDuration, () {
                                onAnimationEnd?.call();
                              });
                            }
                          },
                        ),
                      const SizedBox(height: 16),
                      Text(
                        message,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                .animate()
                .scale(duration: 300.ms, curve: Curves.easeOut)
                .fadeIn(duration: 300.ms, curve: Curves.easeOut),
      ),
    );
  }
}

class SaveSuccessAnimation extends StatelessWidget {
  final VoidCallback? onAnimationEnd;

  const SaveSuccessAnimation({super.key, this.onAnimationEnd});

  @override
  Widget build(BuildContext context) {
    return SuccessAnimationWidget(
      message: AppStrings.saveSuccess,
      onAnimationEnd: onAnimationEnd,
      imageAsset: AppAssets.saveSuccessImage,
    );
  }
}

class UpdateSuccessAnimation extends StatelessWidget {
  final VoidCallback? onAnimationEnd;

  const UpdateSuccessAnimation({super.key, this.onAnimationEnd});

  @override
  Widget build(BuildContext context) {
    return SuccessAnimationWidget(
      message: AppStrings.updateSuccess,
      onAnimationEnd: onAnimationEnd,
      imageAsset: AppAssets.updateSuccessImage,
    );
  }
}
