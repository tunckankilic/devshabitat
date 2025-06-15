import 'package:flutter/material.dart';

class AdaptiveProgressIndicator extends StatelessWidget {
  final double progress;
  final double size;
  final Color? color;

  const AdaptiveProgressIndicator({
    Key? key,
    required this.progress,
    this.size = 40,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        value: progress,
        strokeWidth: 4,
        backgroundColor: Colors.white.withOpacity(0.3),
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
