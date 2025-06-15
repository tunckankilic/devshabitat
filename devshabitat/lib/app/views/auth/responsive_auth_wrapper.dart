import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'login/small_phone_login.dart';
import 'login/large_phone_login.dart';
import 'login/tablet_login.dart';
import 'register/small_phone_register.dart';
import 'register/large_phone_register.dart';
import 'register/tablet_register.dart';

class ResponsiveAuthWrapper extends StatelessWidget {
  final bool isLogin;
  const ResponsiveAuthWrapper({Key? key, this.isLogin = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (1.sw < 600) {
          return isLogin ? SmallPhoneLogin() : SmallPhoneRegister();
        } else if (1.sw < 900) {
          return isLogin ? LargePhoneLogin() : LargePhoneRegister();
        } else {
          return isLogin ? TabletLogin() : TabletRegister();
        }
      },
    );
  }
}
