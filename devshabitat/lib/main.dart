import 'package:devshabitat/app/controllers/auth_controller.dart';
import 'package:devshabitat/app/repositories/auth_repository.dart';
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
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Servisleri başlat
  final logger = Get.put(Logger());
  final errorHandler = Get.put(ErrorHandlerService());
  Get.put(ProfileService());
  Get.put(GithubService());
  Get.put(ImageUploadService());
  Get.put(GitHubOAuthService(
    logger: logger,
    errorHandler: errorHandler,
  ));
  Get.put(AuthRepository(
    githubOAuthService: Get.find(),
  ));
  Get.put(AuthController(
    authRepository: Get.find(),
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
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          initialRoute: Routes.MAIN,
          getPages: AppPages.routes,
          defaultTransition: Transition.fade,
        );
      },
    );
  }
}
