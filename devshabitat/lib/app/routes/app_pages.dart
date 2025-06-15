import 'package:get/get.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/auth/forgot_password/forgot_password_view.dart';
import '../views/main_wrapper.dart';
import '../views/messaging/chat_list_screen.dart';
import '../bindings/auth_binding.dart';
import '../bindings/navigation_binding.dart';
import '../bindings/home_binding.dart';
import '../bindings/messaging_binding.dart';
import '../middleware/auth_middleware.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.INITIAL;

  static final routes = [
    GetPage(
      name: Routes.INITIAL,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.MAIN,
      page: () => const MainWrapper(),
      bindings: [
        NavigationBinding(),
        HomeBinding(),
      ],
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.MESSAGES,
      page: () => const ChatListScreen(),
      binding: MessagingBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
