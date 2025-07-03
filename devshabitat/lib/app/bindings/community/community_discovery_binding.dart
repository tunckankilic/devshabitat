import 'package:get/get.dart';
import '../../controllers/community/community_discovery_controller.dart';

class CommunityDiscoveryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommunityDiscoveryController>(
      () => CommunityDiscoveryController(),
    );
  }
}
