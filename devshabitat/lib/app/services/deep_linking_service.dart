import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class DeepLinkingService extends GetxService {
  final _appLinks = AppLinks();
  final _logger = Get.find<Logger>();

  // OAuth callback için stream controller
  final _oauthCallbackController =
      StreamController<Map<String, String>>.broadcast();
  Stream<Map<String, String>> get oauthCallbackStream =>
      _oauthCallbackController.stream;

  @override
  void onInit() {
    super.onInit();
    _initDeepLinkListener();
  }

  void _initDeepLinkListener() {
    _appLinks.uriLinkStream.listen((uri) {
      _logger.i('Deep link received: $uri');

      // OAuth callback'i kontrol et
      if (uri.path.contains('github-auth')) {
        final params = <String, String>{};
        uri.queryParameters.forEach((key, value) {
          params[key] = value;
        });
        _oauthCallbackController.add(params);
      }
    }, onError: (err) {
      _logger.e('Deep link error: $err');
    });
  }

  @override
  void onClose() {
    _oauthCallbackController.close();
    super.onClose();
  }
}
