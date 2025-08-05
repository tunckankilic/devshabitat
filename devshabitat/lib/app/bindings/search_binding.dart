import 'package:get/get.dart';
import '../controllers/search_controller.dart';
import '../services/search_service.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    // Service
    Get.lazyPut<SearchService>(() => SearchService(), fenix: true);

    // Controller
    Get.lazyPut<SearchController>(() => SearchController(), fenix: true);
  }
}
