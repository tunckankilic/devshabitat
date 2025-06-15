import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app/core/services/error_handler_service.dart';
import 'app/repositories/enhanced_auth_repository.dart';
import 'app/controllers/enhanced_auth_controller.dart';
import 'app/services/profile_service.dart';
import 'app/services/github_service.dart';
import 'app/services/image_upload_service.dart';
import 'app/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Servisleri başlat
  Get.put(Logger());
  Get.put(ErrorHandlerService());
  Get.put(ProfileService());
  Get.put(GithubService());
  Get.put(ImageUploadService());
  Get.put(EnhancedAuthRepository());
  Get.put(EnhancedAuthController(
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
          title: 'DevsHabitat',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          initialRoute: AppRoutes.initial,
          defaultTransition: Transition.fade,
        );
      },
    );
  }
}
