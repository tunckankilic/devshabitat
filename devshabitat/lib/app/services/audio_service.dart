import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService extends GetxService {
  static AudioService get to => Get.find();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final RxBool isSoundEnabled = true.obs;
  final RxDouble volume = 0.5.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isSoundEnabled.value = prefs.getBool('sound_enabled') ?? true;
      volume.value = prefs.getDouble('sound_volume') ?? 0.5;
    } catch (e) {
      print('Audio settings load error: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sound_enabled', isSoundEnabled.value);
      await prefs.setDouble('sound_volume', volume.value);
    } catch (e) {
      print('Audio settings save error: $e');
    }
  }

  Future<void> playNotificationSound() async {
    if (!isSoundEnabled.value) return;

    try {
      await _audioPlayer.setVolume(volume.value);
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      print('Notification sound play error: $e');
    }
  }

  Future<void> playMessageSound() async {
    if (!isSoundEnabled.value) return;

    try {
      await _audioPlayer.setVolume(volume.value);
      await _audioPlayer.play(AssetSource('sounds/message.mp3'));
    } catch (e) {
      print('Message sound play error: $e');
    }
  }

  Future<void> toggleSound() async {
    isSoundEnabled.value = !isSoundEnabled.value;
    await _saveSettings();
  }

  Future<void> setVolume(double newVolume) async {
    volume.value = newVolume.clamp(0.0, 1.0);
    await _saveSettings();
  }
}
