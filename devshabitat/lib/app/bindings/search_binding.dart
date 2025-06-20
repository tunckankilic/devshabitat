import 'package:get/get.dart';
import '../controllers/message_search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MessageSearchController>(() => MessageSearchController());
  }
}
