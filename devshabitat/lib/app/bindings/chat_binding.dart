import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../services/chat_service.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    // Service
    Get.lazyPut<ChatService>(() => ChatService(), fenix: true);

    // Controller
    Get.lazyPut<ChatController>(() => ChatController(), fenix: true);
  }
}
