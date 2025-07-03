import 'package:get/get.dart';
import '../../controllers/community/community_create_controller.dart';

class CommunityCreateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommunityCreateController>(
      () => CommunityCreateController(),
    );
  }
}
