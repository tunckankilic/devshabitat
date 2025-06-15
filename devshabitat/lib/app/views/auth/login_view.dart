import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login/large_phone_login.dart';
import 'login/small_phone_login.dart';
import 'login/tablet_login.dart';

class LoginView extends StatelessWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return SmallPhoneLogin();
        } else if (constraints.maxWidth < 900) {
          return LargePhoneLogin();
        } else {
          return TabletLogin();
        }
      },
    );
  }
}
