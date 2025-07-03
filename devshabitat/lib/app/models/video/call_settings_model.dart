class CallSettingsModel {
  final bool enableAudioProcessing;
  final bool enableEchoCancellation;
  final bool enableNoiseSuppression;
  final bool enableAutoGainControl;
  final bool enableHighPassFilter;
  final bool enableTypingNoiseDetection;
  final bool enableHardwareAEC;
  final int audioMode;
  final int audioSource;
  final bool useSpeakerphone;
  final bool useBluetoothSCO;
  final bool disableAudioInput;
  final bool disableAudioOutput;
  final bool enableH264HighProfile;
  final int maxBitrate;
  final int minBitrate;
  final int maxFramerate;
  final int minFramerate;
  final int width;
  final int height;

  const CallSettingsModel({
    this.enableAudioProcessing = true,
    this.enableEchoCancellation = true,
    this.enableNoiseSuppression = true,
    this.enableAutoGainControl = true,
    this.enableHighPassFilter = true,
    this.enableTypingNoiseDetection = true,
    this.enableHardwareAEC = true,
    this.audioMode = 0,
    this.audioSource = 0,
    this.useSpeakerphone = true,
    this.useBluetoothSCO = false,
    this.disableAudioInput = false,
    this.disableAudioOutput = false,
    this.enableH264HighProfile = true,
    this.maxBitrate = 2500,
    this.minBitrate = 100,
    this.maxFramerate = 30,
    this.minFramerate = 15,
    this.width = 1280,
    this.height = 720,
  });

  CallSettingsModel copyWith({
    bool? enableAudioProcessing,
    bool? enableEchoCancellation,
    bool? enableNoiseSuppression,
    bool? enableAutoGainControl,
    bool? enableHighPassFilter,
    bool? enableTypingNoiseDetection,
    bool? enableHardwareAEC,
    int? audioMode,
    int? audioSource,
    bool? useSpeakerphone,
    bool? useBluetoothSCO,
    bool? disableAudioInput,
    bool? disableAudioOutput,
    bool? enableH264HighProfile,
    int? maxBitrate,
    int? minBitrate,
    int? maxFramerate,
    int? minFramerate,
    int? width,
    int? height,
  }) {
    return CallSettingsModel(
      enableAudioProcessing:
          enableAudioProcessing ?? this.enableAudioProcessing,
      enableEchoCancellation:
          enableEchoCancellation ?? this.enableEchoCancellation,
      enableNoiseSuppression:
          enableNoiseSuppression ?? this.enableNoiseSuppression,
      enableAutoGainControl:
          enableAutoGainControl ?? this.enableAutoGainControl,
      enableHighPassFilter: enableHighPassFilter ?? this.enableHighPassFilter,
      enableTypingNoiseDetection:
          enableTypingNoiseDetection ?? this.enableTypingNoiseDetection,
      enableHardwareAEC: enableHardwareAEC ?? this.enableHardwareAEC,
      audioMode: audioMode ?? this.audioMode,
      audioSource: audioSource ?? this.audioSource,
      useSpeakerphone: useSpeakerphone ?? this.useSpeakerphone,
      useBluetoothSCO: useBluetoothSCO ?? this.useBluetoothSCO,
      disableAudioInput: disableAudioInput ?? this.disableAudioInput,
      disableAudioOutput: disableAudioOutput ?? this.disableAudioOutput,
      enableH264HighProfile:
          enableH264HighProfile ?? this.enableH264HighProfile,
      maxBitrate: maxBitrate ?? this.maxBitrate,
      minBitrate: minBitrate ?? this.minBitrate,
      maxFramerate: maxFramerate ?? this.maxFramerate,
      minFramerate: minFramerate ?? this.minFramerate,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enableAudioProcessing': enableAudioProcessing,
      'enableEchoCancellation': enableEchoCancellation,
      'enableNoiseSuppression': enableNoiseSuppression,
      'enableAutoGainControl': enableAutoGainControl,
      'enableHighPassFilter': enableHighPassFilter,
      'enableTypingNoiseDetection': enableTypingNoiseDetection,
      'enableHardwareAEC': enableHardwareAEC,
      'audioMode': audioMode,
      'audioSource': audioSource,
      'useSpeakerphone': useSpeakerphone,
      'useBluetoothSCO': useBluetoothSCO,
      'disableAudioInput': disableAudioInput,
      'disableAudioOutput': disableAudioOutput,
      'enableH264HighProfile': enableH264HighProfile,
      'maxBitrate': maxBitrate,
      'minBitrate': minBitrate,
      'maxFramerate': maxFramerate,
      'minFramerate': minFramerate,
      'width': width,
      'height': height,
    };
  }

  factory CallSettingsModel.fromJson(Map<String, dynamic> json) {
    return CallSettingsModel(
      enableAudioProcessing: json['enableAudioProcessing'] as bool? ?? true,
      enableEchoCancellation: json['enableEchoCancellation'] as bool? ?? true,
      enableNoiseSuppression: json['enableNoiseSuppression'] as bool? ?? true,
      enableAutoGainControl: json['enableAutoGainControl'] as bool? ?? true,
      enableHighPassFilter: json['enableHighPassFilter'] as bool? ?? true,
      enableTypingNoiseDetection:
          json['enableTypingNoiseDetection'] as bool? ?? true,
      enableHardwareAEC: json['enableHardwareAEC'] as bool? ?? true,
      audioMode: json['audioMode'] as int? ?? 0,
      audioSource: json['audioSource'] as int? ?? 0,
      useSpeakerphone: json['useSpeakerphone'] as bool? ?? true,
      useBluetoothSCO: json['useBluetoothSCO'] as bool? ?? false,
      disableAudioInput: json['disableAudioInput'] as bool? ?? false,
      disableAudioOutput: json['disableAudioOutput'] as bool? ?? false,
      enableH264HighProfile: json['enableH264HighProfile'] as bool? ?? true,
      maxBitrate: json['maxBitrate'] as int? ?? 2500,
      minBitrate: json['minBitrate'] as int? ?? 100,
      maxFramerate: json['maxFramerate'] as int? ?? 30,
      minFramerate: json['minFramerate'] as int? ?? 15,
      width: json['width'] as int? ?? 1280,
      height: json['height'] as int? ?? 720,
    );
  }
}

class VideoQualitySettings {
  final int width;
  final int height;
  final int frameRate;
  final int bitrate;

  const VideoQualitySettings({
    this.width = 640,
    this.height = 480,
    this.frameRate = 30,
    this.bitrate = 1500,
  });

  factory VideoQualitySettings.fromJson(Map<String, dynamic> json) {
    return VideoQualitySettings(
      width: json['width'] ?? 640,
      height: json['height'] ?? 480,
      frameRate: json['frameRate'] ?? 30,
      bitrate: json['bitrate'] ?? 1500,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'frameRate': frameRate,
      'bitrate': bitrate,
    };
  }
}

class AudioQualitySettings {
  final int sampleRate;
  final int bitrate;
  final bool stereo;
  final bool echoCancellation;
  final bool noiseSuppression;

  const AudioQualitySettings({
    this.sampleRate = 48000,
    this.bitrate = 128,
    this.stereo = false,
    this.echoCancellation = true,
    this.noiseSuppression = true,
  });

  factory AudioQualitySettings.fromJson(Map<String, dynamic> json) {
    return AudioQualitySettings(
      sampleRate: json['sampleRate'] ?? 48000,
      bitrate: json['bitrate'] ?? 128,
      stereo: json['stereo'] ?? false,
      echoCancellation: json['echoCancellation'] ?? true,
      noiseSuppression: json['noiseSuppression'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sampleRate': sampleRate,
      'bitrate': bitrate,
      'stereo': stereo,
      'echoCancellation': echoCancellation,
      'noiseSuppression': noiseSuppression,
    };
  }
}
