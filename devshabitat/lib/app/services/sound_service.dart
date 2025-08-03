import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import '../constants/app_assets.dart';

class SoundService extends GetxService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Ses seviyesi kontrolü
  final RxDouble volume = 1.0.obs;

  // Ses durumu kontrolü
  final RxBool isMuted = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    await _audioPlayer.setVolume(volume.value);
  }

  // Mesaj sesi çal
  Future<void> playMessageSound() async {
    if (isMuted.value) return;
    await _audioPlayer.play(AssetSource(AppAssets.messageSound));
  }

  // Bildirim sesi çal
  Future<void> playNotificationSound() async {
    if (isMuted.value) return;
    await _audioPlayer.play(AssetSource(AppAssets.notificationSound));
  }

  // Ses seviyesini ayarla
  Future<void> setVolume(double value) async {
    volume.value = value;
    await _audioPlayer.setVolume(value);
  }

  // Sesi kapat/aç
  void toggleMute() {
    isMuted.value = !isMuted.value;
    if (isMuted.value) {
      _audioPlayer.setVolume(0);
    } else {
      _audioPlayer.setVolume(volume.value);
    }
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}
