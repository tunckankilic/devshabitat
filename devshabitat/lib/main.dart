import 'package:devshabitat/app/firebase/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app/routes/app_pages.dart';
import 'app/core/theme/dev_habitat_theme.dart';
import 'app/bindings/app_binding.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app/services/background_message_handler_service.dart';
import 'app/services/deep_linking_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
