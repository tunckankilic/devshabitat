import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityEventView extends StatelessWidget {
  const CommunityEventView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topluluk Etkinliği'),
      ),
      body: const Center(
        child: Text('Topluluk Etkinlik Sayfası'),
      ),
    );
  }
}
