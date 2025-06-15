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
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

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
    return GetMaterialApp(
      title: 'DevsHabitat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.initial,
      defaultTransition: Transition.fade,
    );
  }
}
