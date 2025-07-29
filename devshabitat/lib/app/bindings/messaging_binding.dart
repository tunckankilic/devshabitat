import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../controllers/message/message_chat_controller.dart';
import '../controllers/message/message_list_controller.dart';
import '../controllers/message/message_search_controller.dart';
import '../controllers/message/message_interaction_controller.dart';
import '../services/messaging_service.dart';
import '../core/services/error_handler_service.dart';

class MessagingBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<Logger>(() => Logger());
    Get.lazyPut<ErrorHandlerService>(() => ErrorHandlerService());
    Get.lazyPut<MessagingService>(
      () => MessagingService(
        firestore: Get.find(),
        errorHandler: Get.find<ErrorHandlerService>(),
        logger: Get.find<Logger>(),
      ),
    );

    // Controllers
    Get.lazyPut<MessageChatController>(
      () => MessageChatController(
        messagingService: Get.find<MessagingService>(),
      ),
    );

    Get.lazyPut<MessageListController>(
      () => MessageListController(
        messagingService: Get.find<MessagingService>(),
        errorHandler: Get.find<ErrorHandlerService>(),
      ),
    );

    Get.lazyPut<MessageSearchController>(
      () => MessageSearchController(
        messagingService: Get.find<MessagingService>(),
        errorHandler: Get.find<ErrorHandlerService>(),
      ),
    );

    Get.lazyPut<MessageInteractionController>(
      () => MessageInteractionController(
        messagingService: Get.find<MessagingService>(),
        errorHandler: Get.find<ErrorHandlerService>(),
      ),
    );
  }
}
