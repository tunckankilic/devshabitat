import 'package:devshabitat/app/controllers/auth_controller.dart';
import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/error_handler_service.dart';
import '../services/github_oauth_service.dart';
import '../services/post_service.dart';
import '../services/lazy_loading_service.dart';
import '../services/asset_optimization_service.dart';
import '../services/notification_service.dart';
import '../controllers/app_controller.dart';
import '../controllers/responsive_controller.dart';
import '../controllers/auth_state_controller.dart';
import '../controllers/email_auth_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() async {
    // Core Services
    final logger = Get.put(Logger());
    final errorHandler = Get.put(ErrorHandlerService());

    // SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(prefs);

    // Notification Service
    final notificationService = Get.put(NotificationService(prefs));
    await notificationService.init();

    // Auth Related Services
    final githubOAuthService = Get.put(GitHubOAuthService(
      logger: logger,
      errorHandler: errorHandler,
    ));

    final authRepository = Get.put(AuthRepository(
      githubOAuthService: githubOAuthService,
    ));

    // Auth Related Controllers
    final authStateController = Get.put(AuthStateController(
      authRepository: authRepository,
    ));

    final emailAuthController = Get.put(EmailAuthController(
      authRepository: authRepository,
      errorHandler: errorHandler,
    ));

    Get.put(AuthController(
      authRepository: authRepository,
      errorHandler: errorHandler,
      emailAuth: emailAuthController,
      authState: authStateController,
    ));

    // App Controllers
    Get.put(AppController(
      errorHandler: errorHandler,
    ));
    Get.put(ResponsiveController());

    // Other Services
    Get.put(PostService(
      errorHandler: errorHandler,
    ));
    Get.put(LazyLoadingService());
    Get.put(AssetOptimizationService());
  }
}
