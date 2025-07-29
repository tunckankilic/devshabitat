import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class ValidationRule {
  final String Function(String) validator;
  final String errorMessage;
  final bool Function(String)? customValidator;
  final String? customErrorMessage;

  ValidationRule({
    required this.validator,
    required this.errorMessage,
    this.customValidator,
    this.customErrorMessage,
  });
}

class EnhancedFormValidationController extends GetxController {
  // Reactive validation states
  final _isEmailValid = false.obs;
  final _isPasswordValid = false.obs;
  final _isUsernameValid = false.obs;
  final _isPhoneValid = false.obs;
  final _isNameValid = false.obs;
  final _isUrlValid = false.obs;
  final _isBioValid = false.obs;
  final _isTitleValid = false.obs;
  final _isCompanyValid = false.obs;
  final _isGithubUsernameValid = false.obs;

  // Validation error messages
  final _emailError = RxnString();
  final _passwordError = RxnString();
  final _usernameError = RxnString();
  final _phoneError = RxnString();
  final _nameError = RxnString();
  final _urlError = RxnString();
  final _bioError = RxnString();
  final _titleError = RxnString();
  final _companyError = RxnString();
  final _githubUsernameError = RxnString();

  // Success states
  final _emailSuccess = false.obs;
  final _passwordSuccess = false.obs;
  final _usernameSuccess = false.obs;
  final _phoneSuccess = false.obs;
  final _nameSuccess = false.obs;
  final _urlSuccess = false.obs;
  final _bioSuccess = false.obs;
  final _titleSuccess = false.obs;
  final _companySuccess = false.obs;
  final _githubUsernameSuccess = false.obs;

  // Form state
  final _isFormValid = false.obs;
  final _isSubmitting = false.obs;
  final _showSuccessMessage = false.obs;
  final _successMessage = ''.obs;

  // Debounce timer
  Timer? _debounceTimer;
  final Duration _debounceDelay = const Duration(milliseconds: 500);

  // Custom validation rules
  final Map<String, List<ValidationRule>> _customRules =
      <String, List<ValidationRule>>{};

  // Getters
  bool get isEmailValid => _isEmailValid.value;
  bool get isPasswordValid => _isPasswordValid.value;
  bool get isUsernameValid => _isUsernameValid.value;
  bool get isPhoneValid => _isPhoneValid.value;
  bool get isNameValid => _isNameValid.value;
  bool get isUrlValid => _isUrlValid.value;
  bool get isBioValid => _isBioValid.value;
  bool get isTitleValid => _isTitleValid.value;
  bool get isCompanyValid => _isCompanyValid.value;
  bool get isGithubUsernameValid => _isGithubUsernameValid.value;

  String? get emailError => _emailError.value;
  String? get passwordError => _passwordError.value;
  String? get usernameError => _usernameError.value;
  String? get phoneError => _phoneError.value;
  String? get nameError => _nameError.value;
  String? get urlError => _urlError.value;
  String? get bioError => _bioError.value;
  String? get titleError => _titleError.value;
  String? get companyError => _companyError.value;
  String? get githubUsernameError => _githubUsernameError.value;

  bool get emailSuccess => _emailSuccess.value;
  bool get passwordSuccess => _passwordSuccess.value;
  bool get usernameSuccess => _usernameSuccess.value;
  bool get phoneSuccess => _phoneSuccess.value;
  bool get nameSuccess => _nameSuccess.value;
  bool get urlSuccess => _urlSuccess.value;
  bool get bioSuccess => _bioSuccess.value;
  bool get titleSuccess => _titleSuccess.value;
  bool get companySuccess => _companySuccess.value;
  bool get githubUsernameSuccess => _githubUsernameSuccess.value;

  bool get isFormValid => _isFormValid.value;
  bool get isSubmitting => _isSubmitting.value;
  bool get showSuccessMessage => _showSuccessMessage.value;
  String get successMessage => _successMessage.value;

  // Enhanced validation methods with real-time feedback
  void validateEmail(String email) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      _isEmailValid.value = emailRegex.hasMatch(email);
      _emailError.value =
          _isEmailValid.value ? null : 'Geçerli bir e-posta adresi giriniz';
      _emailSuccess.value = _isEmailValid.value && email.isNotEmpty;
      _updateFormValidity();
    });
  }

  void validatePassword(String password) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      final hasMinLength = password.length >= 8;
      final hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      final hasLowerCase = password.contains(RegExp(r'[a-z]'));
      final hasNumbers = password.contains(RegExp(r'[0-9]'));
      final hasSpecialChar =
          password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

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
      _passwordSuccess.value = _isPasswordValid.value && password.isNotEmpty;
      _updateFormValidity();
    });
  }

  void validateUsername(String username) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
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
      _usernameSuccess.value = _isUsernameValid.value && username.isNotEmpty;
      _updateFormValidity();
    });
  }

  void validatePhone(String phone) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
      _isPhoneValid.value = phoneRegex.hasMatch(phone);
      _phoneError.value =
          _isPhoneValid.value ? null : 'Geçerli bir telefon numarası giriniz';
      _phoneSuccess.value = _isPhoneValid.value && phone.isNotEmpty;
      _updateFormValidity();
    });
  }

  void validateName(String name) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
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
      _nameSuccess.value = _isNameValid.value && name.isNotEmpty;
      _updateFormValidity();
    });
  }

  void validateUrl(String url) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      final urlRegex = RegExp(
        r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
        caseSensitive: false,
      );
      _isUrlValid.value = urlRegex.hasMatch(url);
      _urlError.value = _isUrlValid.value ? null : 'Geçerli bir URL giriniz';
      _urlSuccess.value = _isUrlValid.value && url.isNotEmpty;
      _updateFormValidity();
    });
  }

  void validateBio(String bio) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      final hasMaxLength = bio.length <= 500;
      _isBioValid.value = hasMaxLength;
      _bioError.value =
          _isBioValid.value ? null : 'Bio en fazla 500 karakter olabilir';
      _bioSuccess.value = _isBioValid.value && bio.isNotEmpty;
      _updateFormValidity();
    });
  }

  void validateTitle(String title) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      final hasMinLength = title.length >= 2;
      final hasMaxLength = title.length <= 100;
      _isTitleValid.value = hasMinLength && hasMaxLength;
      _titleError.value = _isTitleValid.value
          ? null
          : 'Ünvan 2-100 karakter arasında olmalıdır';
      _titleSuccess.value = _isTitleValid.value && title.isNotEmpty;
      _updateFormValidity();
    });
  }

  void validateCompany(String company) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      final hasMaxLength = company.length <= 100;
      _isCompanyValid.value = hasMaxLength;
      _companyError.value = _isCompanyValid.value
          ? null
          : 'Şirket adı en fazla 100 karakter olabilir';
      _companySuccess.value = _isCompanyValid.value && company.isNotEmpty;
      _updateFormValidity();
    });
  }

  void validateGithubUsername(String username) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      final hasMinLength = username.isNotEmpty;
      final hasMaxLength = username.length <= 39;
      final hasValidChars = RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(username);

      _isGithubUsernameValid.value =
          hasMinLength && hasMaxLength && hasValidChars;

      if (!_isGithubUsernameValid.value) {
        final errors = <String>[];
        if (!hasMinLength) errors.add('En az 1 karakter');
        if (!hasMaxLength) errors.add('En fazla 39 karakter');
        if (!hasValidChars) {
          errors.add('Sadece harf, rakam ve tire kullanabilirsiniz');
        }
        _githubUsernameError.value = errors.join(', ');
      } else {
        _githubUsernameError.value = null;
      }
      _githubUsernameSuccess.value =
          _isGithubUsernameValid.value && username.isNotEmpty;
      _updateFormValidity();
    });
  }

  // Custom validation rules
  void addCustomRule(String fieldName, ValidationRule rule) {
    _customRules[fieldName] ??= [];
    _customRules[fieldName]!.add(rule);
  }

  void removeCustomRule(String fieldName, ValidationRule rule) {
    _customRules[fieldName]?.remove(rule);
  }

  String? validateWithCustomRules(String fieldName, String value) {
    final rules = _customRules[fieldName];
    if (rules == null) return null;

    for (final rule in rules) {
      if (rule.customValidator != null) {
        if (!rule.customValidator!(value)) {
          return rule.customErrorMessage ?? rule.errorMessage;
        }
      } else {
        final error = rule.validator(value);
        if (error.isNotEmpty) {
          return error;
        }
      }
    }
    return null;
  }

  // Form validation
  bool validateForm({
    required String email,
    required String password,
    required String username,
    String? phone,
    String? name,
    String? url,
    String? bio,
    String? title,
    String? company,
    String? githubUsername,
  }) {
    validateEmail(email);
    validatePassword(password);
    validateUsername(username);
    if (phone != null) validatePhone(phone);
    if (name != null) validateName(name);
    if (url != null) validateUrl(url);
    if (bio != null) validateBio(bio);
    if (title != null) validateTitle(title);
    if (company != null) validateCompany(company);
    if (githubUsername != null) validateGithubUsername(githubUsername);

    return _isEmailValid.value &&
        _isPasswordValid.value &&
        _isUsernameValid.value &&
        (phone == null || _isPhoneValid.value) &&
        (name == null || _isNameValid.value) &&
        (url == null || _isUrlValid.value) &&
        (bio == null || _isBioValid.value) &&
        (title == null || _isTitleValid.value) &&
        (company == null || _isCompanyValid.value) &&
        (githubUsername == null || _isGithubUsernameValid.value);
  }

  // Form submission
  Future<bool> submitForm(Future<bool> Function() onSubmit) async {
    if (!_isFormValid.value) return false;

    try {
      _isSubmitting.value = true;
      final success = await onSubmit();

      if (success) {
        _showSuccessMessage.value = true;
        _successMessage.value = 'Form başarıyla gönderildi!';

        // Success message'ı 3 saniye sonra gizle
        Timer(const Duration(seconds: 3), () {
          _showSuccessMessage.value = false;
        });
      }

      return success;
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Form gönderilirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isSubmitting.value = false;
    }
  }

  // Form validity update
  void _updateFormValidity() {
    _isFormValid.value = _isEmailValid.value &&
        _isPasswordValid.value &&
        _isUsernameValid.value &&
        _isPhoneValid.value &&
        _isNameValid.value &&
        _isUrlValid.value &&
        _isBioValid.value &&
        _isTitleValid.value &&
        _isCompanyValid.value &&
        _isGithubUsernameValid.value;
  }

  // Reset validation states
  void resetValidation() {
    _isEmailValid.value = false;
    _isPasswordValid.value = false;
    _isUsernameValid.value = false;
    _isPhoneValid.value = false;
    _isNameValid.value = false;
    _isUrlValid.value = false;
    _isBioValid.value = false;
    _isTitleValid.value = false;
    _isCompanyValid.value = false;
    _isGithubUsernameValid.value = false;

    _emailError.value = null;
    _passwordError.value = null;
    _usernameError.value = null;
    _phoneError.value = null;
    _nameError.value = null;
    _urlError.value = null;
    _bioError.value = null;
    _titleError.value = null;
    _companyError.value = null;
    _githubUsernameError.value = null;

    _emailSuccess.value = false;
    _passwordSuccess.value = false;
    _usernameSuccess.value = false;
    _phoneSuccess.value = false;
    _nameSuccess.value = false;
    _urlSuccess.value = false;
    _bioSuccess.value = false;
    _titleSuccess.value = false;
    _companySuccess.value = false;
    _githubUsernameSuccess.value = false;

    _isFormValid.value = false;
    _showSuccessMessage.value = false;
    _successMessage.value = '';
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}
