import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';
import '../core/services/error_handler_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final ErrorHandlerService _errorHandler;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final githubUsernameController = TextEditingController();

  final isLoading = false.obs;
  final Rx<User?> user = Rx<User?>(null);
  final isNewUser = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  AuthController({
    AuthRepository? authRepository,
    ErrorHandlerService? errorHandler,
  })  : _authRepository = authRepository ?? Get.find<AuthRepository>(),
        _errorHandler = errorHandler ?? Get.find<ErrorHandlerService>();

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
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

  bool get isAuthenticated => user.value != null;

  Future<void> signInWithEmailAndPassword() async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
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
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
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
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithApple() async {
    try {
      isLoading.value = true;
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      await _auth.signInWithCredential(oauthCredential);
    } catch (e) {
      print('Error signing in with Apple: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      isLoading.value = true;
      final LoginResult result = await _facebookAuth.login();
      if (result.status != LoginStatus.success) return;

      final AccessToken? accessToken = result.accessToken;
      if (accessToken == null) return;

      final userData = await _facebookAuth.getUserData();
      final OAuthCredential credential =
          FacebookAuthProvider.credential(accessToken.toString());
      await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Facebook: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
        _facebookAuth.logOut(),
      ]);
      _errorHandler.handleSuccess('Çıkış yapıldı');
    } catch (e) {
      _errorHandler.handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      isLoading.value = true;
      await user.value?.updateEmail(newEmail);
    } catch (e) {
      print('Error updating email: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      isLoading.value = true;
      await user.value?.updatePassword(newPassword);
    } catch (e) {
      print('Error updating password: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      isLoading.value = true;
      await user.value?.delete();
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
