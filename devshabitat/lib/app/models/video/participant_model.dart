import 'package:flutter_webrtc/flutter_webrtc.dart';

class ParticipantModel {
  final String id;
  final String name;
  final String? profileImage;
  final RTCVideoRenderer videoRenderer;
  final bool isMuted;
  final bool isVideoEnabled;
  final bool isScreenSharing;
  final RTCPeerConnection? peerConnection;

  ParticipantModel({
    required this.id,
    required this.name,
    this.profileImage,
    required this.videoRenderer,
    this.isMuted = false,
    this.isVideoEnabled = true,
    this.isScreenSharing = false,
    this.peerConnection,
  });

  ParticipantModel copyWith({
    String? id,
    String? name,
    String? profileImage,
    RTCVideoRenderer? videoRenderer,
    bool? isMuted,
    bool? isVideoEnabled,
    bool? isScreenSharing,
    RTCPeerConnection? peerConnection,
  }) {
    return ParticipantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      videoRenderer: videoRenderer ?? this.videoRenderer,
      isMuted: isMuted ?? this.isMuted,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      isScreenSharing: isScreenSharing ?? this.isScreenSharing,
      peerConnection: peerConnection ?? this.peerConnection,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profileImage': profileImage,
      'isMuted': isMuted,
      'isVideoEnabled': isVideoEnabled,
      'isScreenSharing': isScreenSharing,
    };
  }

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      profileImage: json['profileImage'] as String?,
      videoRenderer: RTCVideoRenderer(),
      isMuted: json['isMuted'] as bool? ?? false,
      isVideoEnabled: json['isVideoEnabled'] as bool? ?? true,
      isScreenSharing: json['isScreenSharing'] as bool? ?? false,
    );
  }
}
