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
  static const search = '/search';

  // Event routes
  static const events = '/events';
  static const eventCreate = '/events/create';
  static const eventDetails = '/events/details';
  static const eventDiscovery = '/events/discovery';
  static const myEvents = '/events/my-events';

  // Video routes
  static const videoCall = '/video-call';
  static const incomingCall = '/incoming-call';
  static const callHistory = '/call-history';

  // Topluluk Rotaları
  static const COMMUNITY_DISCOVERY = '/community-discovery';
  static const COMMUNITY_DETAIL = '/community-detail';
  static const COMMUNITY_CREATE = '/community-create';
  static const MY_COMMUNITIES = '/my-communities';
  static const COMMUNITY_MANAGE = '/community-manage';

  // Map routes
  static const developerMap = '/developer-map';
  static const eventMap = '/event-map';
  static const locationSettings = '/location-settings';
  static const locationHistory = '/location-history';

  // New routes
  static const HOME = '/home';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const PROFILE = '/profile';
  static const SETTINGS = '/settings';
  static const EVENT_DETAIL = '/event/detail';
  static const COMMUNITY_EVENT = '/community/event';
  static const NEARBY_EVENTS = '/events/nearby';
}
