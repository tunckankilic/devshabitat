import 'package:get/get.dart';
import '../controllers/message/message_search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MessageSearchController>(() => MessageSearchController(
          messagingService: Get.find(),
          errorHandler: Get.find(),
        ));
  }
}
