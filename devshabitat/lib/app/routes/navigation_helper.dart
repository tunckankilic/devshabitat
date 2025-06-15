import 'package:devshabitat/app/routes/app_pages.dart';
import 'package:get/get.dart';

class NavigationHelper {
  // Sayfa geçişleri
  static void toLogin() => Get.toNamed(Routes.LOGIN);

  // Geri dönüş
  static void back() => Get.back();
}
