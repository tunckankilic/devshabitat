import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/form_validation_controller.dart';
import '../controllers/github_validation_controller.dart';
import '../repositories/auth_repository.dart';
import '../core/services/error_handler_service.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController(
          authRepository: Get.find<AuthRepository>(),
          errorHandler: Get.find<ErrorHandlerService>(),
        ));
    Get.lazyPut<FormValidationController>(() => FormValidationController());
    Get.lazyPut<GitHubValidationController>(() => GitHubValidationController());
  }
}
