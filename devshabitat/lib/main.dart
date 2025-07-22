import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:devshabitat/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'app/controllers/responsive_controller.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Ekran yönlendirmesini sadece portrait ve upside down olarak ayarla
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

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

    // Temel bağımlılıkları başlat
    final appBinding = AppBinding();
    appBinding.initSynchronousDependencies();

    runApp(const MyApp());
  } catch (e, stackTrace) {
    debugPrint('Initialization error: $e\n$stackTrace');
    runApp(const ErrorApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GetMaterialApp(
        title: AppStrings.appName,
        theme: DevHabitatTheme.lightTheme,
        darkTheme: DevHabitatTheme.darkTheme,
        initialRoute: _getInitialRoute(),
        getPages: AppPages.routes,
        initialBinding: AppBinding(),
        defaultTransition: Transition.fade,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child ?? const SizedBox(),
          );
        },
      ),
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
    return MaterialApp(
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
