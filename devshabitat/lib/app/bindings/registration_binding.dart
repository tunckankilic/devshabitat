import 'package:get/get.dart';
import '../controllers/registration_controller.dart';
import '../controllers/enhanced_form_validation_controller.dart';
import '../repositories/auth_repository.dart';
import '../core/services/error_handler_service.dart';
import '../controllers/auth_controller.dart';

class RegistrationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegistrationController>(
      () => RegistrationController(
        authRepository: Get.find<AuthRepository>(),
        errorHandler: Get.find<ErrorHandlerService>(),
        authController: Get.find<AuthController>(),
      ),
    );
    Get.lazyPut<EnhancedFormValidationController>(
      () => EnhancedFormValidationController(),
    );
  }
}
