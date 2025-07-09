import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallControlsWidget extends StatelessWidget {
  final bool isAudioEnabled;
  final bool isVideoEnabled;
  final bool isBackgroundBlurEnabled;
  final bool isRecording;
  final VoidCallback onToggleAudio;
  final VoidCallback onToggleVideo;
  final VoidCallback onToggleBackgroundBlur;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onEndCall;

  const CallControlsWidget({
    Key? key,
    required this.isAudioEnabled,
    required this.isVideoEnabled,
    required this.isBackgroundBlurEnabled,
    required this.isRecording,
    required this.onToggleAudio,
    required this.onToggleVideo,
    required this.onToggleBackgroundBlur,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onEndCall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Obx(() => Icon(
                  isAudioEnabled ? Icons.mic : Icons.mic_off,
                  color: Colors.white,
                )),
            backgroundColor: isAudioEnabled
                ? Colors.grey.shade800
                : Theme.of(context).colorScheme.error,
            onPressed: onToggleAudio,
            tooltip: 'Mikrofon',
          ),
          _buildControlButton(
            icon: Obx(() => Icon(
                  isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                  color: Colors.white,
                )),
            backgroundColor: isVideoEnabled
                ? Colors.grey.shade800
                : Theme.of(context).colorScheme.error,
            onPressed: onToggleVideo,
            tooltip: 'Kamera',
          ),
          _buildControlButton(
            icon: const Icon(Icons.switch_camera, color: Colors.white),
            backgroundColor: Colors.grey.shade800,
            onPressed: onToggleBackgroundBlur,
            tooltip: 'Kamera Değiştir',
          ),
          _buildControlButton(
            icon: Obx(() => Icon(
                  isBackgroundBlurEnabled
                      ? Icons.screen_share
                      : Icons.stop_screen_share,
                  color: Colors.white,
                )),
            backgroundColor: isBackgroundBlurEnabled
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade800,
            onPressed: onToggleBackgroundBlur,
            tooltip: 'Ekran Paylaşımı',
          ),
          _buildControlButton(
            icon: Obx(() => Icon(
                  isRecording ? Icons.stop_circle : Icons.fiber_manual_record,
                  color: isRecording ? Colors.red : Colors.white,
                )),
            backgroundColor: Colors.grey.shade800,
            onPressed: isRecording ? onStopRecording : onStartRecording,
            tooltip: 'Kayıt',
          ),
          _buildControlButton(
            icon: const Icon(Icons.call_end, color: Colors.white),
            backgroundColor: Theme.of(context).colorScheme.error,
            onPressed: onEndCall,
            tooltip: 'Görüşmeyi Sonlandır',
          ),
        ],
      ),
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
