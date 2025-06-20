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
import 'app/bindings/app_binding.dart';
import 'app/bindings/navigation_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X tasarım boyutları
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'DevsHabitat',
          theme: DevHabitatTheme.lightTheme,
          darkTheme: DevHabitatTheme.darkTheme,
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          initialBinding: AppBinding(),
          defaultTransition: Transition.fade,
          locale: const Locale('tr', 'TR'),
          fallbackLocale: const Locale('en', 'US'),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
