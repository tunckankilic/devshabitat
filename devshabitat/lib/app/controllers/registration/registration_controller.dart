import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/error/registration_error.dart';
import '../../core/services/security_service.dart';
import '../../services/registration/registration_validation_service.dart';
import '../../services/github_oauth_service.dart';
import '../../services/error/error_handling_service.dart';
import '../../core/config/registration_config.dart';

class RegistrationController extends GetxController {
  final SecurityService _securityService;
  final RegistrationValidationService _validationService;
  final GitHubOAuthService _githubService;
  final ErrorHandlingService _errorHandler;

  // Form Controllers - Güvenli kullanım için
  final emailController = TextEditingController();
  final usernameController = TextEditingController();

  // Şifre kontrollerini ayrı bir sınıfta yönet
  late final _PasswordControllers _passwordControllers;

  // UI State
  final RxBool isLoading = false.obs;
  final RxBool isGithubConnected = false.obs;
  final RxString currentStep = 'basicInfo'.obs;
  final RxMap<String, dynamic> githubData = RxMap<String, dynamic>();

  RegistrationController({
    required SecurityService securityService,
    required RegistrationValidationService validationService,
    required GitHubOAuthService githubService,
    required ErrorHandlingService errorHandler,
  }) : _securityService = securityService,
       _validationService = validationService,
       _githubService = githubService,
       _errorHandler = errorHandler {
    _passwordControllers = _PasswordControllers(
      securityService: _securityService,
      errorHandler: _errorHandler,
    );
  }

  // Güvenli şifre erişimi
  String get password => _passwordControllers.password;
  String get confirmPassword => _passwordControllers.confirmPassword;

  Future<void> registerUser() async {
    try {
      isLoading.value = true;

      // Form validasyonu
      _validateForm();

      // GitHub entegrasyonu
      if (isGithubConnected.value) {
        await _handleGithubIntegration();
      }

      // Kullanıcı kaydı
      await _performRegistration();

      // Başarılı kayıt
      Get.offAllNamed('/home');
    } on RegistrationException catch (e) {
      _errorHandler.handleRegistrationError(e);
    } finally {
      isLoading.value = false;
      _passwordControllers.clearPasswords();
    }
  }

  void _validateForm() {
    _validationService.validateEmail(emailController.text);
    _validationService.validateUsername(usernameController.text);
    _validationService.validatePassword(password);
    _validationService.validatePasswordMatch(password, confirmPassword);
  }

  Future<void> _handleGithubIntegration() async {
    try {
      // GitHub OAuth işlemi
      final accessToken = await _githubService.getGithubAccessToken();
      if (accessToken == null) {
        throw RegistrationException(
          RegistrationErrorType.githubConnectionFailed,
          details: 'GitHub bağlantısı başarısız oldu',
        );
      }

      // Token'ı güvenli şekilde sakla
      await _securityService.storeToken(
        token: accessToken,
        type: 'github',
        expiry: RegistrationConfig.tokenExpiry,
      );

      // Paralel olarak tüm GitHub verilerini al
      final futures = await Future.wait([
        _githubService.getUserInfo(accessToken),
        _githubService.getUserEmails(accessToken),
        _githubService.getUserRepositories(accessToken),
      ]);

      final userInfo = futures[0] as Map<String, dynamic>?;
      final emails = futures[1] as List<String>?;
      final repos = futures[2] as List<Map<String, dynamic>>?;

      if (userInfo != null) {
        githubData.value = userInfo;

        if (emails != null && emails.isNotEmpty) {
          githubData['primaryEmail'] = emails.first;
        }

        if (repos != null) {
          githubData['repositories'] = repos;
        }
      }

      isGithubConnected.value = true;
    } catch (e) {
      isGithubConnected.value = false;
      rethrow;
    }
  }

  Future<void> _performRegistration() async {
    // Firebase Auth işlemleri
    // Firestore profil oluşturma
    // vs.
  }

  @override
  void onClose() {
    emailController.dispose();
    usernameController.dispose();
    _passwordControllers.dispose();
    super.onClose();
  }
}

// Şifre yönetimi için ayrı bir sınıf
class _PasswordControllers {
  final SecurityService _securityService;
  final ErrorHandlingService _errorHandler;

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _PasswordControllers({
    required SecurityService securityService,
    required ErrorHandlingService errorHandler,
  }) : _securityService = securityService,
       _errorHandler = errorHandler;

  // Şifreleri güvenli şekilde al
  String get password => _passwordController.text;
  String get confirmPassword => _confirmPasswordController.text;

  // Şifreleri temizle
  void clearPasswords() {
    _passwordController.clear();
    _confirmPasswordController.clear();

    // Belleği temizle
    _securityService.secureClearMemory([password, confirmPassword]);
  }

  void dispose() {
    clearPasswords();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }
}
