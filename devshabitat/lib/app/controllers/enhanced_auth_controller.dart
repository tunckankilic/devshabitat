import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../repositories/enhanced_auth_repository.dart';
import '../models/enhanced_user_model.dart';
import '../core/services/error_handler_service.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class EnhancedAuthController extends GetxController {
  final EnhancedAuthRepository _authRepository;
  final ErrorHandlerService _errorHandler;

  // Reactive state variables
  final _isLoading = false.obs;
  final _currentUser = Rxn<EnhancedUserModel>();
  final _authState = AuthState.initial.obs;
  final _lastError = RxnString();

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final githubUsernameController = TextEditingController();

  // Getters
  bool get isLoading => _isLoading.value;
  EnhancedUserModel? get currentUser => _currentUser.value;
  AuthState get authState => _authState.value;
  String? get lastError => _lastError.value;

  EnhancedAuthController({
    required EnhancedAuthRepository authRepository,
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
      if (user != null) {
        await _loadUserProfile(user.uid);
      } else {
        _currentUser.value = null;
        _authState.value = AuthState.unauthenticated;
      }
    });
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      _isLoading.value = true;
      final user = await _authRepository.getUserProfile(uid);
      _currentUser.value = user;
      _authState.value = AuthState.authenticated;
    } catch (e) {
      _errorHandler.handleError(e);
      _lastError.value = e.toString();
      _authState.value = AuthState.error;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signInWithEmailAndPassword() async {
    try {
      _isLoading.value = true;
      await _authRepository.signInWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );
      _errorHandler.handleSuccess('Giriş başarılı');
    } catch (e) {
      _errorHandler.handleError(e);
      _lastError.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    if (passwordController.text != confirmPasswordController.text) {
      _errorHandler.handleError('Şifreler eşleşmiyor');
      return;
    }

    try {
      _isLoading.value = true;
      await _authRepository.createUserWithEmailAndPassword(
        emailController.text,
        passwordController.text,
        usernameController.text,
      );
      _errorHandler.handleSuccess('Hesap oluşturuldu');
    } catch (e) {
      _errorHandler.handleError(e);
      _lastError.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading.value = true;
      await _authRepository.signInWithGoogle();
      _errorHandler.handleSuccess('Google ile giriş başarılı');
    } catch (e) {
      _errorHandler.handleError(e);
      _lastError.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signInWithApple() async {
    try {
      _isLoading.value = true;
      await _authRepository.signInWithApple();
      _errorHandler.handleSuccess('Apple ile giriş başarılı');
    } catch (e) {
      _errorHandler.handleError(e);
      _lastError.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      _isLoading.value = true;
      await _authRepository.signInWithFacebook();
      _errorHandler.handleSuccess('Facebook ile giriş başarılı');
    } catch (e) {
      _errorHandler.handleError(e);
      _lastError.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signInWithGithub() async {
    try {
      _isLoading.value = true;
      await _authRepository.signInWithGithub();
      _errorHandler.handleSuccess('GitHub ile giriş başarılı');
    } catch (e) {
      _errorHandler.handleError(e);
      _lastError.value = e.toString();
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
      _errorHandler.handleError(e);
      _lastError.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> sendPasswordResetEmail() async {
    try {
      _isLoading.value = true;
      await _authRepository.sendPasswordResetEmail(emailController.text);
      _errorHandler.handleSuccess('Şifre sıfırlama e-postası gönderildi');
    } catch (e) {
      _errorHandler.handleError(e);
      _lastError.value = e.toString();
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
      _errorHandler.handleError(e);
      _lastError.value = e.toString();
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
      _errorHandler.handleError(e);
      _lastError.value = e.toString();
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
      _errorHandler.handleError(e);
      _lastError.value = e.toString();
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
      _errorHandler.handleError(e);
      _lastError.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> reauthenticate(String password) async {
    try {
      _isLoading.value = true;
      await _authRepository.reauthenticate(password);
      _errorHandler.handleSuccess('Kimlik doğrulama başarılı');
    } catch (e) {
      _errorHandler.handleError(e);
      _lastError.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> linkWithGoogle() async {
    try {
      _isLoading.value = true;
      await _authRepository.linkWithGoogle();
      _errorHandler.handleSuccess('Google hesabı bağlandı');
    } catch (e) {
      _errorHandler.handleError(e);
      _lastError.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> linkWithApple() async {
    try {
      _isLoading.value = true;
      await _authRepository.linkWithApple();
      _errorHandler.handleSuccess('Apple hesabı bağlandı');
    } catch (e) {
      _errorHandler.handleError(e);
      _lastError.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> linkWithFacebook() async {
    try {
      _isLoading.value = true;
      await _authRepository.linkWithFacebook();
      _errorHandler.handleSuccess('Facebook hesabı bağlandı');
    } catch (e) {
      _errorHandler.handleError(e);
      _lastError.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> linkWithGithub() async {
    try {
      _isLoading.value = true;
      await _authRepository.linkWithGithub();
      _errorHandler.handleSuccess('GitHub hesabı bağlandı');
    } catch (e) {
      _errorHandler.handleError(e);
      _lastError.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> unlinkProvider(String providerId) async {
    try {
      _isLoading.value = true;
      await _authRepository.unlinkProvider(providerId);
      _errorHandler.handleSuccess('Hesap bağlantısı kaldırıldı');
    } catch (e) {
      _errorHandler.handleError(e);
      _lastError.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      _isLoading.value = true;
      final updatedUser = _currentUser.value?.copyWith(
        displayName: displayName,
        photoURL: photoURL,
        preferences: preferences,
      );

      if (updatedUser != null) {
        await _authRepository.updateUserProfile(updatedUser);
        _errorHandler.handleSuccess('Profil güncellendi');
      }
    } catch (e) {
      _errorHandler.handleError(e);
      _lastError.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateUserConnections(Map<String, dynamic> connections) async {
    try {
      _isLoading.value = true;
      await _authRepository.updateUserConnections(connections);
      _errorHandler.handleSuccess('Bağlantılar güncellendi');
    } catch (e) {
      _errorHandler.handleError(e);
      _lastError.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    try {
      _isLoading.value = true;
      await _authRepository.updateUserPreferences(preferences);
      _errorHandler.handleSuccess('Tercihler güncellendi');
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
    githubUsernameController.dispose();
    super.onClose();
  }
}
