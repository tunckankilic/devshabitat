import 'package:get/get.dart';
import '../../controllers/community/community_controller.dart';
import '../../controllers/community/community_event_controller.dart';
import '../../services/community/community_event_service.dart';

class CommunityDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommunityController>(
      () => CommunityController(),
    );

    Get.lazyPut(() => CommunityEventService());
    Get.lazyPut(() => CommunityEventController(
          eventService: Get.find<CommunityEventService>(),
        ));
  }
}
