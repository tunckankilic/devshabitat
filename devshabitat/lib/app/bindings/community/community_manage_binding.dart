import 'package:get/get.dart';
import '../../controllers/community/community_manage_controller.dart';
import '../../services/community/rule_service.dart';

class CommunityManageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RuleService());
    Get.lazyPut<CommunityManageController>(
      () => CommunityManageController(),
    );
  }
}
