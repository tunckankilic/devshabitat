import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/home_controller.dart';

class CommentsView extends GetView<HomeController> {
  const CommentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yorumlar'),
      ),
      body: const Center(
        child: Text('Yorumlar yakında eklenecek'),
      ),
    );
  }
}
