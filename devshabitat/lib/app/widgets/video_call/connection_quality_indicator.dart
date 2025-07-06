import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/services/video/webrtc_service.dart';

class ConnectionQualityIndicator extends StatelessWidget {
  final ConnectionQuality quality;

  const ConnectionQualityIndicator({
    super.key,
    required this.quality,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            _getQualityText(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (quality) {
      case ConnectionQuality.excellent:
        return Colors.green;
      case ConnectionQuality.good:
        return Colors.lightGreen;
      case ConnectionQuality.fair:
        return Colors.orange;
      case ConnectionQuality.poor:
        return Colors.red;
      case ConnectionQuality.disconnected:
        return Colors.grey;
    }
  }

  IconData _getIcon() {
    switch (quality) {
      case ConnectionQuality.excellent:
        return Icons.signal_cellular_alt;
      case ConnectionQuality.good:
        return Icons.signal_cellular_alt_2_bar;
      case ConnectionQuality.fair:
        return Icons.signal_cellular_alt_1_bar;
      case ConnectionQuality.poor:
        return Icons.signal_cellular_connected_no_internet_0_bar;
      case ConnectionQuality.disconnected:
        return Icons.signal_cellular_off;
    }
  }

  String _getQualityText() {
    switch (quality) {
      case ConnectionQuality.excellent:
        return 'Mükemmel';
      case ConnectionQuality.good:
        return 'İyi';
      case ConnectionQuality.fair:
        return 'Orta';
      case ConnectionQuality.poor:
        return 'Zayıf';
      case ConnectionQuality.disconnected:
        return 'Bağlantı Yok';
    }
  }
}

class ConnectionQualityStream extends StatelessWidget {
  final WebRTCService webRTCService;

  const ConnectionQualityStream({
    super.key,
    required this.webRTCService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectionStats>(
      stream: webRTCService.connectionStats,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        return ConnectionQualityIndicator(
          quality: snapshot.data!.quality,
        );
      },
    );
  }
}

class ConnectionDetailsDialog extends StatelessWidget {
  final ConnectionStats stats;

  const ConnectionDetailsDialog({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bağlantı Detayları',
              style: Get.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Bağlantı Kalitesi',
              _getQualityText(stats.quality),
            ),
            _buildDetailRow(
              'Bit Hızı',
              '${(stats.bitrate / 1000000).toStringAsFixed(2)} Mbps',
            ),
            _buildDetailRow(
              'Paket Kaybı',
              '%${stats.packetLoss.toStringAsFixed(1)}',
            ),
            _buildDetailRow(
              'Gecikme',
              '${stats.roundTripTime.toStringAsFixed(0)}ms',
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Get.back(),
                child: const Text('Kapat'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Text(
            value,
            style: Get.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _getQualityText(ConnectionQuality quality) {
    switch (quality) {
      case ConnectionQuality.excellent:
        return 'Mükemmel';
      case ConnectionQuality.good:
        return 'İyi';
      case ConnectionQuality.fair:
        return 'Orta';
      case ConnectionQuality.poor:
        return 'Zayıf';
      case ConnectionQuality.disconnected:
        return 'Bağlantı Yok';
    }
  }
}
