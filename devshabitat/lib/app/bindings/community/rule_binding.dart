import 'package:get/get.dart';
import '../../controllers/community/rule_controller.dart';
import '../../services/community/rule_service.dart';

class RuleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RuleService());
    Get.lazyPut(() => RuleController());
  }
}
