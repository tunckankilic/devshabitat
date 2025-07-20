import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/responsive_controller.dart';

abstract class BaseView<T extends GetxController> extends GetView<T> {
  const BaseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildView(context);
  }

  Widget buildView(BuildContext context);

  // Helper methods for responsive design
  ResponsiveController get responsive => Get.find<ResponsiveController>();

  // Quick access to responsive values
  double get screenWidth => responsive.screenWidth.value;
  double get screenHeight => responsive.screenHeight.value;
  bool get isTablet => responsive.isTablet;
  bool get isMobile => responsive.isMobile;
}
