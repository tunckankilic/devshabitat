import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';
import '../core/services/error_handler_service.dart';
import '../routes/app_pages.dart';
import 'email_auth_controller.dart';
import 'auth_state_controller.dart';
import '../core/config/github_config.dart';
import '../services/storage_service.dart';

class AuthController extends GetxController {
  final EmailAuthController _emailAuth;
  final AuthStateController _authState;
  final AuthRepository _authRepository;
  final ErrorHandlerService _errorHandler;
  final StorageService _storageService = Get.find();

  final Rx<User?> _firebaseUser = Rx<User?>(null);
  final RxMap<String, dynamic> _userProfile = RxMap<String, dynamic>();
  final RxBool _isLoading = false.obs;
  final RxString _lastError = ''.obs;
  final githubUsernameController = TextEditingController();

  AuthController({
    required EmailAuthController emailAuth,
    required AuthStateController authState,
    required AuthRepository authRepository,
    required ErrorHandlerService errorHandler,
  })  : _emailAuth = emailAuth,
        _authState = authState,
        _authRepository = authRepository,
        _errorHandler = errorHandler;

  User? get currentUser => _firebaseUser.value;
  Map<String, dynamic> get userProfile => _userProfile;
  bool get isLoading => _isLoading.value;
  String get lastError => _lastError.value;

  @override
  void onInit() {
    super.onInit();
    _firebaseUser.bindStream(_authRepository.authStateChanges);
    ever(_firebaseUser, _setInitialScreen);
  }

  void _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAllNamed('/login');
    } else {
      _loadUserProfile();
      Get.offAllNamed('/home');
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      if (_firebaseUser.value != null) {
        final profile =
            await _authRepository.getUserProfile(_firebaseUser.value!.uid);
        if (profile != null) {
          _userProfile.assignAll(profile);
        }
      }
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading.value = true;
      _lastError.value = '';

      final credential = await _authRepository.signInWithGoogle();
      _errorHandler.handleSuccess('Google ile giriş başarılı');
    } catch (e) {
      _lastError.value = e.toString();
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signInWithApple() async {
    try {
      _isLoading.value = true;
      _lastError.value = '';

      final credential = await _authRepository.signInWithApple();
      _errorHandler.handleSuccess('Apple ile giriş başarılı');
    } catch (e) {
      _lastError.value = e.toString();
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      _isLoading.value = true;
      _lastError.value = '';

      final credential = await _authRepository.signInWithFacebook();
      _errorHandler.handleSuccess('Facebook ile giriş başarılı');
    } catch (e) {
      _lastError.value = e.toString();
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String?> signInWithGithub() async {
    try {
      _isLoading.value = true;
      _lastError.value = '';

      final accessToken = await _authRepository.getGithubAccessToken();
      if (accessToken == null) {
        throw Exception('GitHub ile giriş yapılamadı. Lütfen tekrar deneyin.');
      }

      return accessToken;
    } catch (e) {
      _lastError.value = e.toString();
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String?> getGithubToken() async {
    try {
      if (_firebaseUser.value != null) {
        final profile =
            await _authRepository.getUserProfile(_firebaseUser.value!.uid);
        return profile?['githubToken'];
      }
      return null;
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
      return null;
    }
  }

  Future<String?> getGithubUsername() async {
    try {
      if (_firebaseUser.value != null) {
        final profile =
            await _authRepository.getUserProfile(_firebaseUser.value!.uid);
        return profile?['githubUsername'];
      }
      return null;
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
      return null;
    }
  }

  // Email auth delegations
  Future<void> signInWithEmailAndPassword() =>
      _emailAuth.signInWithEmailAndPassword();
  Future<void> createUserWithEmailAndPassword() =>
      _emailAuth.createUserWithEmailAndPassword();
  Future<void> sendPasswordResetEmail() => _emailAuth.sendPasswordResetEmail();
  Future<void> updatePassword(String newPassword) =>
      _emailAuth.updatePassword(newPassword);
  Future<void> updateEmail(String newEmail) => _emailAuth.updateEmail(newEmail);
  Future<void> reauthenticate(String email, String password) =>
      _emailAuth.reauthenticate(email, password);

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _authRepository.deleteAccount();
      _errorHandler.handleSuccess('Hesabınız başarıyla silindi');
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
    }
  }

  Future<void> verifyEmail() => _authState.verifyEmail();

  bool get isAuthLoading => _emailAuth.isLoading || isLoading;
  AuthState get authState => _authState.authState;
  Map<String, dynamic>? get authProfile => _authState.userProfile;

  TextEditingController get emailController => _emailAuth.emailController;
  TextEditingController get passwordController => _emailAuth.passwordController;
  TextEditingController get confirmPasswordController =>
      _emailAuth.confirmPasswordController;
  TextEditingController get usernameController => _emailAuth.usernameController;

  @override
  void onClose() {
    _emailAuth.dispose();
    githubUsernameController.dispose();
    super.onClose();
  }
}
