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
  final _socialAuthData = Rxn<Map<String, dynamic>>();

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final githubUsernameController = TextEditingController();

  // Getters
  bool get isLoading => _isLoading.value;
  RegistrationStep get currentStep => _currentStep.value;
  String? get lastError => _lastError.value;
  bool get isEmailValid => _isEmailValid.value;
  bool get isPasswordValid => _isPasswordValid.value;
  bool get isUsernameValid => _isUsernameValid.value;
  bool get canProceed =>
      _isEmailValid.value && _isPasswordValid.value && _isUsernameValid.value;
  Map<String, dynamic>? get socialAuthData => _socialAuthData.value;

  RegistrationController({
    required AuthRepository authRepository,
    required ErrorHandlerService errorHandler,
  })  : _authRepository = authRepository,
        _errorHandler = errorHandler;

  @override
  void onInit() {
    super.onInit();
    _setupValidationListeners();
    _handleSocialAuthData();
  }

  void _handleSocialAuthData() {
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      _socialAuthData.value = args;

      // Form alanlarını doldur
      emailController.text = args['email'] ?? '';
      if (args['displayName'] != null) {
        final names = args['displayName'].toString().split(' ');
        firstNameController.text = names.first;
        if (names.length > 1) {
          lastNameController.text = names.sublist(1).join(' ');
        }
      }
      if (args['githubUsername'] != null) {
        githubUsernameController.text = args['githubUsername'];
      }

      // Email ve kullanıcı adı validasyonlarını tetikle
      _validateEmail(emailController.text);
      _validateUsername(usernameController.text);
    }
  }

  void _setupValidationListeners() {
    emailController.addListener(() {
      _validateEmail(emailController.text);
    });

    passwordController.addListener(() {
      _validatePassword(passwordController.text);
    });

    usernameController.addListener(() {
      _validateUsername(usernameController.text);
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

      // Email kontrolü
      final methods = await _authRepository.auth
          .fetchSignInMethodsForEmail(emailController.text);
      if (methods.isNotEmpty) {
        _errorHandler.handleError('Bu email adresi zaten kullanımda');
        return;
      }

      // Kullanıcı oluştur
      final userCredential =
          await _authRepository.createUserWithEmailAndPassword(
        emailController.value.text,
        passwordController.value.text,
        usernameController.value.text,
      );

      // Sosyal auth provider'ı bağla
      if (_socialAuthData.value != null) {
        final provider = _socialAuthData.value!['provider'];
        if (provider == 'github') {
          await _authRepository.linkWithGithub();
        }
        // Diğer provider'lar için de benzer işlemler eklenebilir
      }

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
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    githubUsernameController.dispose();
    super.onClose();
  }
}
