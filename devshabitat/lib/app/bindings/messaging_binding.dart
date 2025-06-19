import 'package:get/get.dart';
import '../controllers/messaging_controller.dart';
import '../services/messaging_service.dart';
import '../core/services/error_handler_service.dart';
import '../services/auth_service.dart';

class MessagingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MessagingService>(() => MessagingService());
    Get.lazyPut<MessagingController>(
      () => MessagingController(
        messagingService: Get.find<MessagingService>(),
        errorHandler: Get.find<ErrorHandlerService>(),
        authService: Get.find<AuthService>(),
      ),
    );
  }
}
