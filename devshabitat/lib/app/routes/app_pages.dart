import 'package:devshabitat/app/views/auth/login_view.dart';
import 'package:get/get.dart';
import '../views/auth/forgot_password/forgot_password_view.dart';
import '../bindings/auth_binding.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: '/login',
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: '/forgot-password',
      page: () => ForgotPasswordView(),
      binding: AuthBinding(),
    ),
  ];
}
