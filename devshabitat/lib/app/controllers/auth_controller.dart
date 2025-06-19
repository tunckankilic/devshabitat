import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';
import '../core/services/error_handler_service.dart';
import '../routes/app_pages.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final ErrorHandlerService _errorHandler;

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final githubUsernameController = TextEditingController();

  // Reactive state variables
  final _isLoading = false.obs;
  final _currentUser = Rxn<User>();
  final _userProfile = Rxn<Map<String, dynamic>>();
  final _authState = AuthState.initial.obs;
  final _lastError = ''.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  User? get currentUser => _currentUser.value;
  Map<String, dynamic>? get userProfile => _userProfile.value;
  AuthState get authState => _authState.value;
  String get lastError => _lastError.value;

  AuthController({
    required AuthRepository authRepository,
    required ErrorHandlerService errorHandler,
  })  : _authRepository = authRepository,
        _errorHandler = errorHandler;

  @override
  void onInit() {
    super.onInit();
    _initializeAuthState();
  }

  void _initializeAuthState() {
    _authRepository.authStateChanges.listen((user) async {
      _currentUser.value = user;
      if (user != null) {
        _authState.value = AuthState.authenticated;
        // Kullanıcı profilini yükle
        _userProfile.value = await _authRepository.getUserProfile(user.uid);
        Get.offAllNamed(Routes.MAIN);
      } else {
        _authState.value = AuthState.unauthenticated;
        _userProfile.value = null;
        Get.offAllNamed(Routes.LOGIN);
      }
    });
  }

  Future<void> signInWithEmailAndPassword() async {
    try {
      _isLoading.value = true;
      _lastError.value = '';
      await _authRepository.signInWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );
      _errorHandler.handleSuccess('Giriş başarılı');
    } catch (e) {
      _lastError.value = e.toString();
      _errorHandler.handleError(e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
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
      _errorHandler.handleError(e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading.value = true;
      _lastError.value = '';
      await _authRepository.signInWithGoogle();
      _errorHandler.handleSuccess('Google ile giriş başarılı');
    } catch (e) {
      _lastError.value = e.toString();
      _errorHandler.handleError(e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signInWithApple() async {
    try {
      _isLoading.value = true;
      _lastError.value = '';
      await _authRepository.signInWithApple();
      _errorHandler.handleSuccess('Apple ile giriş başarılı');
    } catch (e) {
      _lastError.value = e.toString();
      _errorHandler.handleError(e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      _isLoading.value = true;
      _lastError.value = '';
      await _authRepository.signInWithFacebook();
      _errorHandler.handleSuccess('Facebook ile giriş başarılı');
    } catch (e) {
      _lastError.value = e.toString();
      _errorHandler.handleError(e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signInWithGithub() async {
    try {
      _isLoading.value = true;
      _lastError.value = '';
      await _authRepository.signInWithGithub();
      _errorHandler.handleSuccess('GitHub ile giriş başarılı');
    } catch (e) {
      _lastError.value = e.toString();
      _errorHandler.handleError(e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading.value = true;
      await _authRepository.signOut();
      _errorHandler.handleSuccess('Çıkış yapıldı');
    } catch (e) {
      _lastError.value = e.toString();
      _errorHandler.handleError(e);
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
      _errorHandler.handleError(e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> verifyEmail() async {
    try {
      _isLoading.value = true;
      await _authRepository.verifyEmail();
      _errorHandler.handleSuccess('Doğrulama e-postası gönderildi');
    } catch (e) {
      _lastError.value = e.toString();
      _errorHandler.handleError(e);
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
      _errorHandler.handleError(e);
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
      _errorHandler.handleError(e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      _isLoading.value = true;
      await _authRepository.deleteAccount();
      _errorHandler.handleSuccess('Hesap silindi');
    } catch (e) {
      _lastError.value = e.toString();
      _errorHandler.handleError(e);
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
      _errorHandler.handleError(e);
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
    githubUsernameController.dispose();
    super.onClose();
  }
}
