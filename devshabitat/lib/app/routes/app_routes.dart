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

  // Video routes
  static const videoCall = '/video-call';
  static const incomingCall = '/incoming-call';
  static const callHistory = '/call-history';
}
