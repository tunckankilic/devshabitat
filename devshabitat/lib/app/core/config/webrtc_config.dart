import 'package:devshabitat/app/core/config/env.dart';

class WebRTCConfig {
  static String get turnServerIp => Env.turnServerIp;
  static String get turnServerPort => Env.turnServerPort;
  static String get turnsServerPort => Env.turnsServerPort;
  static String get turnServerUsername => Env.turnServerUsername;
  static String get turnServerPassword => Env.turnServerPassword;

  static Map<String, dynamic> get iceServers => {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          {
            'urls': [
              'turn:$turnServerIp:$turnServerPort',
              'turns:$turnServerIp:$turnsServerPort',
            ],
            'username': turnServerUsername,
            'credential': turnServerPassword,
          },
        ],
        'sdpSemantics': 'unified-plan',
      };

  static bool get isConfigured =>
      turnServerIp.isNotEmpty &&
      turnServerPort.isNotEmpty &&
      turnsServerPort.isNotEmpty &&
      turnServerUsername.isNotEmpty &&
      turnServerPassword.isNotEmpty;
}
