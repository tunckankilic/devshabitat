// ignore_for_file: constant_identifier_names

part of 'app_pages.dart';

abstract class AppRoutes {
  // Auth routes
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const emailVerification = '/email-verification';
  static const emailVerificationAdvanced = '/email-verification-advanced';
  static const authSecurity = '/auth-security';

  // Main routes
  static const home = '/home';
  static const profile = '/profile';
  static const editProfile = '/edit-profile';
  static const settings = '/settings';
  static const appInfo = '/app-info';
  static const notifications = '/notifications';
  static const notificationSettings = '/notification-settings';
  static const search = '/search';

  // Quick Action routes
  static const newProject = '/new-project';
  static const connections = '/connections';
  static const newBlog = '/new-blog';

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
  static const COMMUNITY_RULES = '/community/rules';

  // Map routes
  static const developerMap = '/developer-map';
  static const eventMap = '/event-map';
  static const locationSettings = '/location-settings';
  static const locationHistory = '/location-history';

  // Chat routes
  static const CHAT = '/chat';
  static const NEW_CHAT = '/new-chat';
  static const THREAD_ORGANIZATION = '/thread-organization';

  // Register routes
  static const registerCompleteProfile = '/register/complete-profile';

  // Comments routes
  static const comments = '/comments';

  // Debug routes
  static const memoryDebug = '/memory-debug';
  static const performanceMonitor = '/debug/performance';
  static const enhancedFormTest = '/debug/enhanced-form-test';

  // GitHub Integration routes
  static const githubIntegration = '/github-integration';

  // Integration routes
  static const integrations = '/integrations';

  // Network routes
  static const networkStatus = '/network-status';

  static const messageSearch = '/message-search';
}
