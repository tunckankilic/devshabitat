import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:devshabitat/app/models/video/call_settings_model.dart';

class WebRTCService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  RTCDataChannel? _dataChannel;
  bool _isInitialized = false;

  // Callback fonksiyonları
  Function(RTCTrackEvent)? onTrack;
  Function(RTCPeerConnectionState)? onConnectionStateChange;
  Function(RTCDataChannelMessage)? onDataChannelMessage;

  Future<void> initialize({
    required CallSettingsModel settings,
    Function(RTCTrackEvent)? onTrack,
    Function(RTCPeerConnectionState)? onConnectionStateChange,
    Function(RTCDataChannelMessage)? onDataChannelMessage,
  }) async {
    if (_isInitialized) return;

    this.onTrack = onTrack;
    this.onConnectionStateChange = onConnectionStateChange;
    this.onDataChannelMessage = onDataChannelMessage;

    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {
          'urls': 'turn:your-turn-server.com:3478',
          'username': 'username',
          'credential': 'password',
        },
      ],
      'sdpSemantics': 'unified-plan',
    };

    final constraints = <String, dynamic>{
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': true,
      },
      'optional': [],
    };

    _peerConnection = await createPeerConnection(configuration, constraints);

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      onTrack?.call(event);
      _remoteStream = event.streams[0];
    };

    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      onConnectionStateChange?.call(state);
    };

    _peerConnection!.onDataChannel = (RTCDataChannel channel) {
      _dataChannel = channel;
      _setupDataChannel();
    };

    _isInitialized = true;
  }

  Future<MediaStream> createLocalStream({
    bool audio = true,
    bool video = true,
  }) async {
    final constraints = <String, dynamic>{
      'audio': audio,
      'video': video
          ? {
              'mandatory': {
                'minWidth': '640',
                'minHeight': '480',
                'minFrameRate': '30',
              },
              'facingMode': 'user',
              'optional': [],
            }
          : false,
    };

    _localStream = await navigator.mediaDevices.getUserMedia(constraints);
    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    return _localStream!;
  }

  Future<void> createOffer() async {
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    return offer;
  }

  Future<void> createAnswer() async {
    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    return answer;
  }

  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    await _peerConnection!.setRemoteDescription(description);
  }

  Future<void> addCandidate(RTCIceCandidate candidate) async {
    await _peerConnection!.addCandidate(candidate);
  }

  Future<void> toggleAudio() async {
    if (_localStream != null) {
      final audioTrack = _localStream!.getAudioTracks().first;
      audioTrack.enabled = !audioTrack.enabled;
    }
  }

  Future<void> toggleVideo() async {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().first;
      videoTrack.enabled = !videoTrack.enabled;
    }
  }

  Future<void> switchCamera() async {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().first;
      await Helper.switchCamera(videoTrack);
    }
  }

  Future<void> startScreenSharing() async {
    final mediaConstraints = <String, dynamic>{
      'audio': false,
      'video': true,
    };

    final stream =
        await navigator.mediaDevices.getDisplayMedia(mediaConstraints);
    final screenTrack = stream.getVideoTracks().first;

    // Mevcut video track'i kaldır
    final senders = await _peerConnection!.getSenders();
    final videoSender = senders.firstWhere(
      (sender) => sender.track?.kind == 'video',
    );
    await videoSender.replaceTrack(screenTrack);

    // Eski stream'i kaydet
    _localStream?.getVideoTracks().first.stop();
    _localStream = stream;
  }

  Future<void> stopScreenSharing() async {
    // Ekran paylaşımını durdur
    _localStream?.getVideoTracks().first.stop();

    // Kamera stream'ini yeniden başlat
    final newStream = await createLocalStream(audio: false, video: true);
    final videoTrack = newStream.getVideoTracks().first;

    // Track'i değiştir
    final senders = await _peerConnection!.getSenders();
    final videoSender = senders.firstWhere(
      (sender) => sender.track?.kind == 'video',
    );
    await videoSender.replaceTrack(videoTrack);
  }

  void _setupDataChannel() {
    _dataChannel?.onMessage = (message) {
      onDataChannelMessage?.call(message);
    };
  }

  Future<void> sendMessage(String message) async {
    if (_dataChannel?.state == RTCDataChannelState.RTCDataChannelOpen) {
      _dataChannel?.send(RTCDataChannelMessage(message));
    }
  }

  Future<void> dispose() async {
    await _localStream?.dispose();
    await _remoteStream?.dispose();
    await _peerConnection?.close();
    await _dataChannel?.close();

    _localStream = null;
    _remoteStream = null;
    _peerConnection = null;
    _dataChannel = null;
    _isInitialized = false;
  }
}
