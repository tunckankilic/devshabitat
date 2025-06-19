import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:get/get.dart';

abstract class RefreshableView<T extends GetxController> extends GetView<T> {
  const RefreshableView({Key? key}) : super(key: key);

  Future<void> onRefresh();
  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    final refreshController = RefreshController();

    return SmartRefresher(
      controller: refreshController,
      onRefresh: () async {
        try {
          await onRefresh();
          refreshController.refreshCompleted();
        } catch (e) {
          refreshController.refreshFailed();
        }
      },
      header: const WaterDropHeader(
        waterDropColor: Colors.deepPurple,
        complete: Icon(Icons.done, color: Colors.green),
        failed: Icon(Icons.error, color: Colors.red),
      ),
      child: buildContent(context),
    );
  }
}
