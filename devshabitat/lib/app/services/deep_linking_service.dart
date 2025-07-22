import 'package:get/get.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'dart:async';

class DeepLinkingService extends GetxService {
  static DeepLinkingService get to => Get.find();
  final Logger _logger = Logger();
  final AppLinks _appLinks = AppLinks();
  StreamSubscription? _linkStreamSubscription;

  // Deep link yapısı: devshabitat://route/id?params
  Future<void> init() async {
    try {
      // Yeni gelen linkleri dinle
      _linkStreamSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
        _handleDeepLink(uri.toString());
      }, onError: (err) {
        _logger.e('Deep link error: $err');
      });
    } on PlatformException catch (e) {
      _logger.e('Deep linking initialization error: $e');
    }
  }

  @override
  void onClose() {
    _linkStreamSubscription?.cancel();
    super.onClose();
  }

  static const _validRoutes = {
    'event': '/events',
    'community': '/communities',
    'message': '/messages',
    'connection': '/connections',
    'notification': '/notifications',
    'profile': '/profile',
    'auth': '/auth', // OAuth callback için
  };

  static const _maxIdLength = 100;
  static final _validIdPattern = RegExp(r'^[a-zA-Z0-9_-]+$');
  static final _validParamPattern = RegExp(r'^[a-zA-Z0-9_\-\.@]+$');

  bool _isValidId(String id) {
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

      // OAuth callback özel işlemi
      if (route == 'auth' && id == 'callback') {
        _handleOAuthCallback(params);
        return;
      }

      // Normal deep link işlemi
      if (id != null && !_isValidId(id)) {
        _logger.w('Invalid ID format: $id');
        return;
      }

      if (params.isNotEmpty && !_isValidParams(params)) {
        _logger.w('Invalid parameters format');
        return;
      }

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

  void _handleOAuthCallback(Map<String, String> params) {
    // OAuth callback'i GitHub OAuth Service'e ilet
    if (params.containsKey('code')) {
      _oauthCallbackController.add(params);
    }
  }

  // OAuth callback handler - GitHub OAuth Service tarafından kullanılacak
  final StreamController<Map<String, String>> _oauthCallbackController =
      StreamController<Map<String, String>>.broadcast();

  Stream<Map<String, String>> get oauthCallbackStream =>
      _oauthCallbackController.stream;

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
