import 'package:get/get.dart';
import '../../controllers/event/event_detail_controller.dart';
import '../../services/event/event_detail_service.dart';

class EventDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EventDetailService());
    Get.lazyPut(() => EventDetailController(
          eventService: Get.find<EventDetailService>(),
        ));
  }
}
