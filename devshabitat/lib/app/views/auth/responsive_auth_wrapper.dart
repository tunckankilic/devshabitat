import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/enhanced_auth_controller.dart';
import 'login_view.dart';

class ResponsiveAuthWrapper extends StatelessWidget {
  const ResponsiveAuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<EnhancedAuthController>();

    return Obx(() {
      switch (authController.authState) {
        case AuthState.authenticated:
          // TODO: Ana sayfaya yönlendir
          return const Scaffold(
            body: Center(
              child: Text('Ana Sayfa'),
            ),
          );
        case AuthState.unauthenticated:
          return const LoginView();
        case AuthState.loading:
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        case AuthState.error:
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Hata: ${authController.lastError}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Hata durumunu sıfırla
                    },
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            ),
          );
        default:
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
      }
    });
  }
}
