import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SuccessAnimationWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onAnimationEnd;
  final String? lottieAsset;
  final double? width;
  final double? height;
  final Duration displayDuration;
  final bool autoHide;

  const SuccessAnimationWidget({
    super.key,
    required this.message,
    this.onAnimationEnd,
    this.lottieAsset = 'assets/animations/success.json',
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
        child: Container(
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
              if (lottieAsset != null)
                Lottie.asset(
                  lottieAsset!,
                  width: width ?? 150,
                  height: height ?? 150,
                  repeat: false,
                  onLoaded: (composition) {
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
            .scale(
              duration: 300.ms,
              curve: Curves.easeOut,
            )
            .fadeIn(
              duration: 300.ms,
              curve: Curves.easeOut,
            ),
      ),
    );
  }
}

class SaveSuccessAnimation extends StatelessWidget {
  final VoidCallback? onAnimationEnd;

  const SaveSuccessAnimation({
    super.key,
    this.onAnimationEnd,
  });

  @override
  Widget build(BuildContext context) {
    return SuccessAnimationWidget(
      message: 'Başarıyla Kaydedildi',
      onAnimationEnd: onAnimationEnd,
      lottieAsset: 'assets/animations/save_success.json',
    );
  }
}

class UpdateSuccessAnimation extends StatelessWidget {
  final VoidCallback? onAnimationEnd;

  const UpdateSuccessAnimation({
    super.key,
    this.onAnimationEnd,
  });

  @override
  Widget build(BuildContext context) {
    return SuccessAnimationWidget(
      message: 'Başarıyla Güncellendi',
      onAnimationEnd: onAnimationEnd,
      lottieAsset: 'assets/animations/update_success.json',
    );
  }
}
