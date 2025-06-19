import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../core/services/error_handler_service.dart';

enum RegistrationStep {
  initial,
  personalInfo,
  accountDetails,
  verification,
  completed,
}

class RegistrationController extends GetxController {
  final AuthRepository _authRepository;
  final ErrorHandlerService _errorHandler;

  // Reactive state variables
  final _currentStep = RegistrationStep.initial.obs;
  final _isLoading = false.obs;
  final _lastError = RxnString();
  final _isEmailValid = false.obs;
  final _isPasswordValid = false.obs;
  final _isUsernameValid = false.obs;

  // Form controllers
  final emailController = TextEditingController().obs;
  final passwordController = TextEditingController().obs;
  final confirmPasswordController = TextEditingController().obs;
  final usernameController = TextEditingController().obs;
  final firstNameController = TextEditingController().obs;
  final lastNameController = TextEditingController().obs;

  // Getters
  bool get isLoading => _isLoading.value;
  RegistrationStep get currentStep => _currentStep.value;
  String? get lastError => _lastError.value;
  bool get isEmailValid => _isEmailValid.value;
  bool get isPasswordValid => _isPasswordValid.value;
  bool get isUsernameValid => _isUsernameValid.value;
  bool get canProceed =>
      _isEmailValid.value && _isPasswordValid.value && _isUsernameValid.value;

  RegistrationController({
    required AuthRepository authRepository,
    required ErrorHandlerService errorHandler,
  })  : _authRepository = authRepository,
        _errorHandler = errorHandler;

  @override
  void onInit() {
    super.onInit();
    _setupValidationListeners();
  }

  void _setupValidationListeners() {
    ever(emailController, (TextEditingController controller) {
      _validateEmail(controller.text);
    });

    ever(passwordController, (TextEditingController controller) {
      _validatePassword(controller.text);
    });

    ever(usernameController, (TextEditingController controller) {
      _validateUsername(controller.text);
    });
  }

  void _validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    _isEmailValid.value = emailRegex.hasMatch(email);
  }

  void _validatePassword(String password) {
    _isPasswordValid.value = password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  void _validateUsername(String username) {
    _isUsernameValid.value = username.length >= 3 &&
        username.length <= 20 &&
        RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username);
  }

  void nextStep() {
    switch (_currentStep.value) {
      case RegistrationStep.initial:
        _currentStep.value = RegistrationStep.personalInfo;
        break;
      case RegistrationStep.personalInfo:
        if (_validatePersonalInfo()) {
          _currentStep.value = RegistrationStep.accountDetails;
        }
        break;
      case RegistrationStep.accountDetails:
        if (_validateAccountDetails()) {
          _currentStep.value = RegistrationStep.verification;
          _startVerification();
        }
        break;
      case RegistrationStep.verification:
        _currentStep.value = RegistrationStep.completed;
        break;
      default:
        break;
    }
  }

  void previousStep() {
    switch (_currentStep.value) {
      case RegistrationStep.personalInfo:
        _currentStep.value = RegistrationStep.initial;
        break;
      case RegistrationStep.accountDetails:
        _currentStep.value = RegistrationStep.personalInfo;
        break;
      case RegistrationStep.verification:
        _currentStep.value = RegistrationStep.accountDetails;
        break;
      default:
        break;
    }
  }

  bool _validatePersonalInfo() {
    if (firstNameController.value.text.isEmpty ||
        lastNameController.value.text.isEmpty) {
      _errorHandler.handleError('Ad ve soyad alanları zorunludur');
      return false;
    }
    return true;
  }

  bool _validateAccountDetails() {
    if (!_isEmailValid.value ||
        !_isPasswordValid.value ||
        !_isUsernameValid.value) {
      _errorHandler.handleError('Lütfen tüm alanları doğru şekilde doldurun');
      return false;
    }

    if (passwordController.value.text != confirmPasswordController.value.text) {
      _errorHandler.handleError('Şifreler eşleşmiyor');
      return false;
    }

    return true;
  }

  Future<void> _startVerification() async {
    try {
      _isLoading.value = true;
      await _authRepository.createUserWithEmailAndPassword(
        emailController.value.text,
        passwordController.value.text,
        usernameController.value.text,
      );
      await _authRepository.verifyEmail();
      _errorHandler.handleSuccess('Doğrulama e-postası gönderildi');
    } catch (e) {
      _errorHandler.handleError(e);
      _lastError.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.value.dispose();
    passwordController.value.dispose();
    confirmPasswordController.value.dispose();
    usernameController.value.dispose();
    firstNameController.value.dispose();
    lastNameController.value.dispose();
    super.onClose();
  }
}
