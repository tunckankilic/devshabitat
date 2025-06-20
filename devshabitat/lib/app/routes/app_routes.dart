part of 'app_pages.dart';

abstract class Routes {
  static const INITIAL = '/';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const MAIN = '/main';
  static const HOME = '/home';
  static const SEARCH = '/search';
  static const PROFILE = '/profile';
  static const SETTINGS = '/settings';
  static const FORGOT_PASSWORD = '/forgot-password';
  static const MESSAGES = '/messages';
  static const CHAT = '/chat/:id';
  static const NEW_CHAT = '/new-chat';
  static const DISCOVERY = '/discovery';
  static const NETWORKING = '/networking';
  static const COMMENTS = '/comments';
  static const ITEM_DETAIL = '/item-detail';
  static const USER_PROFILE = '/user-profile';
  static const EDIT_PROFILE = '/edit-profile';
  static const NOTIFICATIONS = '/notifications';
  static const MESSAGE_SEARCH = '/message-search/:id?';
}
