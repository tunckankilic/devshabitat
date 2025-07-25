import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/responsive_controller.dart';
import '../../constants/app_strings.dart';

class EmailVerificationView extends StatefulWidget {
  const EmailVerificationView({super.key});

  @override
  State<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView> {
  final _responsiveController = Get.find<ResponsiveController>();
  bool _isChecking = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startEmailVerificationCheck();
  }

  // Otomatik email doğrulama kontrolü
  void _startEmailVerificationCheck() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerification(timer);
    });
  }

  Future<void> _checkEmailVerification(Timer timer) async {
    if (_isChecking) return;

    setState(() => _isChecking = true);

    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;

      if (user?.emailVerified == true) {
        timer.cancel();
        Get.snackbar(
          'Başarılı!',
          'Email adresiniz doğrulandı. Hoş geldiniz!',
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
        Get.offAllNamed('/home');
      }
    } catch (e) {
      print('Email verification kontrol hatası: $e');
    } finally {
      setState(() => _isChecking = false);
    }
  }

  Future<void> _resendEmail() async {
    setState(() => _isResending = true);

    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      Get.snackbar(
        'Email Gönderildi',
        'Doğrulama emaili tekrar gönderildi.',
        backgroundColor: Colors.blue.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.email, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Email gönderilemedi. Lütfen tekrar deneyin.',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Email Doğrulama',
          style: TextStyle(
            fontSize: _responsiveController.responsiveValue(
              mobile: 20.0,
              tablet: 24.0,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: _responsiveController.responsivePadding(all: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Email icon
            Container(
              width: _responsiveController.responsiveValue(
                mobile: 120.0,
                tablet: 160.0,
              ),
              height: _responsiveController.responsiveValue(
                mobile: 120.0,
                tablet: 160.0,
              ),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.email_outlined,
                size: _responsiveController.responsiveValue(
                  mobile: 60.0,
                  tablet: 80.0,
                ),
                color: Colors.blue[600],
              ),
            ),

            SizedBox(
                height: _responsiveController.responsiveValue(
              mobile: 32.0,
              tablet: 40.0,
            )),

            // Title
            Text(
              'Email Adresinizi Doğrulayın',
              style: TextStyle(
                fontSize: _responsiveController.responsiveValue(
                  mobile: 24.0,
                  tablet: 28.0,
                ),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(
                height: _responsiveController.responsiveValue(
              mobile: 16.0,
              tablet: 20.0,
            )),

            // Description
            Text(
              'Doğrulama emaili ${user?.email} adresine gönderildi.\n\nLütfen email kutunuzu kontrol edin ve doğrulama linkine tıklayın.',
              style: TextStyle(
                fontSize: _responsiveController.responsiveValue(
                  mobile: 16.0,
                  tablet: 18.0,
                ),
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(
                height: _responsiveController.responsiveValue(
              mobile: 32.0,
              tablet: 40.0,
            )),

            // Loading indicator
            if (_isChecking)
              Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Email doğrulaması kontrol ediliyor...',
                    style: TextStyle(
                      fontSize: _responsiveController.responsiveValue(
                        mobile: 14.0,
                        tablet: 16.0,
                      ),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

            SizedBox(
                height: _responsiveController.responsiveValue(
              mobile: 24.0,
              tablet: 32.0,
            )),

            // Resend button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isResending ? null : _resendEmail,
                icon: _isResending
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.refresh),
                label: Text(
                  _isResending ? 'Gönderiliyor...' : 'Emaili Tekrar Gönder',
                  style: TextStyle(
                    fontSize: _responsiveController.responsiveValue(
                      mobile: 16.0,
                      tablet: 18.0,
                    ),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: _responsiveController.responsivePadding(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),

            SizedBox(
                height: _responsiveController.responsiveValue(
              mobile: 16.0,
              tablet: 20.0,
            )),

            // Skip button (development only)
            TextButton(
              onPressed: () {
                Get.offAllNamed('/home');
              },
              child: Text(
                'Şimdilik Geç (Geliştirme)',
                style: TextStyle(
                  fontSize: _responsiveController.responsiveValue(
                    mobile: 14.0,
                    tablet: 16.0,
                  ),
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
