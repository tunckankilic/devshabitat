import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import '../repositories/auth_repository.dart';
import '../core/services/error_handler_service.dart';
import '../services/feature_gate_service.dart';
import '../services/progressive_onboarding_service.dart';
import '../services/auth_migration_service.dart';
import '../models/enhanced_user_model.dart';
import 'email_auth_controller.dart';
import 'auth_state_controller.dart';

class AuthController extends GetxController {
  final EmailAuthController _emailAuth;
  final AuthStateController _authState;
  final AuthRepository _authRepository;
  final ErrorHandlerService _errorHandler;
  final Logger _logger = Get.find<Logger>();
  final FeatureGateService _featureGateService;
  final AuthMigrationService _migrationService =
      Get.find<AuthMigrationService>();

  final Rx<User?> _firebaseUser = Rx<User?>(null);
  final RxMap<String, dynamic> _userProfile = RxMap<String, dynamic>();
  final RxBool _isLoading = false.obs;
  final RxString _lastError = ''.obs;
  final RxBool _isPasswordVisible = false.obs;
  final githubUsernameController = TextEditingController();

  AuthController({
    required EmailAuthController emailAuth,
    required AuthStateController authState,
    required AuthRepository authRepository,
    required ErrorHandlerService errorHandler,
    required FeatureGateService featureGateService,
  }) : _emailAuth = emailAuth,
       _authState = authState,
       _authRepository = authRepository,
       _errorHandler = errorHandler,
       _featureGateService = featureGateService;

  User? get currentUser => _firebaseUser.value;
  Map<String, dynamic> get userProfile => _userProfile;
  bool get isLoading => _isLoading.value;
  String get lastError => _lastError.value;
  bool get isPasswordVisible => _isPasswordVisible.value;

  void togglePasswordVisibility() {
    _isPasswordVisible.value = !_isPasswordVisible.value;
  }

  @override
  void onInit() {
    super.onInit();
    _firebaseUser.bindStream(_authRepository.authStateChanges);
    ever(_firebaseUser, _setInitialScreen);
  }

  Timer? _navigationTimer;
  bool _isNavigating = false;

  void _setInitialScreen(User? user) {
    _navigationTimer?.cancel();
    _navigationTimer = Timer(const Duration(milliseconds: 500), () {
      if (_isNavigating) return;

      if (user == null) {
        _handleUnauthenticatedUser();
      } else {
        _handleAuthenticatedUser();
      }
    });
  }

  void _handleUnauthenticatedUser() {
    final currentRoute = Get.currentRoute;
    final protectedRoutes = [
      '/home',
      '/profile',
      '/settings',
      '/notifications',
    ];

    if (protectedRoutes.contains(currentRoute)) {
      _navigateToRoute('/login');
    }
  }

  void _handleAuthenticatedUser() {
    _loadUserProfile();
    final currentRoute = Get.currentRoute;
    final authRoutes = ['/login', '/register', '/forgot-password'];

    if (authRoutes.contains(currentRoute)) {
      _checkProfileAndNavigate();
    }
  }

  void _checkProfileAndNavigate() async {
    try {
      final currentUser = _firebaseUser.value;
      if (currentUser == null) return;

      await _migrationService.autoMigrateUserOnLogin(currentUser.uid);
      await _loadUserProfile();

      final userProfile = _userProfile;
      if (userProfile.isEmpty) {
        _navigateToRoute('/register/steps');
        return;
      }

      final enhancedUser = EnhancedUserModel.fromJson(userProfile);

      if (_featureGateService.canAccess('browsing', enhancedUser)) {
        _navigateToRoute('/home');
      } else {
        _showProgressiveOnboarding(enhancedUser);
      }
    } catch (e) {
      _logger.e('Error in profile check and navigation: $e');
      _navigateToRoute('/home');
    }
  }

  Future<void> _showProgressiveOnboarding(EnhancedUserModel user) async {
    try {
      final result = await ProgressiveOnboardingService.showQuickSetup(
        user,
        targetFeature: 'browsing',
      );

      if (result == true) {
        await _loadUserProfile();
        _navigateToRoute('/home');
      } else {
        _navigateToRoute('/home');
      }
    } catch (e) {
      _logger.e('Error showing progressive onboarding: $e');
      _navigateToRoute('/home');
    }
  }

  void _navigateToRoute(String route) {
    if (_isNavigating) return;

    _isNavigating = true;
    Timer(const Duration(milliseconds: 100), () {
      Get.offAllNamed(route);
      _isNavigating = false;
    });
  }

  Future<void> _loadUserProfile() async {
    try {
      final currentUser = _firebaseUser.value;
      if (currentUser != null && currentUser.uid.isNotEmpty) {
        final profile = await _authRepository.getUserProfile(currentUser.uid);
        if (profile != null && profile.isNotEmpty) {
          _userProfile.assignAll(profile);
        }
      }
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
    }
  }

  Future<String?> signInWithGithub() async {
    try {
      _isLoading.value = true;
      _lastError.value = '';

      final accessToken = await _authRepository.getGithubAccessToken();
      if (accessToken == null) {
        _logger.i('GitHub sign in was cancelled or failed');
        return null;
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
        final profile = await _authRepository.getUserProfile(
          _firebaseUser.value!.uid,
        );
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
        final profile = await _authRepository.getUserProfile(
          _firebaseUser.value!.uid,
        );
        return profile?['githubUsername'];
      }
      return null;
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
      return null;
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw Exception('E-posta ve şifre alanları boş bırakılamaz');
      }

      _isLoading.value = true;
      _lastError.value = '';
      await _authRepository.signInWithEmailAndPassword(email, password);
      _errorHandler.handleSuccess('Giriş başarılı');
    } catch (e) {
      _lastError.value = e.toString();
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> createUserWithEmailAndPassword() =>
      _emailAuth.createUserWithEmailAndPassword();
  Future<void> sendPasswordResetEmail() => _emailAuth.sendPasswordResetEmail();
  Future<void> updatePassword(String newPassword) =>
      _emailAuth.updatePassword(newPassword);
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

  Future<void> refreshUserProfile() async {
    try {
      if (_firebaseUser.value != null) {
        await _loadUserProfile();
      }
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.AUTH_ERROR);
    }
  }

  @override
  void onClose() {
    _navigationTimer?.cancel();
    _emailAuth.dispose();
    githubUsernameController.dispose();
    super.onClose();
  }
}
