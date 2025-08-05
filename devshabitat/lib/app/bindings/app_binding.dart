import 'package:get/get.dart';
import '../core/services/error_handler_service.dart';

import '../services/developer_matching_service.dart';
import '../services/post_service.dart';
import '../services/lazy_loading_service.dart';
import '../services/asset_optimization_service.dart';
import '../services/audio_service.dart';
import '../services/image_upload_service.dart';
import '../services/community/resource_service.dart';
import '../services/file_storage_service.dart';
import '../services/deep_linking_service.dart';
import '../controllers/app_controller.dart';

import '../controllers/developer_matching_controller.dart';
import '../controllers/networking_controller.dart';
import '../services/responsive_performance_service.dart';
import '../core/services/form_validation_service.dart';
import '../controllers/file_upload_controller.dart';
import '../controllers/integration/notification_controller.dart';
import '../controllers/location/nearby_developers_controller.dart';
import '../controllers/network_controller.dart';
import 'message_binding.dart';
import '../services/network_analytics_service.dart';
import '../services/location/maps_service.dart';
import '../services/fcm_service.dart';
import '../services/progressive_onboarding_service.dart';

import '../controllers/progressive_onboarding_controller.dart';
import '../controllers/feature_gate_controller.dart';
import '../core/services/cache_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Önce senkron bağımlılıkları başlat
    initSynchronousDependencies();

    // Sonra asenkron bağımlılıkları başlat
    _initAsynchronousDependencies();
  }

  void initSynchronousDependencies() {
    // Sadece AppBinding'e özel servisleri yükle
    // Core servisler main.dart'ta yüklendi
    Get.put(DeepLinkingService());
    Get.put(NetworkAnalyticsService());

    // Location Services
    Get.put(MapsService());

    // Responsive Performance Service
    Get.put<ResponsivePerformanceService>(
      ResponsivePerformanceService(),
      permanent: true,
    );

    // Initialize responsive performance service
    final performanceService = Get.find<ResponsivePerformanceService>();
    performanceService.preCalculateCommonValues();

    // Form Validation Service
    Get.put<FormValidationService>(FormValidationService(), permanent: true);

    // Image Upload Service
    Get.put(ImageUploadService(errorHandler: Get.find()));

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

    // FCM Service
    Get.put(FCMService());

    // Progressive Onboarding Service (diğerleri main.dart'ta)
    Get.put(ProgressiveOnboardingService());
  }

  Future<void> _initAsynchronousDependencies() async {
    final errorHandler = Get.find<ErrorHandlerService>();

    try {
      // Cache Service initialization (SharedPreferences main.dart'ta)
      await Get.find<CacheService>().init();

      // Audio Service
      Get.put(AudioService());

      // App Controllers (Auth zaten main.dart'ta)
      Get.put(AppController(errorHandler: errorHandler));

      // Developer Matching Controller
      Get.put(DeveloperMatchingController());

      // Integration Notification Controller
      Get.put(IntegrationNotificationController());

      // Nearby Developers Controller
      Get.put(NearbyDevelopersController());

      // Network Controller
      Get.put(NetworkController());

      // Post Service
      Get.put(PostService(errorHandler: errorHandler));

      // Feature Gate & Progressive Onboarding Controllers (diğerleri main.dart'ta)
      Get.put(FeatureGateController());
      Get.put(ProgressiveOnboardingController());

      // Message Binding
      MessageBinding().dependencies();
    } catch (e) {
      errorHandler.handleError(
        'Bağımlılıklar başlatılırken hata oluştu: $e',
        ErrorHandlerService.AUTH_ERROR,
      );
    }
  }
}
