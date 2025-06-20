import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class BaseView<T extends GetxController> extends GetView<T> {
  const BaseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ScreenUtil initialization
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812), // iPhone X tasarım boyutları
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return buildView(context);
  }

  Widget buildView(BuildContext context);
}
