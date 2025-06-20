import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app/core/services/error_handler_service.dart';
import 'app/services/profile_service.dart';
import 'app/services/github_service.dart';
import 'app/services/github_oauth_service.dart';
import 'app/services/image_upload_service.dart';
import 'app/services/lazy_loading_service.dart';
import 'app/services/asset_optimization_service.dart';
import 'app/services/feed_repository.dart';
import 'app/services/network_analytics_service.dart';
import 'app/services/discovery_service.dart';
import 'app/services/messaging_service.dart';
import 'app/services/thread_service.dart';
import 'app/repositories/auth_repository.dart';
import 'app/controllers/auth_controller.dart';
import 'app/controllers/app_controller.dart';
import 'app/controllers/network_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/core/theme/dev_habitat_theme.dart';
import 'app/constants/app_strings.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize services
  final logger = Logger();
  Get.put(logger);

  final errorHandler = ErrorHandlerService();
  Get.put(errorHandler);

  final profileService = ProfileService();
  Get.put(profileService);

  final githubService = GithubService();
  Get.put(githubService);

  final githubOAuthService = GitHubOAuthService(
    logger: logger,
    errorHandler: errorHandler,
  );
  Get.put(githubOAuthService);

  final imageUploadService = ImageUploadService();
  Get.put(imageUploadService);

  final lazyLoadingService = LazyLoadingService();
  Get.put(lazyLoadingService);

  final assetOptimizationService = AssetOptimizationService();
  Get.put(assetOptimizationService);

  final feedRepository = FeedRepository();
  Get.put(feedRepository);

  final networkAnalyticsService = NetworkAnalyticsService();
  Get.put(networkAnalyticsService);

  final discoveryService = DiscoveryService();
  Get.put(discoveryService);

  final messagingService = MessagingService();
  Get.put(messagingService);

  final threadService = ThreadService();
  Get.put(threadService);

  final authRepository = AuthRepository(
    githubOAuthService: githubOAuthService,
  );
  Get.put(authRepository);

  final authController = AuthController(
    authRepository: authRepository,
    errorHandler: errorHandler,
  );
  Get.put(authController);

  final appController = AppController(
    errorHandler: errorHandler,
  );
  Get.put(appController);

  final networkController = NetworkController();
  Get.put(networkController);

  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: AppStrings.appName,
          theme: DevHabitatTheme.lightTheme,
          darkTheme: DevHabitatTheme.darkTheme,
          themeMode: ThemeMode.system,
          locale: const Locale('en', 'US'),
          fallbackLocale: const Locale('en', 'US'),
          getPages: AppPages.routes,
          initialRoute: Routes.INITIAL,
          debugShowCheckedModeBanner: false,
        );
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'DevsHabitat',
          theme: DevHabitatTheme.lightTheme,
          darkTheme: DevHabitatTheme.darkTheme,
          themeMode: ThemeMode.system,
          initialRoute: Routes.LOGIN,
          getPages: AppPages.routes,
          defaultTransition: Transition.fade,
          debugShowCheckedModeBanner: false,
          locale: const Locale('tr', 'TR'),
          fallbackLocale: const Locale('tr', 'TR'),
          builder: (context, child) {
            return ScrollConfiguration(
              behavior: ScrollBehavior().copyWith(
                physics: const BouncingScrollPhysics(),
                scrollbars: false,
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}
