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
import '../services/audio_service.dart';
import '../services/image_upload_service.dart';
import '../services/storage_service.dart';
import '../services/community/resource_service.dart';
import '../services/file_storage_service.dart';
import '../services/deep_linking_service.dart';
import '../controllers/app_controller.dart';
import '../controllers/responsive_controller.dart';
import '../controllers/auth_state_controller.dart';
import '../controllers/email_auth_controller.dart';
import '../controllers/developer_matching_controller.dart';
import '../controllers/networking_controller.dart';
import '../services/responsive_performance_service.dart';
import '../controllers/enhanced_form_validation_controller.dart';
import '../controllers/file_upload_controller.dart';
import '../controllers/integration/notification_controller.dart';
import '../controllers/location/nearby_developers_controller.dart';
import '../controllers/network_controller.dart';
import 'message_binding.dart';
import '../services/network_analytics_service.dart';
import '../services/location/maps_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    final errorHandler = Get.put(ErrorHandlerService());
    Get.put(MemoryManagerService());
    Get.put(ApiOptimizationService());
    Get.put(DeepLinkingService());
    Get.put(NetworkAnalyticsService());

    // Location Services
    Get.put(MapsService());

    // Storage Service
    Get.put(StorageService());

    // Responsive system (immediately needed for theme)
    Get.put<ResponsiveController>(ResponsiveController(), permanent: true);
    Get.put<ResponsivePerformanceService>(ResponsivePerformanceService(),
        permanent: true);

    // Initialize responsive performance service
    final performanceService = Get.find<ResponsivePerformanceService>();
    performanceService.preCalculateCommonValues();

    // Enhanced Form Validation Controller
    Get.put<EnhancedFormValidationController>(
        EnhancedFormValidationController(),
        permanent: true);

    // Image Upload Service
    Get.put(ImageUploadService(errorHandler: errorHandler));

    // Developer Matching Service
    Get.put(DeveloperMatchingService());

    // Other Services
    Get.put(LazyLoadingService());
    Get.put(AssetOptimizationService());

    // Community Services
    Get.put(ResourceService());
    Get.put(FileStorageService());

    // File Upload Controller
    Get.put(FileUploadController());

    // Networking Controller
    Get.put(NetworkingController());
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

      // Audio Service
      Get.put(AudioService());

      // Auth Related Services
      Get.lazyPut<GitHubOAuthService>(
        () => GitHubOAuthService(
          logger: Get.find(),
          errorHandler: Get.find(),
          auth: FirebaseAuth.instance,
        ),
      );

      final authRepository = Get.put(AuthRepository(
        githubOAuthService: Get.find(),
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

      // Developer Matching Controller
      Get.put(DeveloperMatchingController());

      // Integration Notification Controller
      Get.put(IntegrationNotificationController());

      // Nearby Developers Controller
      Get.put(NearbyDevelopersController());

      // Network Controller
      Get.put(NetworkController());

      // Post Service
      Get.put(PostService(
        errorHandler: errorHandler,
      ));

      // Message Binding
      MessageBinding().dependencies();
    } catch (e) {
      errorHandler.handleError('Bağımlılıklar başlatılırken hata oluştu: $e',
          ErrorHandlerService.AUTH_ERROR);
    }
  }
}
