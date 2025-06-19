import 'package:flutter/material.dart';
import 'login/large_phone_login.dart';
import 'login/small_phone_login.dart';
import 'login/tablet_login.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return const SmallPhoneLogin();
        } else if (constraints.maxWidth < 900) {
          return LargePhoneLogin();
        } else {
          return const TabletLogin();
        }
      },
    );
  }
}
