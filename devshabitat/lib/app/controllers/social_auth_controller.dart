import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/auth_repository.dart';
import '../core/services/error_handler_service.dart';
import '../routes/app_pages.dart';

class SocialAuthController extends GetxController {
  final AuthRepository _authRepository;
  final ErrorHandlerService _errorHandler;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _isLoading = false.obs;
  final _lastError = ''.obs;

  bool get isLoading => _isLoading.value;
  String get lastError => _lastError.value;

  SocialAuthController({
    required AuthRepository authRepository,
    required ErrorHandlerService errorHandler,
  })  : _authRepository = authRepository,
        _errorHandler = errorHandler;

  Future<void> signInWithGoogle() async {
    try {
      _isLoading.value = true;
      _lastError.value = '';

      final GoogleSignInAccount? googleUser =
          await _authRepository.googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google girişi iptal edildi');

      final methods = await _authRepository.auth
          .fetchSignInMethodsForEmail(googleUser.email);
      if (methods.isEmpty) {
        Get.toNamed(Routes.REGISTER, arguments: {
          'email': googleUser.email,
          'displayName': googleUser.displayName,
          'photoURL': googleUser.photoUrl,
          'provider': 'google'
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _authRepository.auth.signInWithCredential(credential);
      await _handleSocialSignIn(userCredential.user!);
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

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (appleCredential.email != null) {
        final methods = await _authRepository.auth
            .fetchSignInMethodsForEmail(appleCredential.email!);
        if (methods.isEmpty) {
          Get.toNamed(Routes.REGISTER, arguments: {
            'email': appleCredential.email,
            'displayName':
                '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                    .trim(),
            'provider': 'apple'
          });
          return;
        }
      }

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential =
          await _authRepository.auth.signInWithCredential(oauthCredential);
      await _handleSocialSignIn(userCredential.user!);
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

      final LoginResult result = await _authRepository.facebookAuth.login();
      if (result.status != LoginStatus.success) {
        throw Exception('Facebook girişi başarısız');
      }

      final userData = await _authRepository.facebookAuth.getUserData();
      if (userData['email'] == null) {
        throw Exception('Facebook email bilgisi alınamadı');
      }

      final methods = await _authRepository.auth
          .fetchSignInMethodsForEmail(userData['email']);
      if (methods.isEmpty) {
        Get.toNamed(Routes.REGISTER, arguments: {
          'email': userData['email'],
          'displayName': userData['name'],
          'photoURL': userData['picture']?['data']?['url'],
          'provider': 'facebook'
        });
        return;
      }

      final AccessToken accessToken = result.accessToken!;
      final OAuthCredential credential =
          FacebookAuthProvider.credential(accessToken.token);
      final userCredential =
          await _authRepository.auth.signInWithCredential(credential);
      await _handleSocialSignIn(userCredential.user!);
      _errorHandler.handleSuccess('Facebook ile giriş başarılı');
    } catch (e) {
      _lastError.value = e.toString();
      _errorHandler.handleError(e);
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
      _errorHandler.handleError(e);
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _handleSocialSignIn(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'id': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
