import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:devshabitat/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/routes/app_pages.dart';
import 'app/core/theme/dev_habitat_theme.dart';
import 'app/bindings/app_binding.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app/services/background_message_handler_service.dart';
import 'app/services/deep_linking_service.dart';
import 'app/core/config/app_config.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // AppConfig servisini başlat
  final config = Get.put(AppConfig());
  await config.initialize();

  // Firebase'i başlat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Background message handler'ı kaydet
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Deep linking servisini başlat
  final deepLinkingService = Get.put(DeepLinkingService());
  await deepLinkingService.init();

  runApp(const MyApp());
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
    );
  }

  String _getInitialRoute() {
    // Firebase Auth'tan mevcut kullanıcıyı kontrol et
    final currentUser = FirebaseAuth.instance.currentUser;

    // Eğer kullanıcı giriş yapmışsa anasayfaya, yapmamışsa login sayfasına yönlendir
    if (currentUser != null) {
      return AppRoutes.home;
    } else {
      return AppRoutes.login;
    }
  }
}
