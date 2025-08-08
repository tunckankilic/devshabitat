import 'package:get/get.dart';
import 'package:devshabitat/app/controllers/video/video_call_controller.dart';
import 'package:devshabitat/app/controllers/video/call_history_controller.dart';
import 'package:devshabitat/app/services/video/webrtc_service.dart';
import 'package:devshabitat/app/services/video/signaling_service.dart';

class VideoBinding extends Bindings {
  @override
  void dependencies() {
    // Servisleri kaydet
    Get.lazyPut<WebRTCService>(() => WebRTCService());
    Get.lazyPut<SignalingService>(() => SignalingService());

    // Controller'ları kaydet
    Get.lazyPut<CallHistoryController>(() => CallHistoryController());
    Get.lazyPut<VideoCallController>(
      () => VideoCallController(
        webRTCService: Get.find<WebRTCService>(),
        signalingService: Get.find<SignalingService>(),
        roomId: (Get.arguments is Map && Get.arguments['roomId'] is String)
            ? Get.arguments['roomId'] as String
            : '',
        isInitiator:
            (Get.arguments is Map && Get.arguments['isInitiator'] is bool)
            ? Get.arguments['isInitiator'] as bool
            : false,
      ),
    );
  }
}
