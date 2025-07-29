import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final _isEmailValid = false.obs;
  final _emailVerificationStatus = ''.obs;
  final _additionalEmails = <String>[].obs;

  // Getters
  bool get isLoading => _isLoading.value;
  String get lastError => _lastError.value;
  bool get isEmailValid => _isEmailValid.value;
  String get emailVerificationStatus => _emailVerificationStatus.value;
  List<String> get additionalEmails => _additionalEmails;

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

      if (!_validateEmail(emailController.text)) {
        throw Exception('Geçerli bir email adresi girin');
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

  Future<void> sendEmailVerification() async {
    try {
      _isLoading.value = true;
      await _authRepository.verifyEmail();
      _errorHandler.handleSuccess('Doğrulama emaili gönderildi');
    } catch (e) {
      _lastError.value = e.toString();
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> resendEmailVerification() async {
    try {
      _isLoading.value = true;
      await _authRepository.verifyEmail();
      _errorHandler.handleSuccess('Doğrulama emaili tekrar gönderildi');
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

  // Multi-email support methods
  Future<void> addAdditionalEmail(String email) async {
    try {
      _isLoading.value = true;
      final user = _authRepository.currentUser;
      if (user != null) {
        await _authRepository.updateUserProfile({
          'additionalEmails': FieldValue.arrayUnion([email]),
        });
        _additionalEmails.add(email);
      }
      _errorHandler.handleSuccess('Ek email adresi eklendi');
    } catch (e) {
      _lastError.value = e.toString();
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> removeAdditionalEmail(String email) async {
    try {
      _isLoading.value = true;
      final user = _authRepository.currentUser;
      if (user != null) {
        await _authRepository.updateUserProfile({
          'additionalEmails': FieldValue.arrayRemove([email]),
        });
        _additionalEmails.remove(email);
      }
      _errorHandler.handleSuccess('Email adresi kaldırıldı');
    } catch (e) {
      _lastError.value = e.toString();
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<List<String>> getAdditionalEmails() async {
    try {
      final user = _authRepository.currentUser;
      if (user != null) {
        final profile = await _authRepository.getUserProfile(user.uid);
        if (profile != null && profile['additionalEmails'] != null) {
          final emails = List<String>.from(profile['additionalEmails']);
          _additionalEmails.assignAll(emails);
          return emails;
        }
      }
      return [];
    } catch (e) {
      _lastError.value = e.toString();
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
      return [];
    }
  }

  Future<bool> isEmailVerified() async {
    try {
      final user = _authRepository.currentUser;
      return user?.emailVerified ?? false;
    } catch (e) {
      _lastError.value = e.toString();
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
      return false;
    }
  }

  // Email validation methods
  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final isValid = emailRegex.hasMatch(email);
    _isEmailValid.value = isValid;
    return isValid;
  }

  void validateEmailOnChange(String email) {
    _validateEmail(email);
  }

  Future<void> checkEmailAvailability(String email) async {
    try {
      _emailVerificationStatus.value = 'checking';

      // Email format kontrolü
      if (!_validateEmail(email)) {
        _emailVerificationStatus.value = 'invalid';
        return;
      }

      // Firestore'da email kullanımda mı kontrol et
      final user = _authRepository.currentUser;
      if (user != null) {
        final existingUsers = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (existingUsers.docs.isNotEmpty) {
          _emailVerificationStatus.value = 'taken';
        } else {
          _emailVerificationStatus.value = 'available';
        }
      }
    } catch (e) {
      _emailVerificationStatus.value = 'error';
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      _isLoading.value = true;
      await _authRepository.verifyEmail();
      _emailVerificationStatus.value = 'sent';
      _errorHandler.handleSuccess('Doğrulama emaili gönderildi');
    } catch (e) {
      _emailVerificationStatus.value = 'error';
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
