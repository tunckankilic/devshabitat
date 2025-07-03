import 'package:flutter/material.dart';
import 'package:devshabitat/app/models/video/participant_model.dart';
import 'package:devshabitat/app/widgets/video_call/video_renderer_widget.dart';

class ParticipantGridWidget extends StatelessWidget {
  final List<ParticipantModel> participants;
  final bool isGroupCall;

  const ParticipantGridWidget({
    Key? key,
    required this.participants,
    required this.isGroupCall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 1-1 Görüşme Layout
    if (!isGroupCall) {
      return _buildOneToOneLayout();
    }

    // Grup Görüşmesi Layout
    return _buildGroupLayout();
  }

  Widget _buildOneToOneLayout() {
    return Stack(
      children: [
        // Uzak Katılımcı (Tam Ekran)
        Positioned.fill(
          child: VideoRendererWidget(
            renderer: participants[1].videoRenderer,
            isMuted: participants[1].isMuted,
            isVideoEnabled: participants[1].isVideoEnabled,
            participantName: participants[1].name,
            isScreenShare: participants[1].isScreenSharing,
          ),
        ),
        // Yerel Katılımcı (Küçük Ekran)
        Positioned(
          right: 16,
          top: 16,
          width: 120,
          height: 180,
          child: VideoRendererWidget(
            renderer: participants[0].videoRenderer,
            isMuted: participants[0].isMuted,
            isVideoEnabled: participants[0].isVideoEnabled,
            participantName: participants[0].name,
            isLocalVideo: true,
          ),
        ),
      ],
    );
  }

  Widget _buildGroupLayout() {
    final crossAxisCount = _calculateGridCrossAxisCount();

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 3 / 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        return VideoRendererWidget(
          renderer: participant.videoRenderer,
          isMuted: participant.isMuted,
          isVideoEnabled: participant.isVideoEnabled,
          participantName: participant.name,
          isScreenShare: participant.isScreenSharing,
          isLocalVideo: index == 0,
        );
      },
    );
  }

  int _calculateGridCrossAxisCount() {
    final count = participants.length;
    if (count <= 2) return 1;
    if (count <= 4) return 2;
    if (count <= 9) return 3;
    return 4; // Max 16 katılımcı
  }
}
