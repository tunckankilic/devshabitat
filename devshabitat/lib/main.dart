import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:devshabitat/app/controllers/email_auth_controller.dart';
import 'package:devshabitat/app/core/services/api_optimization_service.dart';
import 'package:devshabitat/app/core/services/error_handler_service.dart';
import 'package:devshabitat/app/core/services/memory_manager_service.dart';
import 'package:devshabitat/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';
import 'app/routes/app_pages.dart';
import 'app/core/theme/dev_habitat_theme.dart';
import 'app/bindings/app_binding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app/controllers/responsive_controller.dart';
import 'app/services/github_oauth_service.dart';
import 'app/repositories/auth_repository.dart';
import 'app/controllers/auth_controller.dart';
import 'app/controllers/auth_state_controller.dart';
import 'app/services/storage_service.dart';
import 'app/controllers/home_controller.dart';
import 'app/controllers/discovery_controller.dart';
import 'app/controllers/messaging_controller.dart';
import 'app/controllers/profile_controller.dart';
import 'app/controllers/navigation_controller.dart';
import 'app/services/messaging_service.dart';
import 'app/services/navigation_service.dart';
import 'app/services/feed_service.dart';
import 'app/services/connection_service.dart';
import 'app/repositories/feed_repository.dart';
import 'app/services/github_service.dart';
import 'app/services/github/content_sharing_service.dart';
import 'app/controllers/github_content_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/services/notification_service.dart';
import 'app/controllers/message/message_list_controller.dart';
import 'app/controllers/message/message_search_controller.dart';
import 'app/controllers/message/message_interaction_controller.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'app/services/user_service.dart';
import 'app/services/profile_completion_service.dart';
import 'app/services/feature_gate_service.dart';
import 'app/services/auth_migration_service.dart';
import 'app/core/services/cache_service.dart';
import 'app/services/analytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i initialize et
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Web platformunda Firebase Auth persistence ayarını yap
  if (kIsWeb) {
    try {
      await FirebaseAuth.instance.setPersistence(Persistence.SESSION);
      print('Web Firebase Auth persistence set to SESSION');

      // Web için redirect sonucunu dinle
      FirebaseAuth.instance
          .getRedirectResult()
          .then((result) {
            if (result.user != null) {
              print('Web redirect login successful: ${result.user?.email}');
            } else if (result.credential != null) {
              print('Web redirect login with credential');
            }
          })
          .catchError((error) {
            print('Web redirect login error: $error');
          });
    } catch (e) {
      print('Error setting web persistence: $e');
    }
  }

  // Sadece temel servisleri yükle, auth'u sonra
  await initBasicDependencies();

  runApp(MyApp());
}

Future<void> initBasicDependencies() async {
  // Sadece kritik servisleri yükle, AppBinding'den çakışmaları kaldır
  Get.put(Logger(), permanent: true);
  Get.put(MemoryManagerService(), permanent: true);
  Get.put(ResponsiveController(), permanent: true);
  Get.put(StorageService(), permanent: true);
  Get.put(ErrorHandlerService(), permanent: true);
  Get.put(ApiOptimizationService(), permanent: true);
  Get.put(CacheService(), permanent: true);
  Get.put(AnalyticsService(), permanent: true);

  // User Service ve Profile Completion Service
  Get.put(UserService(), permanent: true);
  Get.put(ProfileCompletionService(), permanent: true);
  Get.put(
    FeatureGateService(
      profileCompletionService: Get.find<ProfileCompletionService>(),
      userService: Get.find<UserService>(),
    ),
    permanent: true,
  );

  // Auth Migration Service
  Get.put(AuthMigrationService(), permanent: true);

  // GitHub OAuth Service
  Get.put(
    GitHubOAuthService(logger: Get.find(), errorHandler: Get.find()),
    permanent: true,
  );

  // AuthRepository
  Get.put(AuthRepository(githubOAuthService: Get.find()), permanent: true);

  // GitHub Services
  Get.put(GithubService(), permanent: true);
  Get.put(
    GitHubContentSharingService(logger: Get.find(), errorHandler: Get.find()),
    permanent: true,
  );

  // GitHub Controllers
  Get.put(
    GitHubContentController(
      contentService: Get.find(),
      logger: Get.find(),
      errorHandler: Get.find(),
    ),
    permanent: true,
  );

  // Auth Controllers
  Get.put(
    EmailAuthController(authRepository: Get.find(), errorHandler: Get.find()),
    permanent: true,
  );

  Get.put(AuthStateController(authRepository: Get.find()), permanent: true);

  Get.put(
    AuthController(
      authRepository: Get.find(),
      errorHandler: Get.find(),
      emailAuth: Get.find(),
      authState: Get.find(),
      featureGateService: Get.find(),
    ),
    permanent: true,
  );

  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  Get.put(prefs, permanent: true);

  // Messaging Service
  Get.put(NotificationService(prefs), permanent: true);
  Get.put(
    MessagingService(
      logger: Get.find<Logger>(),
      errorHandler: Get.find<ErrorHandlerService>(),
    ),
    permanent: true,
  );
  Get.put(NavigationService(), permanent: true);
  Get.put(
    FeedService(errorHandler: Get.find<ErrorHandlerService>()),
    permanent: true,
  );
  Get.put(ConnectionService(), permanent: true);
  Get.put(FeedRepository(), permanent: true);

  // Ana sayfa controller'ları
  Get.put(HomeController(), permanent: true);
  Get.put(DiscoveryController(), permanent: true);
  Get.put(
    MessagingController(
      messagingService: Get.find<MessagingService>(),
      authService: Get.find<AuthRepository>(),
      errorHandler: Get.find<ErrorHandlerService>(),
    ),
    permanent: true,
  );
  Get.put(
    MessageListController(
      messagingService: Get.find<MessagingService>(),
      errorHandler: Get.find<ErrorHandlerService>(),
    ),
    permanent: true,
  );
  Get.put(
    MessageSearchController(
      messagingService: Get.find<MessagingService>(),
      errorHandler: Get.find<ErrorHandlerService>(),
    ),
    permanent: true,
  );
  Get.put(
    MessageInteractionController(
      messagingService: Get.find<MessagingService>(),
      errorHandler: Get.find<ErrorHandlerService>(),
    ),
    permanent: true,
  );
  Get.put(ProfileController(), permanent: true);
  Get.put(NavigationController(Get.find<NavigationService>()), permanent: true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      theme: DevHabitatTheme.lightTheme,
      darkTheme: DevHabitatTheme.darkTheme,
      initialRoute: _getInitialRoute(),
      getPages: AppPages.routes,
      initialBinding: AppBinding(),
      defaultTransition: Transition.fade,
      debugShowCheckedModeBanner: false,
      navigatorKey: Get.key,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child ?? const SizedBox(),
        );
      },
      onInit: () {
        Get.put(Get.find<AuthStateController>(), permanent: true);
      },
    );
  }

  String _getInitialRoute() {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null ? AppRoutes.home : AppRoutes.login;
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Uygulama başlatılırken bir hata oluştu.\nLütfen tekrar deneyin.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
