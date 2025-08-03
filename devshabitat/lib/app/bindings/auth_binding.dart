import 'package:devshabitat/app/services/feature_gate_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../controllers/auth_controller.dart';
import '../controllers/email_auth_controller.dart';
import '../controllers/auth_state_controller.dart';
import '../controllers/registration_controller.dart';
import '../repositories/auth_repository.dart';
import '../core/services/error_handler_service.dart';
import '../services/github_oauth_service.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<Logger>(() => Logger());
    Get.lazyPut<ErrorHandlerService>(() => ErrorHandlerService());
    Get.lazyPut<GitHubOAuthService>(
      () => GitHubOAuthService(
        logger: Get.find<Logger>(),
        errorHandler: Get.find<ErrorHandlerService>(),
      ),
    );

    // Repository
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(githubOAuthService: Get.find<GitHubOAuthService>()),
    );

    // Controllers

    Get.lazyPut<EmailAuthController>(
      () => EmailAuthController(
        authRepository: Get.find<AuthRepository>(),
        errorHandler: Get.find<ErrorHandlerService>(),
      ),
    );

    Get.lazyPut<AuthStateController>(
      () => AuthStateController(authRepository: Get.find<AuthRepository>()),
    );

    Get.lazyPut<AuthController>(
      () => AuthController(
        errorHandler: Get.find<ErrorHandlerService>(),
        authRepository: Get.find<AuthRepository>(),
        emailAuth: Get.find<EmailAuthController>(),
        authState: Get.find<AuthStateController>(),
        featureGateService: Get.find<FeatureGateService>(),
      ),
    );

    Get.lazyPut<RegistrationController>(
      () => RegistrationController(
        authRepository: Get.find(),
        errorHandler: Get.find(),
        authController: Get.find(),
      ),
    );
  }
}
