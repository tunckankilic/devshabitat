import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../models/video/participant_model.dart';

class ParticipantGridWidget extends StatelessWidget {
  final List<ParticipantModel> participants;
  final bool isGroupCall;

  const ParticipantGridWidget({
    super.key,
    required this.participants,
    required this.isGroupCall,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isGroupCall ? 2 : 1,
        childAspectRatio: 9 / 16,
      ),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        return RTCVideoView(
          participant.videoRenderer,
          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
        );
      },
    );
  }
}
