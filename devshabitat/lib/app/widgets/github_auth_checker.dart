import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../services/github_service.dart';

class GitHubAuthChecker extends StatelessWidget {
  final Widget child;
  final Widget? fallbackWidget;
  final String? customMessage;
  final bool showConnectButton;

  const GitHubAuthChecker({
    super.key,
    required this.child,
    this.fallbackWidget,
    this.customMessage,
    this.showConnectButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: Get.find<GithubService>().getCurrentUsername(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(context, AppStrings.errorGeneric);
        }

        final username = snapshot.data;
        if (username == null || username.isEmpty) {
          return fallbackWidget ?? _buildAuthRequiredWidget(context);
        }

        return child;
      },
    );
  }

  Widget _buildAuthRequiredWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.code,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            customMessage ?? 'GitHub Hesabı Gerekli',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Bu özelliği kullanmak için GitHub hesabınızın bağlı olması gerekiyor.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (showConnectButton) ...[
            ElevatedButton.icon(
              onPressed: () {
                // Profil sayfasına yönlendir
                Get.toNamed('/profile');
              },
              icon: const Icon(Icons.settings),
              label: const Text('Profil Ayarlarına Git'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                // AuthController'da GitHub sign in metodunu çağır
                final authController = Get.find<AuthController>();
                authController.signInWithGithub();
              },
              child: const Text('GitHub ile Bağlan'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Bir Hata Oluştu',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Sayfayı yenile
              Get.forceAppUpdate();
            },
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }
}
