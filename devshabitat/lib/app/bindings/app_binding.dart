import 'package:devshabitat/app/controllers/auth_controller.dart';
import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/error_handler_service.dart';
import '../core/services/memory_manager_service.dart';
import '../core/services/api_optimization_service.dart';
import '../services/github_oauth_service.dart';
import '../services/github_service.dart';
import '../services/developer_matching_service.dart';
import '../services/post_service.dart';
import '../services/lazy_loading_service.dart';
import '../services/asset_optimization_service.dart';
import '../services/notification_service.dart';
import '../services/image_upload_service.dart';
import '../controllers/app_controller.dart';
import '../controllers/responsive_controller.dart';
import '../controllers/auth_state_controller.dart';
import '../controllers/email_auth_controller.dart';
import '../services/responsive_performance_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Önce senkron bağımlılıkları başlat
    initSynchronousDependencies();

    // Sonra asenkron bağımlılıkları başlat
    _initAsynchronousDependencies();
  }

  void initSynchronousDependencies() {
    // Core Services
    final logger = Get.put(Logger());
    final errorHandler = Get.put(ErrorHandlerService());
    Get.put(MemoryManagerService());
    Get.put(ApiOptimizationService());

    // Responsive system (immediately needed for theme)
    Get.put<ResponsiveController>(ResponsiveController(), permanent: true);
    Get.put<ResponsivePerformanceService>(ResponsivePerformanceService(),
        permanent: true);

    // Initialize responsive performance service
    final performanceService = Get.find<ResponsivePerformanceService>();
    performanceService.preCalculateCommonValues();

    // Image Upload Service
    Get.put(ImageUploadService(errorHandler: errorHandler));

    // Developer Matching Service
    Get.put(DeveloperMatchingService());

    // Other Services
    Get.put(LazyLoadingService());
    Get.put(AssetOptimizationService());
  }

  Future<void> _initAsynchronousDependencies() async {
    final errorHandler = Get.find<ErrorHandlerService>();
    final logger = Get.find<Logger>();

    try {
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

      // GitHub Services (after AuthRepository)
      Get.put(GithubService());

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

      // Post Service
      Get.put(PostService(
        errorHandler: errorHandler,
      ));
    } catch (e) {
      errorHandler.handleError('Bağımlılıklar başlatılırken hata oluştu: $e',
          ErrorHandlerService.AUTH_ERROR);
    }
  }
}
