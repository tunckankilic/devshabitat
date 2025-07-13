import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:devshabitat/app/models/video/call_settings_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:devshabitat/app/core/config/webrtc_config.dart';
import 'package:logger/logger.dart';

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
  bool _isDisposed = false;
  String? _currentRoomId;
  final _logger = Logger();

  // Callback fonksiyonları
  Function(RTCTrackEvent)? onTrack;
  Function(RTCPeerConnectionState)? onConnectionStateChange;
  Function(RTCDataChannelMessage)? onDataChannelMessage;

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
    if (_isInitialized || _isDisposed) return;

    try {
      this.onTrack = onTrack;
      this.onConnectionStateChange = onConnectionStateChange;
      this.onDataChannelMessage = onDataChannelMessage;

      if (!WebRTCConfig.isConfigured) {
        throw Exception('WebRTC TURN/STUN sunucusu yapılandırması eksik!');
      }

      final configuration = WebRTCConfig.iceServers;

      final constraints = <String, dynamic>{
        'mandatory': {
          'OfferToReceiveAudio': true,
          'OfferToReceiveVideo': true,
        },
        'optional': [],
      };

      _peerConnection = await createPeerConnection(configuration, constraints);

      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (!_isDisposed) {
          onTrack?.call(event);
          _remoteStream = event.streams[0];
        }
      };

      _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
        if (!_isDisposed) {
          onConnectionStateChange?.call(state);
        }
      };

      _peerConnection!.onDataChannel = (RTCDataChannel channel) {
        if (!_isDisposed) {
          _dataChannel = channel;
          _setupDataChannel();
        }
      };

      _isInitialized = true;
      await _startConnectionMonitoring();
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  Future<MediaStream> createLocalStream({
    bool audio = true,
    bool video = true,
  }) async {
    if (_isDisposed) {
      throw Exception('Service disposed');
    }

    try {
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

      if (!_isDisposed && _peerConnection != null) {
        _localStream!.getTracks().forEach((track) {
          _peerConnection!.addTrack(track, _localStream!);
        });
      }

      return _localStream!;
    } catch (e) {
      _localStream = null;
      rethrow;
    }
  }

  Future<RTCSessionDescription> createOffer() async {
    if (_isDisposed || _peerConnection == null) {
      throw Exception('Connection not initialized or disposed');
    }

    try {
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      return offer;
    } catch (e) {
      rethrow;
    }
  }

  Future<RTCSessionDescription> createAnswer() async {
    if (_isDisposed || _peerConnection == null) {
      throw Exception('Connection not initialized or disposed');
    }

    try {
      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      return answer;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    if (_isDisposed || _peerConnection == null) {
      throw Exception('Connection not initialized or disposed');
    }

    try {
      await _peerConnection!.setRemoteDescription(description);
    } catch (e) {
      rethrow;
    }
  }

  Future<RTCSessionDescription> handleOffer(
      Map<String, dynamic> message) async {
    if (_isDisposed || _peerConnection == null) {
      _logger.e('Connection not initialized or disposed');
      throw Exception('Connection not initialized or disposed');
    }

    try {
      if (!message.containsKey('sdp') || !message.containsKey('type')) {
        _logger.e('Invalid SDP offer format');
        throw Exception('Invalid SDP offer format');
      }

      final sdp = message['sdp'] as String?;
      final type = message['type'] as String?;

      if (sdp == null || sdp.isEmpty || type == null || type.isEmpty) {
        _logger.e('Empty SDP or type in offer');
        throw Exception('Empty SDP or type in offer');
      }

      _logger.i('Setting remote description from offer');
      await setRemoteDescription(
        RTCSessionDescription(sdp, type),
      );

      _logger.i('Creating answer');
      final answer = await createAnswer();
      _logger.i('Answer created successfully');
      return answer;
    } catch (e) {
      _logger.e('Error handling offer: $e');
      rethrow;
    }
  }

  Future<void> handleAnswer(Map<String, dynamic> message) async {
    if (_isDisposed || _peerConnection == null) {
      _logger.e('Connection not initialized or disposed');
      throw Exception('Connection not initialized or disposed');
    }

    try {
      if (!message.containsKey('sdp') || !message.containsKey('type')) {
        _logger.e('Invalid SDP answer format');
        throw Exception('Invalid SDP answer format');
      }

      final sdp = message['sdp'] as String?;
      final type = message['type'] as String?;

      if (sdp == null || sdp.isEmpty || type == null || type.isEmpty) {
        _logger.e('Empty SDP or type in answer');
        throw Exception('Empty SDP or type in answer');
      }

      _logger.i('Setting remote description from answer');
      await setRemoteDescription(
        RTCSessionDescription(sdp, type),
      );
      _logger.i('Remote description set successfully');
    } catch (e) {
      _logger.e('Error handling answer: $e');
      rethrow;
    }
  }

  Future<void> handleIceCandidate(Map<String, dynamic> message) async {
    if (_isDisposed || _peerConnection == null) {
      _logger.w('Peer connection disposed or not initialized');
      return;
    }

    try {
      if (!message.containsKey('candidate') ||
          !message.containsKey('sdpMid') ||
          !message.containsKey('sdpMLineIndex')) {
        throw Exception('Invalid ICE candidate format');
      }

      final candidate = RTCIceCandidate(
        message['candidate'],
        message['sdpMid'],
        message['sdpMLineIndex'],
      );

      if (candidate.candidate == null || candidate.candidate!.isEmpty) {
        _logger.w('Empty ICE candidate received, skipping...');
        return;
      }

      await addCandidate(candidate);
      _logger.i('ICE candidate added successfully');
    } catch (e) {
      _logger.e('Error handling ICE candidate: $e');
      if (e is Exception &&
          e.toString().contains('Invalid ICE candidate format')) {
        rethrow; // Format hatalarını yukarı ilet
      }
      // Diğer ICE candidate hataları genellikle kritik değildir
    }
  }

  Future<void> addCandidate(RTCIceCandidate candidate) async {
    if (_isDisposed || _peerConnection == null) {
      _logger.w(
          'Cannot add ICE candidate: connection disposed or not initialized');
      return;
    }

    try {
      if (candidate.candidate == null || candidate.candidate!.isEmpty) {
        _logger.w('Empty ICE candidate, skipping...');
        return;
      }

      if (_peerConnection!.connectionState ==
              RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          _peerConnection!.connectionState ==
              RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        _logger.w(
            'Cannot add ICE candidate: connection in ${_peerConnection!.connectionState} state');
        return;
      }

      await _peerConnection!.addCandidate(candidate);
      _logger.i('ICE candidate added successfully');
    } catch (e) {
      _logger.e('Error adding ICE candidate: $e');
      if (e.toString().contains('InvalidStateError')) {
        _logger.w('Connection state error, attempting reconnection...');
        _attemptReconnection();
      }
    }
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
    if (_isDisposed || _dataChannel == null) return;

    _dataChannel!.onMessage = (RTCDataChannelMessage message) {
      if (!_isDisposed) {
        onDataChannelMessage?.call(message);
      }
    };

    _dataChannel!.onDataChannelState = (RTCDataChannelState state) {
      if (state == RTCDataChannelState.RTCDataChannelClosed) {
        _dataChannel = null;
      }
    };
  }

  Future<void> sendMessage(String message) async {
    if (_dataChannel?.state == RTCDataChannelState.RTCDataChannelOpen) {
      _dataChannel?.send(RTCDataChannelMessage(message));
    }
  }

  Future<void> dispose() async {
    if (_isDisposed) {
      _logger.w('WebRTC service already disposed');
      return;
    }

    _logger.i('Disposing WebRTC service...');
    _isDisposed = true;
    _isInitialized = false;

    try {
      // Timer'ı durdur
      if (_statsTimer != null) {
        _logger.i('Canceling stats timer');
        _statsTimer?.cancel();
        _statsTimer = null;
      }

      // Data channel'ı kapat
      if (_dataChannel != null) {
        _logger.i('Closing data channel');
        _dataChannel?.close();
        _dataChannel = null;
      }

      // Stream'leri durdur
      if (_localStream != null) {
        _logger.i('Stopping local stream tracks');
        _localStream?.getTracks().forEach((track) {
          track.stop();
          _logger.i('Stopped track: ${track.kind}');
        });
        _localStream = null;
      }
      _remoteStream = null;

      // Peer connection'ı kapat
      if (_peerConnection != null) {
        _logger.i('Closing peer connection');
        await _peerConnection!.close();
        _peerConnection = null;
      }

      // Stream controller'ı kapat
      if (!_connectionStatsController.isClosed) {
        _logger.i('Closing connection stats controller');
        _connectionStatsController.close();
      }

      // Recording'i durdur
      if (_isRecording) {
        _logger.i('Stopping active recording');
        await stopRecording();
      }

      _logger.i('WebRTC service disposed successfully');
    } catch (e) {
      _logger.e('Error disposing WebRTC service: $e');
      // Hata durumunda bile kaynakları temizlemeye çalış
      _cleanupResources();
    }
  }

  void _cleanupResources() {
    _logger.i('Cleaning up remaining resources');
    try {
      _statsTimer?.cancel();
      _dataChannel?.close();
      _localStream?.getTracks().forEach((track) => track.stop());
      _peerConnection?.close();
      if (!_connectionStatsController.isClosed) {
        _connectionStatsController.close();
      }
    } catch (e) {
      _logger.e('Error during cleanup: $e');
    }
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

  Future<void> applyBackgroundBlur() async {
    try {
      if (Platform.isIOS) {
        await _applyIOSBackgroundBlur();
      } else if (Platform.isAndroid) {
        await _applyAndroidBackgroundBlur();
      } else {
        print('Background blur not supported on this platform');
      }
    } catch (e) {
      print('Error applying background blur: $e');
    }
  }

  Future<void> _applyIOSBackgroundBlur() async {
    // iOS spesifik implementasyon
    final localVideoTrack = _localStream?.getVideoTracks().first;
    if (localVideoTrack != null) {
      await localVideoTrack.applyConstraints({
        'backgroundBlur': true,
        'blurStrength': 15,
      });
    }
  }

  Future<void> _applyAndroidBackgroundBlur() async {
    // Android spesifik implementasyon
    final localVideoTrack = _localStream?.getVideoTracks().first;
    if (localVideoTrack != null) {
      await localVideoTrack.applyConstraints({
        'backgroundBlur': true,
        'blurStrength': 15,
      });
    }
  }

  // Recording methods
  Future<void> startRecording() async {
    if (_isDisposed || _localStream == null) return;

    try {
      _isRecording = true;
      // Recording implementation
    } catch (e) {
      _isRecording = false;
      rethrow;
    }
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

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

  Future<void> _startConnectionMonitoring() async {
    if (_isDisposed) return;

    _statsTimer?.cancel();
    _statsTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      try {
        if (_peerConnection != null) {
          final stats = await _peerConnection!.getStats();
          final connectionStats = _processConnectionStats(stats);
          if (!_isDisposed) {
            _connectionStatsController.add(connectionStats);
          }
        }
      } catch (e) {
        print('Error getting connection stats: $e');
      }
    });
  }

  ConnectionStats _processConnectionStats(List<StatsReport> stats) {
    double bitrate = 0.0;
    double packetLoss = 0.0;
    double roundTripTime = 0.0;

    for (final report in stats) {
      final values = report.values;
      if (report.type == 'outbound-rtp') {
        bitrate = (values['bytesSent'] ?? 0) * 8 / 1000; // kbps
      } else if (report.type == 'inbound-rtp') {
        packetLoss = (values['packetsLost'] ?? 0).toDouble();
      } else if (report.type == 'candidate-pair') {
        roundTripTime = (values['currentRoundTripTime'] ?? 0).toDouble();
      }
    }

    final quality =
        _determineConnectionQuality(bitrate, packetLoss, roundTripTime);

    return ConnectionStats(
      bitrate: bitrate,
      packetLoss: packetLoss,
      roundTripTime: roundTripTime,
      quality: quality,
    );
  }

  ConnectionQuality _determineConnectionQuality(
    double bitrate,
    double packetLoss,
    double roundTripTime,
  ) {
    if (bitrate < 100 || packetLoss > 5 || roundTripTime > 300) {
      return ConnectionQuality.poor;
    } else if (bitrate < 500 || packetLoss > 2 || roundTripTime > 150) {
      return ConnectionQuality.fair;
    } else if (bitrate < 1000 || packetLoss > 1 || roundTripTime > 100) {
      return ConnectionQuality.good;
    } else {
      return ConnectionQuality.excellent;
    }
  }

/*
  Future<void> _adjustMediaQuality(ConnectionStats stats) async {
    if (_localStream == null) return;

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
*/
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

  // Utility methods
  bool get isInitialized => _isInitialized && !_isDisposed;
  bool get isDisposed => _isDisposed;
  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;
}
