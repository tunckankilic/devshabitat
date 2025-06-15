import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherService extends GetxService {
  Future<void> launchUrl(String url, {required LaunchMode mode}) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('URL açılamadı: $url');
      }
    } catch (e) {
      throw Exception('URL açılırken bir hata oluştu: $e');
    }
  }
}
