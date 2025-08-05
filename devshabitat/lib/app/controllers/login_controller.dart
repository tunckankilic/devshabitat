import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../core/services/error_handler_service.dart';
import '../controllers/auth_controller.dart';
import 'package:logger/logger.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepository;
  final ErrorHandlerService _errorHandler;
  final AuthController _authController;
  final Logger _logger = Get.find<Logger>();

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Reactive state variables
  final _isLoading = false.obs;
  final _lastError = RxnString();
  final _isEmailValid = false.obs;
  final _rememberMe = false.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  String? get lastError => _lastError.value;
  bool get isEmailValid => _isEmailValid.value;
  bool get rememberMe => _rememberMe.value;

  LoginController({
    required AuthRepository authRepository,
    required ErrorHandlerService errorHandler,
    required AuthController authController,
  }) : _authRepository = authRepository,
       _errorHandler = errorHandler,
       _authController = authController;

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(_validateEmail);
  }

  void _validateEmail() {
    final email = emailController.text;
    _isEmailValid.value = email.isNotEmpty && GetUtils.isEmail(email);
  }

  void toggleRememberMe() {
    _rememberMe.value = !_rememberMe.value;
  }

  // Email ile giriş
  Future<void> loginWithEmail() async {
    try {
      if (!_isEmailValid.value) {
        Get.snackbar(
          'Hata',
          'Lütfen geçerli bir email adresi girin',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      _isLoading.value = true;

      final userCredential = await _authRepository.signInWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );

      if (userCredential.user == null) {
        throw Exception('Giriş başarısız oldu');
      }

      // Beni hatırla seçeneği işlemi
      if (_rememberMe.value) {
        await _authRepository.setPersistence(true);
      }

      // Ana sayfaya yönlendir
      Get.offAllNamed('/home');
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
    } finally {
      _isLoading.value = false;
    }
  }

  // Google ile giriş
  Future<void> loginWithGoogle() async {
    try {
      _isLoading.value = true;

      final userCredential = await _authRepository.signInWithGoogle();

      if (userCredential.user == null) {
        throw Exception('Google ile giriş başarısız oldu');
      }

      // Beni hatırla seçeneği işlemi
      if (_rememberMe.value) {
        await _authRepository.setPersistence(true);
      }

      // Kullanıcı daha önce kayıt olmamışsa kayıt sayfasına yönlendir
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        Get.offAllNamed(
          '/register',
          arguments: {
            'email': userCredential.user?.email,
            'displayName': userCredential.user?.displayName,
            'photoUrl': userCredential.user?.photoURL,
            'provider': 'google',
          },
        );
        return;
      }

      // Ana sayfaya yönlendir
      Get.offAllNamed('/home');
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
    } finally {
      _isLoading.value = false;
    }
  }

  // Apple ile giriş
  Future<void> loginWithApple() async {
    try {
      _isLoading.value = true;

      final userCredential = await _authRepository.signInWithApple();

      if (userCredential.user == null) {
        throw Exception('Apple ile giriş başarısız oldu');
      }

      // Beni hatırla seçeneği işlemi
      if (_rememberMe.value) {
        await _authRepository.setPersistence(true);
      }

      // Kullanıcı daha önce kayıt olmamışsa kayıt sayfasına yönlendir
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        Get.offAllNamed(
          '/register',
          arguments: {
            'email': userCredential.user?.email,
            'displayName': userCredential.user?.displayName,
            'provider': 'apple',
          },
        );
        return;
      }

      // Ana sayfaya yönlendir
      Get.offAllNamed('/home');
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
    } finally {
      _isLoading.value = false;
    }
  }

  // Şifremi unuttum
  Future<void> forgotPassword() async {
    try {
      if (!_isEmailValid.value) {
        Get.snackbar(
          'Hata',
          'Lütfen geçerli bir email adresi girin',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      _isLoading.value = true;

      await _authRepository.sendPasswordResetEmail(emailController.text);

      Get.snackbar(
        'Başarılı',
        'Şifre sıfırlama bağlantısı email adresinize gönderildi',
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
