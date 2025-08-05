import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

mixin ControllerLifecycleMixin on GetxController {
  final List<TextEditingController> _controllers = [];
  final List<Worker> _workers = [];
  final List<StreamSubscription> _subscriptions = [];

  // TextEditingController için factory method
  TextEditingController createController([String? initialValue]) {
    final controller = TextEditingController(text: initialValue);
    _controllers.add(controller);
    return controller;
  }

  // Worker için factory method
  void createWorker(Worker worker) {
    _workers.add(worker);
  }

  // StreamSubscription için factory method
  void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  @override
  void onClose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final worker in _workers) {
      worker.dispose();
    }
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _controllers.clear();
    _workers.clear();
    _subscriptions.clear();
    super.onClose();
  }
}
