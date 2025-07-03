import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/controllers/video/video_call_controller.dart';

class CallControlsWidget extends GetView<VideoCallController> {
  const CallControlsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          icon: Obx(() => Icon(
                controller.isAudioEnabled.value ? Icons.mic : Icons.mic_off,
                color: Colors.white,
              )),
          backgroundColor: controller.isAudioEnabled.value
              ? Colors.grey.shade800
              : Theme.of(context).colorScheme.error,
          onPressed: controller.toggleAudio,
          tooltip: 'Mikrofon',
        ),
        _buildControlButton(
          icon: Obx(() => Icon(
                controller.isVideoEnabled.value
                    ? Icons.videocam
                    : Icons.videocam_off,
                color: Colors.white,
              )),
          backgroundColor: controller.isVideoEnabled.value
              ? Colors.grey.shade800
              : Theme.of(context).colorScheme.error,
          onPressed: controller.toggleVideo,
          tooltip: 'Kamera',
        ),
        _buildControlButton(
          icon: const Icon(Icons.switch_camera, color: Colors.white),
          backgroundColor: Colors.grey.shade800,
          onPressed: controller.switchCamera,
          tooltip: 'Kamera Değiştir',
        ),
        _buildControlButton(
          icon: Obx(() => Icon(
                controller.isScreenSharing.value
                    ? Icons.screen_share
                    : Icons.stop_screen_share,
                color: Colors.white,
              )),
          backgroundColor: controller.isScreenSharing.value
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade800,
          onPressed: controller.toggleScreenShare,
          tooltip: 'Ekran Paylaşımı',
        ),
        _buildControlButton(
          icon: const Icon(Icons.call_end, color: Colors.white),
          backgroundColor: Theme.of(context).colorScheme.error,
          onPressed: () {
            controller.endCall();
            Get.back();
          },
          tooltip: 'Görüşmeyi Sonlandır',
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required Widget icon,
    required Color backgroundColor,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(28),
            child: Center(child: icon),
          ),
        ),
      ),
    );
  }
}
