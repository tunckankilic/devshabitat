import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/navigation_service.dart';

class NavigationController extends GetxController {
  final NavigationService _navigationService;
  final RxInt currentIndex = 0.obs;

  NavigationController(this._navigationService);

  Future<void> navigateToPage(String routeName, {dynamic arguments}) async {
    await _navigationService.navigateTo(routeName, arguments: arguments);
  }

  void goBack() {
    _navigationService.goBack();
  }

  Future<void> navigateToAndRemoveUntil(String routeName,
      {dynamic arguments}) async {
    await _navigationService.navigateToAndRemoveUntil(routeName,
        arguments: arguments);
  }

  Future<void> navigateToAndReplace(String routeName,
      {dynamic arguments}) async {
    await _navigationService.navigateToAndReplace(routeName,
        arguments: arguments);
  }

  void popUntil(String routeName) {
    _navigationService.popUntil(routeName);
  }

  Future<T?> showCustomDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) async {
    final result = await _navigationService.showCustomDialog(
      child: child,
      barrierDismissible: barrierDismissible,
    );
    return result as T?;
  }

  Future<T?> showCustomBottomSheet<T>({
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
  }) async {
    final result = await _navigationService.showCustomBottomSheet(
      child: child,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor,
    );
    return result as T?;
  }

  void changePage(int index) {
    currentIndex.value = index;
  }
}
