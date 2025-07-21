import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/controllers/video/video_call_controller.dart';

class CallStatusWidget extends GetView<VideoCallController> {
  final Duration duration;
  final bool isRecording;

  const CallStatusWidget({
    super.key,
    required this.duration,
    required this.isRecording,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.callStatus;

      return Row(
        children: [
          _buildStatusIndicator(status),
          const SizedBox(width: 8),
          Text(
            _getStatusText(status, duration),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          if (isRecording) ...[
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              AppStrings.recording,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildStatusIndicator(CallConnectionStatus status) {
    Color indicatorColor = Colors.grey; // Varsayılan renk
    switch (status) {
      case CallConnectionStatus.connecting:
        indicatorColor = Colors.orange;
        break;
      case CallConnectionStatus.connected:
        indicatorColor = Colors.green;
        break;
      case CallConnectionStatus.reconnecting:
        indicatorColor = Colors.orange;
        break;
      case CallConnectionStatus.disconnected:
        indicatorColor = Colors.red;
        break;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: indicatorColor,
        shape: BoxShape.circle,
      ),
    );
  }

  String _getStatusText(CallConnectionStatus status, Duration duration) {
    switch (status) {
      case CallConnectionStatus.connecting:
        return AppStrings.connecting;
      case CallConnectionStatus.connected:
        return _formatDuration(duration);
      case CallConnectionStatus.reconnecting:
        return AppStrings.reconnecting;
      case CallConnectionStatus.disconnected:
        return AppStrings.disconnected;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}
