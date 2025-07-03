import 'package:get/get.dart';
import '../../controllers/community/community_controller.dart';

class CommunityDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommunityController>(
      () => CommunityController(),
    );
  }
}
