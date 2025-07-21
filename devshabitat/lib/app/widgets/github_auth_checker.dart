import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../services/github_service.dart';

class GitHubAuthChecker extends StatelessWidget {
  final Widget child;
  final Widget? fallbackWidget;
  final String? customMessage;

  const GitHubAuthChecker({
    super.key,
    required this.child,
    this.fallbackWidget,
    this.customMessage,
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
        if (username == null) {
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
            customMessage ?? AppStrings.githubAuthRequired,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.githubAuthRequired,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // AuthController'da GitHub sign in metodunu çağır
              final authController = Get.find<AuthController>();
              // GitHub sign in metodunu çağır
              authController.signInWithGithub();
            },
            icon: const Icon(Icons.login),
            label: const Text(AppStrings.githubAuthRequired),
          ),
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
            AppStrings.error,
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
            child: const Text(AppStrings.tryAgain),
          ),
        ],
      ),
    );
  }
}
