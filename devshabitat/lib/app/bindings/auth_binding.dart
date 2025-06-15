import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/form_validation_controller.dart';
import '../controllers/github_validation_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<FormValidationController>(() => FormValidationController());
    Get.lazyPut<GitHubValidationController>(() => GitHubValidationController());
  }
}
