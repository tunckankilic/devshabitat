import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/auth_repository.dart';
import '../core/services/error_handler_service.dart';

class EmailAuthController extends GetxController {
  final AuthRepository _authRepository;
  final ErrorHandlerService _errorHandler;

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();

  // Reactive state variables
  final _isLoading = false.obs;
  final _lastError = ''.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  String get lastError => _lastError.value;

  EmailAuthController({
    required AuthRepository authRepository,
    required ErrorHandlerService errorHandler,
  })  : _authRepository = authRepository,
        _errorHandler = errorHandler;

  Future<void> signInWithEmailAndPassword() async {
    try {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        throw Exception('E-posta ve şifre alanları boş bırakılamaz');
      }

      _isLoading.value = true;
      _lastError.value = '';
      await _authRepository.signInWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );
      _errorHandler.handleSuccess('Giriş başarılı');
    } catch (e) {
      _lastError.value = e.toString();
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        throw Exception('E-posta ve şifre alanları boş bırakılamaz');
      }

      if (usernameController.text.isEmpty) {
        throw Exception('Kullanıcı adı boş bırakılamaz');
      }

      if (passwordController.text != confirmPasswordController.text) {
        throw Exception('Şifreler eşleşmiyor');
      }

      _isLoading.value = true;
      _lastError.value = '';
      await _authRepository.createUserWithEmailAndPassword(
        emailController.text,
        passwordController.text,
        usernameController.text,
      );
      _errorHandler.handleSuccess('Hesap oluşturuldu');
    } catch (e) {
      _lastError.value = e.toString();
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> sendPasswordResetEmail() async {
    try {
      if (emailController.text.isEmpty) {
        throw Exception('Lütfen e-posta adresinizi girin');
      }

      _isLoading.value = true;
      await _authRepository.sendPasswordResetEmail(emailController.text);
      _errorHandler.handleSuccess('Şifre sıfırlama bağlantısı gönderildi');
    } catch (e) {
      _lastError.value = e.toString();
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      _isLoading.value = true;
      await _authRepository.updatePassword(newPassword);
      _errorHandler.handleSuccess('Şifre güncellendi');
    } catch (e) {
      _lastError.value = e.toString();
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      _isLoading.value = true;
      await _authRepository.updateEmail(newEmail);
      _errorHandler.handleSuccess('E-posta güncellendi');
    } catch (e) {
      _lastError.value = e.toString();
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> reauthenticate(String email, String password) async {
    try {
      _isLoading.value = true;
      await _authRepository.reauthenticate(email, password);
      _errorHandler.handleSuccess('Kimlik doğrulama başarılı');
    } catch (e) {
      _lastError.value = e.toString();
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
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
    super.onClose();
  }
}
