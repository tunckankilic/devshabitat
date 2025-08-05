import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingDialog extends StatelessWidget {
  final String message;
  final Duration timeout;
  final VoidCallback? onTimeout;

  const LoadingDialog({
    super.key,
    required this.message,
    this.timeout = const Duration(seconds: 30),
    this.onTimeout,
  });

  @override
  Widget build(BuildContext context) {
    // Timeout sonrası dialog'u kapat
    Future.delayed(timeout, () {
      if (Get.isDialogOpen ?? false) {
        Get.back();
        onTimeout?.call();
      }
    });

    return WillPopScope(
      onWillPop: () async =>
          true, // Dialog'un geri tuşuyla kapatılmasına izin ver
      child: Dialog(
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }
}

// Global helper fonksiyon
void showLoadingDialog(String message) {
  Get.dialog(
    LoadingDialog(
      message: message,
      onTimeout: () {
        Get.snackbar(
          'Uyarı',
          'İşlem zaman aşımına uğradı',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      },
    ),
    barrierDismissible: true,
  );
}
