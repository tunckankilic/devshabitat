import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/controllers/video/video_call_controller.dart';
import 'package:devshabitat/app/widgets/video_call/video_renderer_widget.dart';
import 'package:devshabitat/app/widgets/video_call/call_controls_widget.dart';
import 'package:devshabitat/app/widgets/video_call/participant_grid_widget.dart';
import 'package:devshabitat/app/widgets/video_call/call_status_widget.dart';

class VideoCallView extends GetView<VideoCallController> {
  const VideoCallView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Katılımcı Grid
            Positioned.fill(
              child: Obx(() => ParticipantGridWidget(
                    participants: controller.participants,
                    isGroupCall: controller.isGroupCall,
                  )),
            ),

            // Üst Bilgi Çubuğu
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
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => controller.endCall(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => Text(
                                controller.callTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                          const SizedBox(height: 4),
                          const CallStatusWidget(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Kontrol Butonları
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
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
                child: const CallControlsWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
