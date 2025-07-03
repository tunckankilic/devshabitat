import 'package:devshabitat/app/routes/app_pages.dart';
import 'package:get/get.dart';

class NavigationHelper {
  // Page transitions
  static void toLogin() => Get.toNamed(AppRoutes.LOGIN);

  // Go back
  static void back() => Get.back();
}
