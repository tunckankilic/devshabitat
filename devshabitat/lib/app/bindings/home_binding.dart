import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../repositories/feed_repository.dart';
import '../services/feed_service.dart';
import '../services/connection_service.dart';
import '../core/services/error_handler_service.dart';
import '../controllers/feed_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<FeedService>(
      () => FeedService(errorHandler: Get.find<ErrorHandlerService>()),
    );
    Get.lazyPut<ConnectionService>(() => ConnectionService());

    // Repositories
    Get.lazyPut<FeedRepository>(() => FeedRepository());

    // Controllers
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<FeedController>(
      () => FeedController(
        repository: Get.find<FeedRepository>(),
        errorHandler: Get.find<ErrorHandlerService>(),
      ),
    );
  }
}
