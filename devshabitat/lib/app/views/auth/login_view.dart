import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/responsive_controller.dart';
import '../base/base_view.dart';
import 'login/large_phone_login.dart';
import 'login/small_phone_login.dart';
import 'login/tablet_login.dart';

class LoginView extends BaseView<AuthController> {
  const LoginView({super.key});

  @override
  Widget buildView(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    if (responsive.isSmallPhone) {
      return const SmallPhoneLogin();
    } else if (responsive.isLargePhone) {
      return LargePhoneLogin();
    } else {
      return const TabletLogin();
    }
  }
}
