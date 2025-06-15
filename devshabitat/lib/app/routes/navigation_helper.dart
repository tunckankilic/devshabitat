import 'package:get/get.dart';
import 'app_routes.dart';

class NavigationHelper {
  // Sayfa geçişleri
  static void toLogin() => Get.toNamed(AppRoutes.login);

  // Geri dönüş
  static void back() => Get.back();
}
