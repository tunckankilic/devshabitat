import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import '../services/navigation_service.dart';

class NavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavigationService>(() => NavigationService());
    Get.lazyPut<NavigationController>(
      () => NavigationController(Get.find<NavigationService>()),
    );
  }
}
