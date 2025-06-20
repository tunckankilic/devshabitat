import 'package:devshabitat/app/views/auth/register/register_view.dart';
import 'package:get/get.dart';
import '../views/auth/login_view.dart';
import '../views/auth/forgot_password/forgot_password_view.dart';
import '../views/main_wrapper.dart';
import '../views/messaging/chat_list_screen.dart';
import '../views/messaging/chat_screen.dart';
import '../views/discovery/discovery_screen.dart';
import '../views/networking/my_network_screen.dart';
import '../views/home/widgets/comments_view.dart';
import '../views/home/widgets/item_detail_view.dart';
import '../views/profile/profile_view.dart';
import '../views/profile/edit_profile_view.dart';
import '../views/notifications/notifications_view.dart';
import '../views/settings/settings_view.dart';
import '../views/search/search_view.dart';
import '../bindings/auth_binding.dart';
import '../bindings/navigation_binding.dart';
import '../bindings/home_binding.dart';
import '../bindings/messaging_binding.dart';
import '../bindings/discovery_binding.dart';
import '../bindings/networking_binding.dart';
import '../bindings/profile_binding.dart';
import '../bindings/settings_binding.dart';
import '../bindings/search_binding.dart';
import '../middleware/auth_middleware.dart';
import '../views/messaging/message_view.dart';
import '../views/messaging/chat_view.dart';
import '../views/messaging/message_search_view.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.LOGIN;

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
      page: () => MainWrapper(),
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
      page: () => MessageView(),
      binding: MessagingBinding(),
    ),
    GetPage(
      name: Routes.CHAT,
      page: () => ChatView(),
      binding: MessagingBinding(),
    ),
    GetPage(
      name: Routes.MESSAGE_SEARCH,
      page: () => MessageSearchView(),
      binding: MessagingBinding(),
    ),
    GetPage(
      name: Routes.DISCOVERY,
      page: () => const DiscoveryScreen(),
      binding: DiscoveryBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.NETWORKING,
      page: () => const MyNetworkScreen(),
      binding: NetworkingBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.COMMENTS,
      page: () => const CommentsView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.ITEM_DETAIL,
      page: () => const ItemDetailView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.USER_PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.SEARCH,
      page: () => const SearchView(),
      binding: SearchBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
