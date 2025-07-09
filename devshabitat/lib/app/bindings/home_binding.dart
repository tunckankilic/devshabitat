import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../repositories/feed_repository.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(FeedRepository());
    Get.put(HomeController());
  }
}
