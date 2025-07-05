import 'package:get/get.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class DeepLinkingService extends GetxService {
  static DeepLinkingService get to => Get.find();
  final Logger _logger = Logger();

  // Deep link yapısı: devshabitat://route/id?params
  Future<void> init() async {
    try {
      // Initial link'i kontrol et
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }

      // Yeni gelen linkleri dinle
      uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          _handleDeepLink(uri.toString());
        }
      }, onError: (err) {
        _logger.e('Deep link error: $err');
      });
    } on PlatformException catch (e) {
      _logger.e('Deep linking initialization error: $e');
    }
  }

  void _handleDeepLink(String link) {
    try {
      final uri = Uri.parse(link);
      if (uri.scheme != 'devshabitat') return;

      final pathSegments = uri.pathSegments;
      if (pathSegments.isEmpty) return;

      final route = pathSegments[0];
      String? id = pathSegments.length > 1 ? pathSegments[1] : null;
      final params = uri.queryParameters;

      switch (route) {
        case 'event':
          if (id != null) {
            Get.toNamed('/events/$id', parameters: params);
          }
          break;

        case 'community':
          if (id != null) {
            Get.toNamed('/communities/$id', parameters: params);
          }
          break;

        case 'message':
          if (id != null) {
            Get.toNamed('/messages/$id', parameters: params);
          }
          break;

        case 'connection':
          if (id != null) {
            Get.toNamed('/connections/$id', parameters: params);
          }
          break;

        case 'notification':
          Get.toNamed('/notifications', parameters: params);
          break;

        case 'profile':
          if (id != null) {
            Get.toNamed('/profile/$id', parameters: params);
          }
          break;

        default:
          _logger.w('Unknown deep link route: $route');
      }
    } catch (e) {
      _logger.e('Error handling deep link: $e');
    }
  }

  // Deep link oluşturma yardımcı metodları
  String createEventDeepLink(String eventId, {Map<String, String>? params}) {
    return _createDeepLink('event', eventId, params);
  }

  String createCommunityDeepLink(String communityId,
      {Map<String, String>? params}) {
    return _createDeepLink('community', communityId, params);
  }

  String createMessageDeepLink(String messageId,
      {Map<String, String>? params}) {
    return _createDeepLink('message', messageId, params);
  }

  String createConnectionDeepLink(String connectionId,
      {Map<String, String>? params}) {
    return _createDeepLink('connection', connectionId, params);
  }

  String createProfileDeepLink(String userId, {Map<String, String>? params}) {
    return _createDeepLink('profile', userId, params);
  }

  String _createDeepLink(String route, String id,
      [Map<String, String>? params]) {
    final uri = Uri(
      scheme: 'devshabitat',
      path: '$route/$id',
      queryParameters: params,
    );
    return uri.toString();
  }
}
