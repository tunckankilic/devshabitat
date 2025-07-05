import 'package:get/get.dart';
import '../../controllers/community/community_event_controller.dart';
import '../../services/community/community_event_service.dart';

class CommunityEventBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CommunityEventService());
    Get.lazyPut(() => CommunityEventController(
          eventService: Get.find<CommunityEventService>(),
        ));
  }
}
