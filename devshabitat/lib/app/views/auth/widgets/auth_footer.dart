import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthFooter extends StatelessWidget {
  final bool isLogin;

  const AuthFooter({
    Key? key,
    required this.isLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isLogin ? 'Hesabınız yok mu?' : 'Zaten hesabınız var mı?',
        ),
        TextButton(
          onPressed: () {
            Get.toNamed(isLogin ? '/register' : '/login');
          },
          child: Text(
            isLogin ? 'Kayıt Ol' : 'Giriş Yap',
          ),
        ),
      ],
    );
  }
}
