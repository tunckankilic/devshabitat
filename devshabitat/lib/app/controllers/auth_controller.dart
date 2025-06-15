import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';
import '../core/services/error_handler_service.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final ErrorHandlerService _errorHandler;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final githubUsernameController = TextEditingController();

  final isLoading = false.obs;
  final user = Rxn<User>();
  final isNewUser = false.obs;

  AuthController({
    AuthRepository? authRepository,
    ErrorHandlerService? errorHandler,
  })  : _authRepository = authRepository ?? Get.find<AuthRepository>(),
        _errorHandler = errorHandler ?? Get.find<ErrorHandlerService>();

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_authRepository.authStateChanges);
    ever(user, _handleAuthStateChange);
  }

  void _handleAuthStateChange(User? user) {
    if (user != null) {
      // Kullanıcı profil bilgilerini kontrol et
      if (user.displayName == null || user.displayName!.isEmpty) {
        isNewUser.value = true;
        Get.offAllNamed('/register');
      } else {
        isNewUser.value = false;
        Get.offAllNamed('/home');
      }
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

  Future<void> signInWithEmailAndPassword() async {
    try {
      isLoading.value = true;
      await _authRepository.signInWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );
      _errorHandler.handleSuccess('Giriş başarılı');
    } catch (e) {
      _errorHandler.handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      if (passwordController.text != confirmPasswordController.text) {
        throw Exception('Şifreler eşleşmiyor');
      }

      isLoading.value = true;
      final userCredential =
          await _authRepository.createUserWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );

      // Kullanıcı adını güncelle
      await userCredential.user?.updateDisplayName(usernameController.text);

      _errorHandler.handleSuccess('Hesap oluşturuldu');
    } catch (e) {
      _errorHandler.handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final userCredential = await _authRepository.signInWithGoogle();

      // Kullanıcı adı kontrolü
      if (userCredential.user?.displayName == null ||
          userCredential.user?.displayName!.isEmpty == true) {
        isNewUser.value = true;
        Get.offAllNamed('/register');
      } else {
        _errorHandler.handleSuccess('Google ile giriş başarılı');
      }
    } catch (e) {
      _errorHandler.handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithApple() async {
    try {
      isLoading.value = true;
      final userCredential = await _authRepository.signInWithApple();

      // Kullanıcı adı kontrolü
      if (userCredential.user?.displayName == null ||
          userCredential.user?.displayName!.isEmpty == true) {
        isNewUser.value = true;
        Get.offAllNamed('/register');
      } else {
        _errorHandler.handleSuccess('Apple ile giriş başarılı');
      }
    } catch (e) {
      _errorHandler.handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      isLoading.value = true;
      final userCredential = await _authRepository.signInWithFacebook();

      // Kullanıcı adı kontrolü
      if (userCredential.user?.displayName == null ||
          userCredential.user?.displayName!.isEmpty == true) {
        isNewUser.value = true;
        Get.offAllNamed('/register');
      } else {
        _errorHandler.handleSuccess('Facebook ile giriş başarılı');
      }
    } catch (e) {
      _errorHandler.handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _authRepository.signOut();
      _errorHandler.handleSuccess('Çıkış yapıldı');
    } catch (e) {
      _errorHandler.handleError(e);
    } finally {
      isLoading.value = false;
    }
  }
}
