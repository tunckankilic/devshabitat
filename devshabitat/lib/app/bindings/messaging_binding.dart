import 'package:get/get.dart';
import '../controllers/messaging_controller.dart';
import '../services/messaging_service.dart';

class MessagingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MessagingService>(() => MessagingService());
    Get.lazyPut<MessagingController>(() => MessagingController());
  }
}
