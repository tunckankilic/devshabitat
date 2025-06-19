import 'package:get/get.dart';
import '../controllers/networking_controller.dart';

class NetworkingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NetworkingController>(() => NetworkingController());
  }
}
