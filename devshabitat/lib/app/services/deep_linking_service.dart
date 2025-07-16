import 'package:get/get.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class DeepLinkingService extends GetxService {
  static DeepLinkingService get to => Get.find();
  final Logger _logger = Logger();
  final AppLinks _appLinks = AppLinks();

  // Deep link yapısı: devshabitat://route/id?params
  Future<void> init() async {
    try {
      // Initial link'i kontrol et
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink.toString());
      }

      // Yeni gelen linkleri dinle
      _appLinks.uriLinkStream.listen((Uri uri) {
        _handleDeepLink(uri.toString());
      }, onError: (err) {
        _logger.e('Deep link error: $err');
      });
    } on PlatformException catch (e) {
      _logger.e('Deep linking initialization error: $e');
    }
  }

  static const _validRoutes = {
    'event': '/events',
    'community': '/communities',
    'message': '/messages',
    'connection': '/connections',
    'notification': '/notifications',
    'profile': '/profile',
  };

  static const _maxIdLength = 100;
  static final _validIdPattern = RegExp(r'^[a-zA-Z0-9_-]+$');
  static final _validParamPattern = RegExp(r'^[a-zA-Z0-9_\-\.@]+$');

  bool _isValidId(String id) {
    // Sanitize input first
    final sanitizedId = _sanitizeInput(id);
    return sanitizedId.length <= _maxIdLength &&
        sanitizedId.isNotEmpty &&
        _validIdPattern.hasMatch(sanitizedId);
  }

  bool _isValidParams(Map<String, String> params) {
    return params.entries.every((entry) {
      final sanitizedKey = _sanitizeInput(entry.key);
      final sanitizedValue = _sanitizeInput(entry.value);

      return sanitizedKey.length <= 50 &&
          sanitizedValue.length <= 255 &&
          sanitizedKey.isNotEmpty &&
          sanitizedValue.isNotEmpty &&
          _validParamPattern.hasMatch(sanitizedKey) &&
          _validParamPattern.hasMatch(sanitizedValue);
    });
  }

  String _sanitizeInput(String input) {
    // Remove potentially dangerous characters
    return input
        .replaceAll(RegExp(r'[<>"();]'), '')
        .replaceAll("'", '')
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('{', '')
        .replaceAll('}', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .trim();
  }

  void _handleDeepLink(String link) {
    try {
      final uri = Uri.parse(link);
      if (uri.scheme != 'devshabitat') {
        _logger.w('Invalid scheme: ${uri.scheme}');
        return;
      }

      final pathSegments = uri.pathSegments;
      if (pathSegments.isEmpty) {
        _logger.w('Empty path segments');
        return;
      }

      final route = pathSegments[0];
      if (!_validRoutes.containsKey(route)) {
        _logger.w('Unknown route: $route');
        return;
      }

      String? id = pathSegments.length > 1 ? pathSegments[1] : null;
      final params = uri.queryParameters;

      // ID validation
      if (id != null && !_isValidId(id)) {
        _logger.w('Invalid ID format: $id');
        return;
      }

      // Parameters validation
      if (params.isNotEmpty && !_isValidParams(params)) {
        _logger.w('Invalid parameters format');
        return;
      }

      // Route handling
      final basePath = _validRoutes[route]!;
      if (id != null) {
        Get.toNamed('$basePath/$id', parameters: params);
      } else if (route == 'notification') {
        Get.toNamed(basePath, parameters: params);
      } else {
        _logger.w('Missing required ID for route: $route');
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
