import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Simple analytics service abstraction
/// Can be easily extended with Firebase Analytics, Mixpanel, etc.
class AnalyticsService extends GetxService {
  static AnalyticsService get to => Get.find();

  /// Log custom event with parameters
  void logEvent(String eventName, Map<String, dynamic> parameters) {
    if (kDebugMode) {
      debugPrint('Analytics: $eventName - $parameters');
    }

    // In production, integrate with your preferred analytics provider:
    // Firebase: FirebaseAnalytics.instance.logEvent(name: eventName, parameters: parameters);
    // Mixpanel: Mixpanel.track(eventName, parameters);
    // Custom API: await analyticsApi.send(eventName, parameters);
  }

  /// Track user property
  void setUserProperty(String propertyName, String value) {
    if (kDebugMode) {
      debugPrint('User Property: $propertyName = $value');
    }
  }

  /// Track screen view
  void trackScreenView(String screenName) {
    logEvent('screen_view', {'screen_name': screenName});
  }
}
