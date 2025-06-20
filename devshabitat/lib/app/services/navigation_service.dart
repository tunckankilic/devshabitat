import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationService extends GetxService {
  final navigationKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName, {dynamic arguments}) {
    return navigationKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  void goBack() {
    return navigationKey.currentState!.pop();
  }

  Future<dynamic> navigateToAndRemoveUntil(String routeName,
      {dynamic arguments}) {
    return navigationKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  Future<dynamic> navigateToAndReplace(String routeName, {dynamic arguments}) {
    return navigationKey.currentState!.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  void popUntil(String routeName) {
    navigationKey.currentState!.popUntil(ModalRoute.withName(routeName));
  }

  Future<dynamic> showCustomDialog({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog(
      context: navigationKey.currentState!.context,
      barrierDismissible: barrierDismissible,
      builder: (context) => child,
    );
  }

  Future<dynamic> showCustomBottomSheet({
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
  }) {
    return showModalBottomSheet(
      context: navigationKey.currentState!.context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor,
      builder: (context) => child,
    );
  }
}
