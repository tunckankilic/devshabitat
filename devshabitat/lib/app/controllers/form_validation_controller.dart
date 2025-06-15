import 'package:get/get.dart';

class FormValidationController extends GetxController {
  final email = ''.obs;
  final password = ''.obs;
  final confirmPassword = ''.obs;
  final username = ''.obs;

  final emailError = RxnString();
  final passwordError = RxnString();
  final confirmPasswordError = RxnString();
  final usernameError = RxnString();

  final isEmailValid = false.obs;
  final isPasswordValid = false.obs;
  final isConfirmPasswordValid = false.obs;
  final isUsernameValid = false.obs;

  void validateEmail(String value) {
    email.value = value;
    if (value.isEmpty) {
      emailError.value = 'E-posta adresi boş olamaz';
      isEmailValid.value = false;
    } else if (!GetUtils.isEmail(value)) {
      emailError.value = 'Geçerli bir e-posta adresi girin';
      isEmailValid.value = false;
    } else {
      emailError.value = null;
      isEmailValid.value = true;
    }
  }

  void validatePassword(String value) {
    password.value = value;
    if (value.isEmpty) {
      passwordError.value = 'Şifre boş olamaz';
      isPasswordValid.value = false;
    } else if (value.length < 6) {
      passwordError.value = 'Şifre en az 6 karakter olmalıdır';
      isPasswordValid.value = false;
    } else {
      passwordError.value = null;
      isPasswordValid.value = true;
    }
  }

  void validateConfirmPassword(String value) {
    confirmPassword.value = value;
    if (value.isEmpty) {
      confirmPasswordError.value = 'Şifre tekrarı boş olamaz';
      isConfirmPasswordValid.value = false;
    } else if (value != password.value) {
      confirmPasswordError.value = 'Şifreler eşleşmiyor';
      isConfirmPasswordValid.value = false;
    } else {
      confirmPasswordError.value = null;
      isConfirmPasswordValid.value = true;
    }
  }

  void validateUsername(String value) {
    username.value = value;
    if (value.isEmpty) {
      usernameError.value = 'Kullanıcı adı boş olamaz';
      isUsernameValid.value = false;
    } else if (value.length < 3) {
      usernameError.value = 'Kullanıcı adı en az 3 karakter olmalıdır';
      isUsernameValid.value = false;
    } else {
      usernameError.value = null;
      isUsernameValid.value = true;
    }
  }

  bool get isFormValid =>
      isEmailValid.value &&
      isPasswordValid.value &&
      isConfirmPasswordValid.value &&
      isUsernameValid.value;
}
