import 'package:devshabitat/app/views/auth/register/register_view.dart';
import 'package:get/get.dart';
import '../views/auth/login_view.dart';
import '../views/auth/forgot_password/forgot_password_view.dart';
import '../views/main_wrapper.dart';
import '../views/notifications/notifications_view.dart';
import '../views/settings/settings_view.dart';
import '../views/settings/notification_settings_view.dart';
import '../views/search/search_view.dart';
import '../bindings/auth_binding.dart';
import '../bindings/navigation_binding.dart';
import '../bindings/home_binding.dart';
import '../bindings/settings_binding.dart';
import '../bindings/notification_binding.dart';
import '../bindings/search_binding.dart';
import '../middleware/auth_middleware.dart';
import '../bindings/video_binding.dart';
import '../views/video/video_call_view.dart';
import '../views/video/call_history_view.dart';
import '../views/video/incoming_call_view.dart';
import '../bindings/event_binding.dart';
import '../views/event/events_view.dart';
import '../views/event/event_create_view.dart';
import '../views/event/event_details_view.dart';
import '../views/event/event_discovery_view.dart';
import '../views/event/my_events_view.dart';
import '../views/community/community_discovery_view.dart';
import '../views/community/community_detail_view.dart';
import '../views/community/community_create_view.dart';
import '../views/community/my_communities_view.dart';
import '../views/community/community_manage_view.dart';
import '../bindings/community/community_discovery_binding.dart';
import '../bindings/community/community_detail_binding.dart';
import '../bindings/community/community_create_binding.dart';
import '../bindings/community/my_communities_binding.dart';
import '../bindings/community/community_manage_binding.dart';
import '../views/map/developer_map_view.dart';
import '../views/map/event_map_view.dart';
import '../views/map/location_settings_view.dart';
import '../bindings/location_binding.dart';
import '../views/community/community_event_view.dart';
import '../views/event/nearby_events_view.dart';
import '../bindings/event/event_detail_binding.dart';
import '../bindings/community/community_event_binding.dart';
import '../bindings/event/nearby_events_binding.dart';
import '../views/debug/memory_debug_view.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL =
      AppRoutes.login; // Bu artık dinamik olarak belirleniyor

  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => MainWrapper(),
      bindings: [
        NavigationBinding(),
        HomeBinding(),
      ],
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchView(),
      binding: SearchBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.videoCall,
      page: () => const VideoCallView(),
      binding: VideoBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.incomingCall,
      page: () => const IncomingCallView(),
      binding: VideoBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.callHistory,
      page: () => const CallHistoryView(),
      binding: VideoBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.events,
      page: () => EventsView(),
      binding: EventBinding(),
    ),
    GetPage(
      name: AppRoutes.eventCreate,
      page: () => const EventCreateView(),
      binding: EventBinding(),
    ),
    GetPage(
      name: AppRoutes.eventDetails,
      page: () => const EventDetailsView(),
      binding: EventBinding(),
    ),
    GetPage(
      name: AppRoutes.eventDiscovery,
      page: () => const EventDiscoveryView(),
      binding: EventBinding(),
    ),
    GetPage(
      name: AppRoutes.myEvents,
      page: () => const MyEventsView(),
      binding: EventBinding(),
    ),
    GetPage(
      name: AppRoutes.COMMUNITY_DISCOVERY,
      page: () => const CommunityDiscoveryView(),
      binding: CommunityDiscoveryBinding(),
    ),
    GetPage(
      name: AppRoutes.COMMUNITY_DETAIL,
      page: () => const CommunityDetailView(),
      binding: CommunityDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.COMMUNITY_CREATE,
      page: () => const CommunityCreateView(),
      binding: CommunityCreateBinding(),
    ),
    GetPage(
      name: AppRoutes.MY_COMMUNITIES,
      page: () => const MyCommunitiesView(),
      binding: MyCommunitiesBinding(),
    ),
    GetPage(
      name: AppRoutes.COMMUNITY_MANAGE,
      page: () => const CommunityManageView(),
      binding: CommunityManageBinding(),
    ),
    GetPage(
      name: AppRoutes.developerMap,
      page: () => const DeveloperMapView(),
      binding: LocationBinding(),
    ),
    GetPage(
      name: AppRoutes.eventMap,
      page: () => const EventMapView(),
      binding: LocationBinding(),
    ),
    GetPage(
      name: AppRoutes.locationSettings,
      page: () => const LocationSettingsView(),
      binding: LocationBinding(),
    ),
    GetPage(
      name: AppRoutes.EVENT_DETAIL,
      page: () => const EventDetailsView(),
      binding: EventDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.COMMUNITY_EVENT,
      page: () => const CommunityEventView(),
      binding: CommunityEventBinding(),
    ),
    GetPage(
      name: AppRoutes.NEARBY_EVENTS,
      page: () => const NearbyEventsView(),
      binding: NearbyEventsBinding(),
    ),
    GetPage(
      name: AppRoutes.notificationSettings,
      page: () => const NotificationSettingsView(),
      binding: NotificationBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.memoryDebug,
      page: () => const MemoryDebugView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MemoryDebugController());
      }),
    ),
  ];
}
