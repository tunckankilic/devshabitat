import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app/core/theme/dev_habitat_theme.dart';
import 'app/views/auth/responsive_auth_wrapper.dart';
import 'app/bindings/app_binding.dart';
import 'package:logger/logger.dart';
import 'app/core/services/error_handler_service.dart';
import 'app/repositories/enhanced_auth_repository.dart';
import 'app/controllers/enhanced_auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Servisleri başlat
  Get.put(Logger());
  Get.put(ErrorHandlerService());
  Get.put(EnhancedAuthRepository());
  Get.put(EnhancedAuthController(
    authRepository: Get.find<EnhancedAuthRepository>(),
    errorHandler: Get.find<ErrorHandlerService>(),
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X tasarım boyutu
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'DevHabitat',
          theme: DevHabitatTheme.lightTheme,
          darkTheme: DevHabitatTheme.darkTheme,
          themeMode: ThemeMode.dark,
          initialBinding: AppBinding(),
          home: const ResponsiveAuthWrapper(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
