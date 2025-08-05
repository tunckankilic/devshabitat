import 'package:flutter/material.dart';

class ReadingProgressIndicator extends StatelessWidget {
  final double progress;
  final Color color;
  final double height;

  const ReadingProgressIndicator({
    super.key,
    required this.progress,
    this.color = Colors.blue,
    this.height = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(color: Colors.grey[200]),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}
