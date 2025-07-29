import 'package:get/get.dart';
import '../controllers/github_integration_controller.dart';
import '../services/github_service.dart';

class GithubIntegrationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GithubService>(() => GithubService());
    Get.lazyPut<GithubIntegrationController>(
        () => GithubIntegrationController());
  }
}
