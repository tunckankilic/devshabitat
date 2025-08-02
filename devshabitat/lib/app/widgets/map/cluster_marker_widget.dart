import 'package:flutter/material.dart';
import '../../models/map/marker_cluster_model.dart';

class ClusterMarkerWidget extends StatelessWidget {
  final MarkerCluster cluster;
  final VoidCallback? onTap;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;

  const ClusterMarkerWidget({
    super.key,
    required this.cluster,
    this.onTap,
    this.size = 56.0,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.primaryColor;
    final txtColor = textColor ?? theme.colorScheme.onPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                cluster.count.toString(),
                style: TextStyle(
                  color: txtColor,
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (cluster.count > 1) ...[
                const SizedBox(height: 2),
                Text(
                  'markers',
                  style: TextStyle(
                    color: txtColor,
                    fontSize: size * 0.2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
