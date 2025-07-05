part of 'app_pages.dart';

abstract class AppRoutes {
  // Auth routes
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  // Main routes
  static const home = '/home';
  static const profile = '/profile';
  static const settings = '/settings';
  static const notifications = '/notifications';
  static const notificationSettings = '/notification-settings';
  static const search = '/search';

  // Event routes
  static const events = '/events';
  static const eventCreate = '/event-create';
  static const eventDetails = '/event-details';
  static const eventDiscovery = '/event-discovery';
  static const myEvents = '/my-events';
  static const EVENT_DETAIL = '/event-detail';
  static const NEARBY_EVENTS = '/nearby-events';

  // Video routes
  static const videoCall = '/video-call';
  static const incomingCall = '/incoming-call';
  static const callHistory = '/call-history';

  // Community routes
  static const COMMUNITY_DISCOVERY = '/community-discovery';
  static const COMMUNITY_DETAIL = '/community-detail';
  static const COMMUNITY_CREATE = '/community-create';
  static const MY_COMMUNITIES = '/my-communities';
  static const COMMUNITY_MANAGE = '/community-manage';
  static const COMMUNITY_EVENT = '/community-event';

  // Map routes
  static const developerMap = '/developer-map';
  static const eventMap = '/event-map';
  static const locationSettings = '/location-settings';
  static const locationHistory = '/location-history';

  // Chat routes
  static const CHAT = '/chat';
  static const NEW_CHAT = '/new-chat';
}
