import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:devshabitat/app/models/video/call_model.dart';
import 'package:devshabitat/app/models/video/participant_model.dart';
import 'package:devshabitat/app/models/video/call_settings_model.dart';
import 'package:devshabitat/app/services/video/webrtc_service.dart';
import 'package:devshabitat/app/services/video/signaling_service.dart';

class CallManagerService extends GetxService {
  final WebRTCService _webRTCService = Get.find();
  final SignalingService _signalingService = Get.find();
  final _currentCall = Rxn<CallModel>();
  final _participants = <String, ParticipantModel>{}.obs;
  final _callSettings = CallSettingsModel().obs;

  CallModel? get currentCall => _currentCall.value;
  Map<String, ParticipantModel> get participants => _participants;
  CallSettingsModel get callSettings => _callSettings.value;

  Future<CallModel> initiateCall({
    required List<String> participantIds,
    required String initiatorId,
    required String initiatorName,
    String? initiatorAvatarUrl,
    CallType type = CallType.video,
    CallSettingsModel? settings,
  }) async {
    if (settings != null) {
      _callSettings.value = settings;
    }

    final callId = const Uuid().v4();
    final roomId = 'room_$callId';
    final renderer = RTCVideoRenderer();
    await renderer.initialize();

    final participants = [
      ParticipantModel(
        id: initiatorId,
        name: initiatorName,
        profileImage: initiatorAvatarUrl,
        videoRenderer: renderer,
      ),
      ...await Future.wait(participantIds.map((id) async {
        final renderer = RTCVideoRenderer();
        await renderer.initialize();
        return ParticipantModel(
          id: id,
          name: 'User $id', // TODO: Fetch user details
          videoRenderer: renderer,
        );
      })),
    ];

    final call = CallModel(
      id: callId,
      roomId: roomId,
      callType: type,
      status: CallStatus.completed, // Başlangıç durumu
      startTime: DateTime.now(),
      duration: Duration.zero,
      participants: participants,
      isGroupCall: participantIds.length > 1,
    );

    await _signalingService.createCall(call);
    _currentCall.value = call;
    _updateParticipants(participants);

    // Join the call
    await joinCall(call);

    return call;
  }

  Future<void> joinCall(CallModel call) async {
    await _webRTCService.joinRoom(call.roomId);
    await _signalingService.updateCallStatus(call.id, CallStatus.completed);

    // Listen for call updates
    _signalingService.watchCall(call.id).listen((updatedCall) {
      _currentCall.value = updatedCall;
      _updateParticipants(updatedCall.participants);
    });

    // Listen for signaling messages
    _signalingService.getSignals(call.id).listen((signals) {
      for (final signal in signals) {
        _handleSignal(signal);
      }
    });
  }

  Future<void> endCall() async {
    if (_currentCall.value == null) return;

    final callId = _currentCall.value!.id;
    await _webRTCService.leaveRoom();
    await _signalingService.endCall(callId);
    await _signalingService.cleanupSignals(callId);

    // Cleanup renderers
    for (final participant in _participants.values) {
      participant.videoRenderer.dispose();
    }

    _currentCall.value = null;
    _participants.clear();
  }

  Future<void> toggleCamera(bool enabled) async {
    await _webRTCService.enableVideo(enabled);
    _updateLocalParticipantState('isVideoEnabled', enabled);
  }

  Future<void> toggleMicrophone(bool enabled) async {
    await _webRTCService.enableAudio(enabled);
    _updateLocalParticipantState('isMuted', !enabled);
  }

  Future<void> switchCamera() async {
    await _webRTCService.switchCamera();
  }

  Future<void> startScreenShare() async {
    await _webRTCService.startScreenSharing();
    _updateLocalParticipantState('isScreenSharing', true);
  }

  void _updateParticipants(List<ParticipantModel> participants) {
    _participants.clear();
    for (final participant in participants) {
      _participants[participant.id] = participant;
    }
  }

  void _updateLocalParticipantState(String key, dynamic value) {
    if (_currentCall.value == null) return;

    final localUserId = _currentCall.value!.participants
        .firstWhere((p) => p.id == _currentCall.value!.id)
        .id;

    if (_participants.containsKey(localUserId)) {
      final oldParticipant = _participants[localUserId]!;
      final newParticipant = oldParticipant.copyWith(
        isMuted: key == 'isMuted' ? value : oldParticipant.isMuted,
        isVideoEnabled:
            key == 'isVideoEnabled' ? value : oldParticipant.isVideoEnabled,
        isScreenSharing:
            key == 'isScreenSharing' ? value : oldParticipant.isScreenSharing,
      );
      _participants[localUserId] = newParticipant;
    }
  }

  void _handleSignal(Map<String, dynamic> signal) {
    final type = signal['type'] as String;
    final data = signal['data'] as Map<String, dynamic>;

    switch (type) {
      case 'participant_state_changed':
        _handleParticipantStateChange(data);
        break;
      case 'participant_left':
        _handleParticipantLeft(data);
        break;
      // Add more signal handlers as needed
    }
  }

  void _handleParticipantStateChange(Map<String, dynamic> data) {
    final userId = data['userId'] as String;
    if (_participants.containsKey(userId)) {
      final oldParticipant = _participants[userId]!;
      final newParticipant = oldParticipant.copyWith(
        isVideoEnabled: data['isVideoEnabled'] as bool?,
        isMuted: data['isMuted'] as bool?,
        isScreenSharing: data['isScreenSharing'] as bool?,
      );
      _participants[userId] = newParticipant;
    }
  }

  void _handleParticipantLeft(Map<String, dynamic> data) {
    final userId = data['userId'] as String;
    if (_participants.containsKey(userId)) {
      _participants.remove(userId);
    }
  }

  @override
  void onClose() {
    endCall();
    super.onClose();
  }
}
