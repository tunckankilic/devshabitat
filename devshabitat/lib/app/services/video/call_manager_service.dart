import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
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
    CallType type = CallType.oneToOne,
    CallSettingsModel? settings,
  }) async {
    if (settings != null) {
      _callSettings.value = settings;
    }

    final callId = const Uuid().v4();
    final channelName = 'channel_$callId';
    // TODO: Implement token generation service
    final token = 'YOUR_AGORA_TOKEN';

    final participants = [
      ParticipantModel(
        userId: initiatorId,
        name: initiatorName,
        avatarUrl: initiatorAvatarUrl,
        joinedAt: DateTime.now(),
      ),
      ...participantIds.map((id) => ParticipantModel(
            userId: id,
            name: 'User $id', // TODO: Fetch user details
            joinedAt: DateTime.now(),
          )),
    ];

    final call = CallModel(
      id: callId,
      channelName: channelName,
      token: token,
      initiatorId: initiatorId,
      participants: participants,
      type: type,
      status: CallStatus.pending,
      startTime: DateTime.now(),
    );

    await _signalingService.createCall(call);
    _currentCall.value = call;
    _updateParticipants(participants);

    // Join the call
    await joinCall(call);

    return call;
  }

  Future<void> joinCall(CallModel call) async {
    await _webRTCService.joinChannel(call.channelName, call.token);
    await _signalingService.updateCallStatus(call.id, CallStatus.active);

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
    await _webRTCService.leaveChannel();
    await _signalingService.endCall(callId);
    await _signalingService.cleanupSignals(callId);

    _currentCall.value = null;
    _participants.clear();
  }

  Future<void> toggleCamera(bool enabled) async {
    await _webRTCService.toggleCamera(enabled);
    _updateLocalParticipantState('isVideoEnabled', enabled);
  }

  Future<void> toggleMicrophone(bool enabled) async {
    await _webRTCService.toggleMicrophone(enabled);
    _updateLocalParticipantState('isAudioEnabled', enabled);
  }

  Future<void> switchCamera() async {
    await _webRTCService.switchCamera();
  }

  Future<void> startScreenShare() async {
    await _webRTCService.startScreenShare();
    _updateLocalParticipantState('isScreenSharing', true);
  }

  void _updateParticipants(List<ParticipantModel> participants) {
    _participants.clear();
    for (final participant in participants) {
      _participants[participant.userId] = participant;
    }
  }

  void _updateLocalParticipantState(String key, dynamic value) {
    if (_currentCall.value == null) return;

    final localUserId = _currentCall.value!.initiatorId;
    if (_participants.containsKey(localUserId)) {
      final participant = _participants[localUserId]!;
      switch (key) {
        case 'isVideoEnabled':
          participant.isVideoEnabled = value as bool;
          break;
        case 'isAudioEnabled':
          participant.isAudioEnabled = value as bool;
          break;
        case 'isScreenSharing':
          participant.isScreenSharing = value as bool;
          break;
      }
      _participants[localUserId] = participant;
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
      final participant = _participants[userId]!;
      if (data.containsKey('isVideoEnabled')) {
        participant.isVideoEnabled = data['isVideoEnabled'] as bool;
      }
      if (data.containsKey('isAudioEnabled')) {
        participant.isAudioEnabled = data['isAudioEnabled'] as bool;
      }
      if (data.containsKey('isScreenSharing')) {
        participant.isScreenSharing = data['isScreenSharing'] as bool;
      }
      _participants[userId] = participant;
    }
  }

  void _handleParticipantLeft(Map<String, dynamic> data) {
    final userId = data['userId'] as String;
    if (_participants.containsKey(userId)) {
      final participant = _participants[userId]!;
      participant.leftAt = DateTime.now();
      _participants[userId] = participant;
    }
  }

  @override
  void onClose() {
    endCall();
    super.onClose();
  }
}
