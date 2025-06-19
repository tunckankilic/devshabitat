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
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Temel servisler
  final logger = Get.put(Logger());
  final errorHandler = Get.put(ErrorHandlerService());
  Get.put(NetworkController());

  // Uygulama servisleri
  Get.put(ProfileService());
  Get.put(GithubService());
  Get.put(ImageUploadService());
  Get.put(LazyLoadingService());
  Get.put(AssetOptimizationService());
  Get.put(FeedRepository());
  Get.put(NetworkAnalyticsService());
  Get.put(DiscoveryService());
  Get.put(MessagingService());
  Get.put(ThreadService());

  // OAuth servisleri
  Get.put(GitHubOAuthService(
    logger: logger,
    errorHandler: errorHandler,
  ));

  // Repository ve Controller'lar
  Get.put(AuthRepository(
    githubOAuthService: Get.find(),
  ));
  Get.put(AuthController(
    authRepository: Get.find(),
    errorHandler: Get.find(),
  ));
  Get.put(AppController(
    errorHandler: Get.find(),
  ));

  runApp(const MyApp());
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
