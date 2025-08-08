import 'dart:async';

import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:devshabitat/app/core/services/api_optimization_service.dart';
import 'package:devshabitat/app/core/services/error_handler_service.dart';
import 'package:devshabitat/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';
import 'app/core/services/logger_service.dart';
import 'app/routes/app_pages.dart';
import 'app/core/theme/dev_habitat_theme.dart';
import 'app/bindings/app_binding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app/controllers/responsive_controller.dart';
import 'app/services/github_oauth_service.dart';
import 'app/controllers/auth_state_controller.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'app/services/notification_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'app/services/user_service.dart';
import 'app/services/profile_completion_service.dart';
import 'app/services/feature_gate_service.dart';
import 'app/services/auth_migration_service.dart';
import 'app/core/services/cache_service.dart';
import 'app/services/analytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kritik servisleri başlat
  await _initializeCriticalServices();

  // Firebase'i arka planda başlat
  unawaited(_initializeFirebaseAsync());

  runApp(const MyApp());
}

Future<void> _initializeCriticalServices() async {
  // Sadece başlangıç için kritik olanlar
  final logger = Logger();
  Get.put(logger, permanent: true);
  Get.put(LoggerService(logger: logger), permanent: true);
  Get.put(ErrorHandlerService(), permanent: true);
  Get.put(CacheService(), permanent: true);

  // SharedPreferences - kritik
  final prefs = await SharedPreferences.getInstance();
  Get.put(prefs, permanent: true);

  // Auth - kritik
  Get.put(AuthStateController(authRepository: Get.find()), permanent: true);
}

Future<void> _initializeFirebaseAsync() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (kIsWeb) {
      await FirebaseAuth.instance.setPersistence(Persistence.SESSION);
    }

    // Firebase başlatıldıktan sonra diğer servisleri başlat
    _initializePostFirebaseServices();
  } catch (e) {
    print('Firebase initialization error: $e');
  }
}

void _initializePostFirebaseServices() {
  // Auth ve güvenlik servisleri
  Get.put(AuthMigrationService(), permanent: true);
  Get.put(
    GitHubOAuthService(
      logger: Get.find<LoggerService>(),
      errorHandler: Get.find(),
    ),
    permanent: true,
  );

  // Diğer servisler lazy olarak yüklenecek
  _initializeNonCriticalServices();
}

void _initializeNonCriticalServices() {
  // UI ve responsive servisleri
  Get.lazyPut(() => ResponsiveController(), fenix: true);
  Get.lazyPut(() => ApiOptimizationService(), fenix: true);
  Get.lazyPut(() => AnalyticsService(), fenix: true);

  // User ve profil servisleri
  Get.lazyPut(() => UserService(), fenix: true);
  Get.lazyPut(() => ProfileCompletionService(), fenix: true);
  Get.lazyPut(
    () => FeatureGateService(
      profileCompletionService: Get.find<ProfileCompletionService>(),
      userService: Get.find<UserService>(),
    ),
    fenix: true,
  );

  // GitHub servisleri
  Get.lazyPut(() => GithubService(), fenix: true);
  Get.lazyPut(
    () => GitHubContentSharingService(
      logger: Get.find(),
      errorHandler: Get.find(),
    ),
    fenix: true,
  );

  // Messaging ve feed servisleri
  Get.lazyPut(() => NotificationService(Get.find()), fenix: true);
  Get.lazyPut(
    () => MessagingService(logger: Get.find(), errorHandler: Get.find()),
    fenix: true,
  );
  Get.lazyPut(() => NavigationService(), fenix: true);
  Get.lazyPut(() => FeedService(errorHandler: Get.find()), fenix: true);
  Get.lazyPut(() => ConnectionService(), fenix: true);
  Get.lazyPut(() => FeedRepository(), fenix: true);

  // Controller'lar
  Get.lazyPut(() => HomeController(), fenix: true);
  Get.lazyPut(() => DiscoveryController(), fenix: true);
  Get.lazyPut(
    () => MessagingController(
      messagingService: Get.find(),
      authService: Get.find(),
      errorHandler: Get.find(),
    ),
    fenix: true,
  );
  Get.lazyPut(() => ProfileController(), fenix: true);
  Get.lazyPut(() => NavigationController(Get.find()), fenix: true);
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
    return GetMaterialApp(
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
