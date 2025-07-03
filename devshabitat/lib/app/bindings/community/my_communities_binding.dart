import 'package:get/get.dart';
import '../../controllers/community/my_communities_controller.dart';

class MyCommunitiesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyCommunitiesController>(
      () => MyCommunitiesController(),
    );
  }
}
