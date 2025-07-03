import 'package:devshabitat/app/models/video/participant_model.dart';

enum CallType { audio, video }

enum CallStatus { completed, missed, rejected, failed }

enum CallConnectionStatus { connecting, connected, reconnecting, disconnected }

class CallModel {
  final String id;
  final String roomId;
  final CallType callType;
  final CallStatus status;
  final DateTime startTime;
  final Duration duration;
  final List<ParticipantModel> participants;
  final bool isGroupCall;
  final Map<String, dynamic>? metadata;

  CallModel({
    required this.id,
    required this.roomId,
    required this.callType,
    required this.status,
    required this.startTime,
    required this.duration,
    required this.participants,
    this.isGroupCall = false,
    this.metadata,
  });

  CallModel copyWith({
    String? id,
    String? roomId,
    CallType? callType,
    CallStatus? status,
    DateTime? startTime,
    Duration? duration,
    List<ParticipantModel>? participants,
    bool? isGroupCall,
    Map<String, dynamic>? metadata,
  }) {
    return CallModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      callType: callType ?? this.callType,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      participants: participants ?? this.participants,
      isGroupCall: isGroupCall ?? this.isGroupCall,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'callType': callType.toString(),
      'status': status.toString(),
      'startTime': startTime.toIso8601String(),
      'duration': duration.inSeconds,
      'participants': participants.map((p) => p.toJson()).toList(),
      'isGroupCall': isGroupCall,
      'metadata': metadata,
    };
  }

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      callType: CallType.values.firstWhere(
        (e) => e.toString() == json['callType'],
        orElse: () => CallType.video,
      ),
      status: CallStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => CallStatus.completed,
      ),
      startTime: DateTime.parse(json['startTime'] as String),
      duration: Duration(seconds: json['duration'] as int),
      participants: (json['participants'] as List)
          .map((p) => ParticipantModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      isGroupCall: json['isGroupCall'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}
