import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/controllers/video/video_call_controller.dart';
import 'package:devshabitat/app/widgets/video_call/connection_quality_indicator.dart';
import 'package:devshabitat/app/services/video/webrtc_service.dart';
import 'package:devshabitat/app/widgets/video_call/call_controls_widget.dart';
import 'package:devshabitat/app/widgets/video_call/participant_grid_widget.dart';
import 'package:devshabitat/app/widgets/video_call/call_status_widget.dart';

class VideoCallView extends GetView<VideoCallController> {
  const VideoCallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Video görüntüleri
            Obx(() {
              if (controller.participants.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return ParticipantGridWidget(
                participants: controller.participants,
                isGroupCall: controller.isGroupCall,
              );
            }),

            // Üst bilgi çubuğu
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Bağlantı kalitesi göstergesi
                    ConnectionQualityStream(
                      webRTCService: Get.find<WebRTCService>(),
                    ),
                    const SizedBox(width: 8),
                    // Görüşme durumu
                    CallStatusWidget(
                      duration: controller.callDuration,
                      isRecording: controller.isRecording,
                    ),
                  ],
                ),
              ),
            ),

            // Alt kontrol çubuğu
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CallControlsWidget(
                isAudioEnabled: controller.isAudioEnabled,
                isVideoEnabled: controller.isVideoEnabled,
                isBackgroundBlurEnabled: controller.isBackgroundBlurEnabled,
                isRecording: controller.isRecording,
                onToggleAudio: controller.toggleAudio,
                onToggleVideo: controller.toggleVideo,
                onToggleBackgroundBlur: () {},
                onStartRecording: controller.startRecording,
                onStopRecording: controller.stopRecording,
                onEndCall: controller.endCall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
