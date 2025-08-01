import 'package:devshabitat/app/controllers/auth_controller.dart';
import 'package:devshabitat/app/routes/app_pages.dart';
import 'package:devshabitat/app/services/profile_completion_service.dart';
import 'package:devshabitat/app/services/feature_gate_service.dart';
import 'package:devshabitat/app/models/profile_completion_model.dart';
import 'package:devshabitat/app/models/enhanced_user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_state_controller.dart';

class AuthMiddleware extends GetMiddleware {
  final ProfileCompletionService _profileCompletionService =
      ProfileCompletionService.to;
  final FeatureGateService _featureGateService = FeatureGateService.to;

  @override
  RouteSettings? redirect(String? route) {
    try {
      // AuthController mevcut mu kontrol et
      if (!Get.isRegistered<AuthController>()) {
        return null; // Henüz yüklenmediyse bekleme
      }

      final authController = Get.find<AuthController>();

      if (authController.authState == AuthState.unauthenticated) {
        return RouteSettings(name: AppRoutes.login);
      }

      // Kimlik doğrulanmış kullanıcı için profil kontrolü
      if (authController.currentUser != null && route != null) {
        return _checkFeatureAccessAndRedirect(route, authController);
      }

      return null;
    } catch (e) {
      // Hata olursa login'e yönlendir
      return RouteSettings(name: AppRoutes.login);
    }
  }

  // Feature access kontrolü ve yönlendirme
  RouteSettings? _checkFeatureAccessAndRedirect(
      String route, AuthController authController) {
    // Feature-route mapping
    final routeFeatureMap = {
      '/home': 'browsing',
      '/profile': 'browsing',
      '/settings': 'browsing',
      '/notifications': 'browsing',
      '/messaging': 'messaging',
      '/chat': 'messaging',
      '/communities': 'community_join',
      '/events': 'networking',
      '/projects': 'project_sharing',
      '/portfolio': 'portfolio_showcase',
      '/video-call': 'video_calling',
    };

    final userProfile = authController.userProfile;
    if (userProfile.isEmpty) {
      return RouteSettings(name: '/register/steps');
    }

    try {
      // Create enhanced user model
      final enhancedUser = EnhancedUserModel.fromJson(userProfile);

      // Get required feature for this route
      final requiredFeature = routeFeatureMap[route];

      if (requiredFeature != null) {
        // Check if user can access this feature
        if (!_featureGateService.canAccess(requiredFeature, enhancedUser)) {
          final completionStatus =
              _profileCompletionService.calculateCompletionLevel(enhancedUser);

          // If completion level is too low, redirect to quick setup
          if (completionStatus.level == ProfileCompletionLevel.minimal &&
              completionStatus.percentage < 15.0) {
            return RouteSettings(name: '/onboarding/quick-setup', arguments: {
              'targetFeature': requiredFeature,
              'targetRoute': route,
            });
          }

          // For higher level features, show upgrade prompt (handled by pages)
          // Just allow navigation and let pages handle the feature gate
        }
      }

      return null;
    } catch (e) {
      // If there's an error with user data, allow basic navigation
      return null;
    }
  }
}
