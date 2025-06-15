import 'package:get/get.dart';
import 'package:flutter/material.dart';

class EnhancedFormValidationController extends GetxController {
  // Reactive validation states
  final _isEmailValid = false.obs;
  final _isPasswordValid = false.obs;
  final _isUsernameValid = false.obs;
  final _isPhoneValid = false.obs;
  final _isNameValid = false.obs;
  final _isUrlValid = false.obs;

  // Validation error messages
  final _emailError = RxnString();
  final _passwordError = RxnString();
  final _usernameError = RxnString();
  final _phoneError = RxnString();
  final _nameError = RxnString();
  final _urlError = RxnString();

  // Getters
  bool get isEmailValid => _isEmailValid.value;
  bool get isPasswordValid => _isPasswordValid.value;
  bool get isUsernameValid => _isUsernameValid.value;
  bool get isPhoneValid => _isPhoneValid.value;
  bool get isNameValid => _isNameValid.value;
  bool get isUrlValid => _isUrlValid.value;

  String? get emailError => _emailError.value;
  String? get passwordError => _passwordError.value;
  String? get usernameError => _usernameError.value;
  String? get phoneError => _phoneError.value;
  String? get nameError => _nameError.value;
  String? get urlError => _urlError.value;

  // Validation methods
  void validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    _isEmailValid.value = emailRegex.hasMatch(email);
    _emailError.value =
        _isEmailValid.value ? null : 'Geçerli bir e-posta adresi giriniz';
  }

  void validatePassword(String password) {
    final hasMinLength = password.length >= 8;
    final hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    final hasLowerCase = password.contains(RegExp(r'[a-z]'));
    final hasNumbers = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    _isPasswordValid.value = hasMinLength &&
        hasUpperCase &&
        hasLowerCase &&
        hasNumbers &&
        hasSpecialChar;

    if (!_isPasswordValid.value) {
      final errors = <String>[];
      if (!hasMinLength) errors.add('En az 8 karakter');
      if (!hasUpperCase) errors.add('En az bir büyük harf');
      if (!hasLowerCase) errors.add('En az bir küçük harf');
      if (!hasNumbers) errors.add('En az bir rakam');
      if (!hasSpecialChar) errors.add('En az bir özel karakter');
      _passwordError.value = errors.join(', ');
    } else {
      _passwordError.value = null;
    }
  }

  void validateUsername(String username) {
    final hasMinLength = username.length >= 3;
    final hasMaxLength = username.length <= 20;
    final hasValidChars = RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username);

    _isUsernameValid.value = hasMinLength && hasMaxLength && hasValidChars;

    if (!_isUsernameValid.value) {
      final errors = <String>[];
      if (!hasMinLength) errors.add('En az 3 karakter');
      if (!hasMaxLength) errors.add('En fazla 20 karakter');
      if (!hasValidChars) {
        errors.add('Sadece harf, rakam ve alt çizgi kullanabilirsiniz');
      }
      _usernameError.value = errors.join(', ');
    } else {
      _usernameError.value = null;
    }
  }

  void validatePhone(String phone) {
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    _isPhoneValid.value = phoneRegex.hasMatch(phone);
    _phoneError.value =
        _isPhoneValid.value ? null : 'Geçerli bir telefon numarası giriniz';
  }

  void validateName(String name) {
    final hasMinLength = name.length >= 2;
    final hasValidChars = RegExp(r'^[a-zA-ZğüşıöçĞÜŞİÖÇ\s]+$').hasMatch(name);

    _isNameValid.value = hasMinLength && hasValidChars;

    if (!_isNameValid.value) {
      final errors = <String>[];
      if (!hasMinLength) errors.add('En az 2 karakter');
      if (!hasValidChars) errors.add('Sadece harf kullanabilirsiniz');
      _nameError.value = errors.join(', ');
    } else {
      _nameError.value = null;
    }
  }

  void validateUrl(String url) {
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );
    _isUrlValid.value = urlRegex.hasMatch(url);
    _urlError.value = _isUrlValid.value ? null : 'Geçerli bir URL giriniz';
  }

  // Debounced validation methods
  void debouncedValidateEmail(Rx<TextEditingController> controller) {
    ever(controller, (TextEditingController c) {
      validateEmail(c.text);
    });
  }

  void debouncedValidatePassword(Rx<TextEditingController> controller) {
    ever(controller, (TextEditingController c) {
      validatePassword(c.text);
    });
  }

  void debouncedValidateUsername(Rx<TextEditingController> controller) {
    ever(controller, (TextEditingController c) {
      validateUsername(c.text);
    });
  }

  void debouncedValidatePhone(Rx<TextEditingController> controller) {
    ever(controller, (TextEditingController c) {
      validatePhone(c.text);
    });
  }

  void debouncedValidateName(Rx<TextEditingController> controller) {
    ever(controller, (TextEditingController c) {
      validateName(c.text);
    });
  }

  void debouncedValidateUrl(Rx<TextEditingController> controller) {
    ever(controller, (TextEditingController c) {
      validateUrl(c.text);
    });
  }

  // Form validation
  bool validateForm({
    required String email,
    required String password,
    required String username,
    String? phone,
    String? name,
    String? url,
  }) {
    validateEmail(email);
    validatePassword(password);
    validateUsername(username);
    if (phone != null) validatePhone(phone);
    if (name != null) validateName(name);
    if (url != null) validateUrl(url);

    return _isEmailValid.value &&
        _isPasswordValid.value &&
        _isUsernameValid.value &&
        (phone == null || _isPhoneValid.value) &&
        (name == null || _isNameValid.value) &&
        (url == null || _isUrlValid.value);
  }

  // Reset validation states
  void resetValidation() {
    _isEmailValid.value = false;
    _isPasswordValid.value = false;
    _isUsernameValid.value = false;
    _isPhoneValid.value = false;
    _isNameValid.value = false;
    _isUrlValid.value = false;

    _emailError.value = null;
    _passwordError.value = null;
    _usernameError.value = null;
    _phoneError.value = null;
    _nameError.value = null;
    _urlError.value = null;
  }
}
