import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devshabitat/app/models/video/participant_model.dart';
import 'package:devshabitat/app/models/video/call_settings_model.dart';
import 'package:devshabitat/app/services/video/webrtc_service.dart';
import 'package:devshabitat/app/services/video/signaling_service.dart';
import 'package:devshabitat/app/core/services/memory_manager_service.dart';

enum CallConnectionStatus {
  connecting,
  connected,
  reconnecting,
  disconnected,
}

class VideoCallController extends GetxController with MemoryManagementMixin {
  final WebRTCService _webRTCService;
  final SignalingService _signalingService;
  final String roomId;
  final bool isInitiator;
  final caller = Get.arguments['caller'];

  VideoCallController({
    required WebRTCService webRTCService,
    required SignalingService signalingService,
    required this.roomId,
    required this.isInitiator,
  })  : _webRTCService = webRTCService,
        _signalingService = signalingService;

  // Durum Değişkenleri
  final _isAudioEnabled = true.obs;
  final _isVideoEnabled = true.obs;
  final _isScreenSharing = false.obs;
  final _callStatus = CallConnectionStatus.connecting.obs;
  final _callDuration = const Duration().obs;
  final _participants = <ParticipantModel>[].obs;
  final _callTitle = ''.obs;
  final _isBackgroundBlurEnabled = false.obs;
  final _isRecording = false.obs;
  String? _recordingUrl;

  // Getters
  bool get isAudioEnabled => _isAudioEnabled.value;
  bool get isVideoEnabled => _isVideoEnabled.value;
  bool get isScreenSharing => _isScreenSharing.value;
  CallConnectionStatus get callStatus => _callStatus.value;
  Duration get callDuration => _callDuration.value;
  List<ParticipantModel> get participants => _participants;
  String get callTitle => _callTitle.value;
  bool get isGroupCall => participants.length > 2;
  bool get isBackgroundBlurEnabled => _isBackgroundBlurEnabled.value;
  bool get isRecording => _isRecording.value;
  String? get recordingUrl => _recordingUrl;

  Timer? _durationTimer;
  StreamSubscription? _signalingSubscription;
  StreamSubscription? _participantSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeCall();
  }

  @override
  void onClose() {
    // Tüm stream'leri temizle
    _signalingSubscription?.cancel();
    _participantSubscription?.cancel();
    _durationTimer?.cancel();

    // WebRTC kaynaklarını temizle
    _webRTCService.dispose();

    // Tüm video renderer'ları temizle
    for (var participant in _participants) {
      participant.videoRenderer.dispose();
    }
    _participants.clear();

    super.onClose();
  }

  Future<void> _initializeCall() async {
    try {
      // WebRTC ve Signaling servisleri başlatılıyor
      await _webRTCService.initialize(
        settings: CallSettingsModel(),
        onTrack: _handleRemoteTrack,
        onConnectionStateChange: _handleConnectionStateChange,
      );

      // Signaling servisine bağlanılıyor
      await _signalingService.joinRoom(
        roomId: roomId,
        userId: Get.find<String>(tag: 'userId'),
        isInitiator: isInitiator,
      );

      // Signaling mesajları dinleniyor - Otomatik yönetim
      _signalingSubscription = _signalingService.onSignalingMessage.listen(
        _handleSignalingMessage,
      );
      registerSubscription(_signalingSubscription!);

      // Katılımcı değişiklikleri dinleniyor - Otomatik yönetim
      _participantSubscription = FirebaseFirestore.instance
          .collection('calls')
          .doc(roomId)
          .collection('participants')
          .snapshots()
          .listen(_handleParticipantChanges);
      registerSubscription(_participantSubscription!);

      // Süre sayacı başlatılıyor - Otomatik yönetim
      _startDurationTimer();

      // Yerel medya akışları başlatılıyor
      await _initializeLocalStreams();
    } catch (e) {
      print('Call initialization error: $e');
      _callStatus.value = CallConnectionStatus.disconnected;
    }
  }

  Future<void> _initializeLocalStreams() async {
    try {
      final localStream = await _webRTCService.createLocalStream(
        audio: true,
        video: true,
      );

      final localParticipant = ParticipantModel(
        id: Get.find<String>(tag: 'userId'),
        name: Get.find<String>(tag: 'userName'),
        videoRenderer: RTCVideoRenderer(),
        isVideoEnabled: true,
        isMuted: false,
      );

      await localParticipant.videoRenderer.initialize();
      localParticipant.videoRenderer.srcObject = localStream;
      _participants.add(localParticipant);
    } catch (e) {
      print('Local stream initialization error: $e');
    }
  }

  void _handleRemoteTrack(RTCTrackEvent event) async {
    try {
      final stream = event.streams[0];
      final senderId = event.track.id!;

      final existingParticipant = _participants.firstWhereOrNull(
        (p) => p.id == senderId,
      );

      if (existingParticipant != null) {
        existingParticipant.videoRenderer.srcObject = stream;
      } else {
        final remoteParticipant = ParticipantModel(
          id: senderId,
          name: 'Remote User',
          videoRenderer: RTCVideoRenderer(),
          isVideoEnabled: true,
          isMuted: false,
        );

        await remoteParticipant.videoRenderer.initialize();
        remoteParticipant.videoRenderer.srcObject = stream;
        _participants.add(remoteParticipant);
      }
    } catch (e) {
      print('Remote track handling error: $e');
    }
  }

  void _handleConnectionStateChange(RTCPeerConnectionState state) {
    switch (state) {
      case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
        _callStatus.value = CallConnectionStatus.connected;
        break;
      case RTCPeerConnectionState.RTCPeerConnectionStateConnecting:
        _callStatus.value = CallConnectionStatus.connecting;
        break;
      case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
      case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
        _callStatus.value = CallConnectionStatus.disconnected;
        break;
      default:
        break;
    }
  }

  void _handleSignalingMessage(Map<String, dynamic> message) async {
    try {
      switch (message['type']) {
        case 'offer':
          await _webRTCService.handleOffer(message);
          break;
        case 'answer':
          await _webRTCService.handleAnswer(message);
          break;
        case 'ice-candidate':
          await _webRTCService.handleIceCandidate(message);
          break;
      }
    } catch (e) {
      print('Signaling message handling error: $e');
    }
  }

  void _handleParticipantChanges(QuerySnapshot snapshot) {
    try {
      final participants = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ParticipantModel.fromJson(data);
      }).toList();

      _updateParticipants(participants);
      _updateCallTitle();
    } catch (e) {
      print('Participant changes handling error: $e');
    }
  }

  void _updateParticipants(List<ParticipantModel> newParticipants) {
    for (var participant in newParticipants) {
      final existingIndex =
          _participants.indexWhere((p) => p.id == participant.id);
      if (existingIndex != -1) {
        _participants[existingIndex] = participant;
      } else {
        _participants.add(participant);
      }
    }

    _participants.removeWhere(
      (p) => !newParticipants.any((newP) => newP.id == p.id),
    );
  }

  void _updateCallTitle() {
    if (participants.length <= 2) {
      _callTitle.value = participants
              .firstWhereOrNull((p) => p.id != Get.find<String>(tag: 'userId'))
              ?.name ??
          'Görüşme';
    } else {
      _callTitle.value = '${participants.length} Kişilik Grup Görüşmesi';
    }
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _callDuration.value = Duration(seconds: timer.tick);
    });
    registerTimer(_durationTimer!); // Otomatik yönetim
  }

  // Kontrol Metodları
  Future<void> toggleAudio() async {
    try {
      await _webRTCService.toggleAudio();
      _isAudioEnabled.value = !_isAudioEnabled.value;

      // Durumu Firestore'a kaydet
      await _signalingService.updateParticipantState(
        roomId: roomId,
        userId: Get.find<String>(tag: 'userId'),
        updates: {'isMuted': !_isAudioEnabled.value},
      );
    } catch (e) {
      print('Toggle audio error: $e');
    }
  }

  Future<void> toggleVideo() async {
    try {
      await _webRTCService.toggleVideo();
      _isVideoEnabled.value = !_isVideoEnabled.value;

      // Durumu Firestore'a kaydet
      await _signalingService.updateParticipantState(
        roomId: roomId,
        userId: Get.find<String>(tag: 'userId'),
        updates: {'isVideoEnabled': _isVideoEnabled.value},
      );
    } catch (e) {
      print('Toggle video error: $e');
    }
  }

  Future<void> toggleScreenShare() async {
    try {
      if (_isScreenSharing.value) {
        await _webRTCService.stopScreenSharing();
      } else {
        await _webRTCService.startScreenSharing();
      }
      _isScreenSharing.value = !_isScreenSharing.value;

      // Durumu Firestore'a kaydet
      await _signalingService.updateParticipantState(
        roomId: roomId,
        userId: Get.find<String>(tag: 'userId'),
        updates: {'isScreenSharing': _isScreenSharing.value},
      );
    } catch (e) {
      print('Toggle screen share error: $e');
    }
  }

  Future<void> switchCamera() async {
    try {
      await _webRTCService.switchCamera();
    } catch (e) {
      print('Switch camera error: $e');
    }
  }

  Future<void> endCall() async {
    try {
      _callStatus.value = CallConnectionStatus.disconnected;
      // Timer otomatik olarak iptal edilecek

      await _signalingService.leaveRoom(
        roomId: roomId,
        userId: Get.find<String>(tag: 'userId'),
      );

      await _webRTCService.dispose();
      Get.back();
    } catch (e) {
      print('End call error: $e');
    }
  }

  Future<void> acceptCall() async {
    try {
      await _initializeCall();
    } catch (e) {
      print('Accept call error: $e');
    }
  }

  Future<void> rejectCall() async {
    try {
      await _signalingService.rejectCall(roomId: roomId);
      Get.back();
    } catch (e) {
      print('Reject call error: $e');
    }
  }

/*
  Future<void> toggleBackgroundBlur() async {
    try {
      await _webRTCService.toggleBackgroundBlur();
      _isBackgroundBlurEnabled.value = !_isBackgroundBlurEnabled.value;
    } catch (e) {
      print('Toggle background blur error: $e');
    }
  }
*/
  Future<void> startRecording() async {
    try {
      await _webRTCService.startRecording();
      _isRecording.value = true;
    } catch (e) {
      print('Start recording error: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      final url = await _webRTCService.stopRecording();
      _isRecording.value = false;
      _recordingUrl = url;

      if (url != null) {
        Get.snackbar(
          'Kayıt Tamamlandı',
          'Görüşme kaydı başarıyla kaydedildi.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Stop recording error: $e');
    }
  }

  Future<void> pauseRecording() async {
    try {
      await _webRTCService.pauseRecording();
    } catch (e) {
      print('Pause recording error: $e');
    }
  }

  Future<void> resumeRecording() async {
    try {
      await _webRTCService.resumeRecording();
    } catch (e) {
      print('Resume recording error: $e');
    }
  }
}
