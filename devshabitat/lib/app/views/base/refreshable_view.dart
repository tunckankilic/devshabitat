import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'base_view.dart';

abstract class RefreshableView<T extends GetxController> extends BaseView<T> {
  const RefreshableView({super.key});

  Future<void> onRefresh();
  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: buildContent(context),
    );
  }
}
