import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../controllers/message/message_chat_controller.dart';
import '../controllers/message/message_interaction_controller.dart';
import '../controllers/thread_controller.dart';
import '../services/thread_service.dart';
import '../services/user_service.dart';
import '../services/messaging_service.dart';
import '../core/services/error_handler_service.dart';

class MessageBinding extends Bindings {
  @override
  void dependencies() {
    // Core Services
    final errorHandler = Get.find<ErrorHandlerService>();
    final logger = Get.find<Logger>();

    // Messaging Service
    Get.lazyPut<MessagingService>(
        () => MessagingService(
              errorHandler: errorHandler,
              logger: logger,
            ),
        fenix: true);

    // Thread Service
    Get.lazyPut<ThreadService>(() => ThreadService(), fenix: true);

    // Thread Controller
    Get.lazyPut<ThreadController>(() => ThreadController(), fenix: true);

    // Message Controllers
    Get.lazyPut<MessageChatController>(
        () => MessageChatController(
              messagingService: Get.find<MessagingService>(),
              errorHandler: errorHandler,
            ),
        fenix: true);

    Get.lazyPut<MessageInteractionController>(
        () => MessageInteractionController(
              messagingService: Get.find<MessagingService>(),
              errorHandler: errorHandler,
            ),
        fenix: true);

    // User Service (ThreadService için gerekli)
    Get.lazyPut<UserService>(() => UserService(), fenix: true);
  }
}
