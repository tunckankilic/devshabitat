import 'package:get/get.dart';
import '../../controllers/community/community_manage_controller.dart';

class CommunityManageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommunityManageController>(
      () => CommunityManageController(),
    );
  }
}
