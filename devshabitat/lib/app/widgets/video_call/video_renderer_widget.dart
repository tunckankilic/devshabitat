import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class VideoRendererWidget extends StatelessWidget {
  final RTCVideoRenderer renderer;
  final bool isMuted;
  final bool isVideoEnabled;
  final String participantName;
  final bool isScreenShare;
  final bool isLocalVideo;

  const VideoRendererWidget({
    super.key,
    required this.renderer,
    required this.isMuted,
    required this.isVideoEnabled,
    required this.participantName,
    this.isScreenShare = false,
    this.isLocalVideo = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Video Görüntüsü
            if (isVideoEnabled)
              Positioned.fill(
                child: RTCVideoView(
                  renderer,
                  mirror: isLocalVideo && !isScreenShare,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),

            // Video Kapalıyken Avatar
            if (!isVideoEnabled)
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    participantName.characters.first.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // İsim ve Durum Göstergeleri
            Positioned(
              left: 8,
              bottom: 8,
              right: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        participantName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMuted)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.mic_off,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    if (isScreenShare)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.screen_share,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
