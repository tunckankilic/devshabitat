import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:devshabitat/app/models/video/call_settings_model.dart';
import 'package:devshabitat/app/models/video/video_frame.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// RTCStatsReport sınıfı tanımı
class RTCStatsReport {
  final Map<String, dynamic> stats;
  RTCStatsReport(this.stats);

  void forEach(Function(String key, Map<String, dynamic> value) callback) {
    stats.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        callback(key, value);
      }
    });
  }
}

// RTCRtpEncodingParameters sınıfı tanımı
class RTCRtpEncodingParameters {
  final int? maxBitrate;
  final int? maxFramerate;
  final double? scaleResolutionDownBy;

  RTCRtpEncodingParameters({
    this.maxBitrate,
    this.maxFramerate,
    this.scaleResolutionDownBy,
  });
}

// RTCRtpSendParameters sınıfı tanımı
class RTCRtpSendParameters {
  final List<RTCRtpEncodingParameters> encodings;

  RTCRtpSendParameters({
    required this.encodings,
  });
}

enum ConnectionQuality { excellent, good, fair, poor, disconnected }

class ConnectionStats {
  final double bitrate;
  final double packetLoss;
  final double roundTripTime;
  final ConnectionQuality quality;

  ConnectionStats({
    required this.bitrate,
    required this.packetLoss,
    required this.roundTripTime,
    required this.quality,
  });
}

class WebRTCService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  RTCDataChannel? _dataChannel;
  bool _isInitialized = false;
  String? _currentRoomId;

  // Callback fonksiyonları
  Function(RTCTrackEvent)? onTrack;
  Function(RTCPeerConnectionState)? onConnectionStateChange;
  Function(RTCDataChannelMessage)? onDataChannelMessage;

  bool _isBackgroundBlurEnabled = false;
  Interpreter? _interpreter;
  bool _isInterpreterInitialized = false;
  late final FaceDetector _faceDetector;

  MediaRecorder? _mediaRecorder;
  bool _isRecording = false;
  String? _recordingPath;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Timer? _statsTimer;
  final _connectionStatsController =
      StreamController<ConnectionStats>.broadcast();
  Stream<ConnectionStats> get connectionStats =>
      _connectionStatsController.stream;

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

  Future<RTCSessionDescription> createOffer() async {
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    return offer;
  }

  Future<RTCSessionDescription> createAnswer() async {
    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    return answer;
  }

  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    await _peerConnection!.setRemoteDescription(description);
  }

  Future<RTCSessionDescription> handleOffer(
      Map<String, dynamic> message) async {
    await setRemoteDescription(
      RTCSessionDescription(message['sdp'], message['type']),
    );
    final answer = await createAnswer();
    return answer;
  }

  Future<void> handleAnswer(Map<String, dynamic> message) async {
    await setRemoteDescription(
      RTCSessionDescription(message['sdp'], message['type']),
    );
  }

  Future<void> handleIceCandidate(Map<String, dynamic> message) async {
    await addCandidate(
      RTCIceCandidate(
        message['candidate'],
        message['sdpMid'],
        message['sdpMLineIndex'],
      ),
    );
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
    _statsTimer?.cancel();
    _connectionStatsController.close();
    if (_isRecording) {
      await stopRecording();
    }
    await _localStream?.dispose();
    await _remoteStream?.dispose();
    await _peerConnection?.close();
    await _dataChannel?.close();

    _localStream = null;
    _remoteStream = null;
    _peerConnection = null;
    _dataChannel = null;
    _isInitialized = false;

    _interpreter?.close();
    _faceDetector.close();
    _isInterpreterInitialized = false;
  }

  Future<void> joinRoom(String roomId) async {
    if (_currentRoomId != null) {
      await leaveRoom();
    }

    await initialize(settings: CallSettingsModel());
    await createLocalStream();
    _currentRoomId = roomId;
  }

  Future<void> leaveRoom() async {
    if (_currentRoomId == null) return;

    await dispose();
    _currentRoomId = null;
  }

  Future<void> enableVideo(bool enabled) async {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().first;
      videoTrack.enabled = enabled;
    }
  }

  Future<void> enableAudio(bool enabled) async {
    if (_localStream != null) {
      final audioTrack = _localStream!.getAudioTracks().first;
      audioTrack.enabled = enabled;
    }
  }

  Future<void> initializeBackgroundBlur() async {
    if (_isInterpreterInitialized) return;

    try {
      // TensorFlow Lite modelini yükle
      _interpreter = await Interpreter.fromAsset(
          'assets/models/selfie_segmentation.tflite');
      _faceDetector = GoogleMlKit.vision.faceDetector();
      _isInterpreterInitialized = true;
    } catch (e) {
      print('Background blur initialization error: $e');
      _isInterpreterInitialized = false;
    }
  }

  Future<void> toggleBackgroundBlur() async {
    if (!_isInterpreterInitialized) {
      await initializeBackgroundBlur();
    }

    _isBackgroundBlurEnabled = !_isBackgroundBlurEnabled;
    if (_localStream != null) {
      await _applyBackgroundBlur(_localStream!);
    }
  }

  Future<void> _applyBackgroundBlur(MediaStream stream) async {
    // TODO: Implement background blur using platform-specific solution
    print('Background blur is not implemented yet');
  }

  Future<void> startRecording() async {
    if (_isRecording || _localStream == null) return;

    try {
      final directory = await getTemporaryDirectory();
      _recordingPath =
          '${directory.path}/call_${DateTime.now().millisecondsSinceEpoch}.webm';

      _mediaRecorder = MediaRecorder();
      await _mediaRecorder!.start(
        _recordingPath!,
        videoTrack: _localStream!.getVideoTracks().first,
      );

      _isRecording = true;
    } catch (e) {
      print('Recording start error: $e');
      _isRecording = false;
    }
  }

  Future<String?> stopRecording() async {
    if (!_isRecording || _mediaRecorder == null) return null;

    try {
      // Kaydı durdur
      await _mediaRecorder!.stop();
      _isRecording = false;

      // Firebase Storage'a yükle
      final fileName =
          'recordings/call_${DateTime.now().millisecondsSinceEpoch}.webm';
      final ref = _storage.ref().child(fileName);

      final file = File(_recordingPath!);
      await ref.putFile(file);

      // İndirme URL'sini al
      final downloadUrl = await ref.getDownloadURL();

      // Geçici dosyayı sil
      await file.delete();

      _recordingPath = null;
      _mediaRecorder = null;

      return downloadUrl;
    } catch (e) {
      print('Recording stop error: $e');
      return null;
    }
  }

  Future<void> pauseRecording() async {
    if (!_isRecording || _mediaRecorder == null) return;

    try {
      await _mediaRecorder!.stop();
      _isRecording = false;
    } catch (e) {
      print('Recording pause error: $e');
    }
  }

  Future<void> resumeRecording() async {
    if (!_isRecording || _mediaRecorder == null) return;

    try {
      await startRecording();
    } catch (e) {
      print('Recording resume error: $e');
    }
  }

  bool get isRecording => _isRecording;

  int? _lastBytesSent;
  int? _lastTimestamp;

  Future<void> _startConnectionMonitoring() async {
    _statsTimer?.cancel();
    _statsTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_peerConnection == null) return;

      try {
        final stats = await _peerConnection!.getStats();
        final connectionStats = await _processStats(stats);
        _connectionStatsController.add(connectionStats);
        _adjustMediaQuality(connectionStats);
      } catch (e) {
        print('Stats collection error: $e');
      }
    });
  }

  Future<ConnectionStats> _processStats(List<StatsReport> stats) async {
    double bitrate = 0;
    double packetLoss = 0;
    double roundTripTime = 0;

    for (var report in stats) {
      final values = report.values;
      if (report.type == 'outbound-rtp' && values['mediaType'] == 'video') {
        final bytesSent = values['bytesSent'] ?? 0;
        final timestamp = values['timestamp'] ?? 0;

        if (_lastBytesSent != null && _lastTimestamp != null) {
          final byteDiff = bytesSent - _lastBytesSent!;
          final timeDiff = timestamp - _lastTimestamp!;
          bitrate = (byteDiff * 8) / timeDiff;
        }

        _lastBytesSent = bytesSent;
        _lastTimestamp = timestamp;
      }

      if (report.type == 'remote-inbound-rtp') {
        packetLoss = values['packetsLost'] ?? 0;
        roundTripTime = values['roundTripTime'] ?? 0;
      }
    }

    return ConnectionStats(
      bitrate: bitrate,
      packetLoss: packetLoss,
      roundTripTime: roundTripTime,
      quality: _calculateQuality(bitrate, packetLoss, roundTripTime),
    );
  }

  ConnectionQuality _calculateQuality(
    double bitrate,
    double packetLoss,
    double roundTripTime,
  ) {
    if (bitrate == 0 || roundTripTime > 1000) {
      return ConnectionQuality.disconnected;
    }

    if (bitrate < 150000 || packetLoss > 10 || roundTripTime > 500) {
      return ConnectionQuality.poor;
    }

    if (bitrate < 500000 || packetLoss > 5 || roundTripTime > 200) {
      return ConnectionQuality.fair;
    }

    if (bitrate < 1500000 || packetLoss > 2 || roundTripTime > 100) {
      return ConnectionQuality.good;
    }

    return ConnectionQuality.excellent;
  }

  Future<void> _adjustMediaQuality(ConnectionStats stats) async {
    if (_localStream == null) return;

    final videoTrack = _localStream!.getVideoTracks().first;
    final sender = (await _peerConnection!.getSenders())
        .firstWhere((s) => s.track?.kind == 'video');

    final parameters = RTCRtpParameters();

    switch (stats.quality) {
      case ConnectionQuality.poor:
        parameters.encodings = [
          RTCRtpEncoding(
            maxBitrate: 150000,
            maxFramerate: 15,
            scaleResolutionDownBy: 4,
          ),
        ];
        break;

      case ConnectionQuality.fair:
        parameters.encodings = [
          RTCRtpEncoding(
            maxBitrate: 500000,
            maxFramerate: 20,
            scaleResolutionDownBy: 2,
          ),
        ];
        break;

      case ConnectionQuality.good:
      case ConnectionQuality.excellent:
        parameters.encodings = [
          RTCRtpEncoding(
            maxBitrate: 2000000,
            maxFramerate: 30,
            scaleResolutionDownBy: 1,
          ),
        ];
        break;

      case ConnectionQuality.disconnected:
        // Bağlantı koptuğunda yeniden bağlanmayı dene
        _attemptReconnection();
        break;
    }

    if (stats.quality != ConnectionQuality.disconnected) {
      await sender.setParameters(parameters);
    }
  }

  Future<void> _attemptReconnection() async {
    if (_peerConnection?.connectionState ==
        RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
      try {
        final offer = await _peerConnection!.createOffer();
        await _peerConnection!.setLocalDescription(offer);
      } catch (e) {
        print('Reconnection attempt error: $e');
      }
    }
  }
}
