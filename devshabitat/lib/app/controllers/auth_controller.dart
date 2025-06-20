import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';
import '../core/services/error_handler_service.dart';
import '../routes/app_pages.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'social_auth_controller.dart';
import 'email_auth_controller.dart';
import 'auth_state_controller.dart';
import '../core/config/github_config.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthController extends GetxController {
  final SocialAuthController _socialAuth;
  final EmailAuthController _emailAuth;
  final AuthStateController _authState;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final AuthService _authService = Get.find();
  final StorageService _storageService = Get.find();

  final Rx<User?> _firebaseUser = Rx<User?>(null);
  final RxMap<String, dynamic> _userProfile = RxMap<String, dynamic>();
  final RxBool isLoading = false.obs;
  final githubUsernameController = TextEditingController();

  AuthController({
    required SocialAuthController socialAuth,
    required EmailAuthController emailAuth,
    required AuthStateController authState,
  })  : _socialAuth = socialAuth,
        _emailAuth = emailAuth,
        _authState = authState;

  User? get currentUser => _firebaseUser.value;
  Map<String, dynamic> get userProfile => _userProfile;

  @override
  void onInit() {
    super.onInit();
    _firebaseUser.bindStream(_auth.authStateChanges());
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
        final doc = await _firestore
            .collection('users')
            .doc(_firebaseUser.value!.uid)
            .get();
        if (doc.exists) {
          _userProfile.assignAll(doc.data() ?? {});
        }
      }
    } catch (e) {
      print('Kullanıcı profili yüklenirken hata: $e');
    }
  }

  Future<String?> getGithubToken() async {
    try {
      if (_firebaseUser.value != null) {
        final doc = await _firestore
            .collection('users')
            .doc(_firebaseUser.value!.uid)
            .collection('connections')
            .doc('github')
            .get();
        if (doc.exists) {
          return doc.data()?['accessToken'];
        }
      }
      return null;
    } catch (e) {
      print('GitHub token alınırken hata: $e');
      return null;
    }
  }

  Future<String?> getGithubUsername() async {
    try {
      if (_firebaseUser.value != null) {
        final doc = await _firestore
            .collection('users')
            .doc(_firebaseUser.value!.uid)
            .collection('connections')
            .doc('github')
            .get();
        if (doc.exists) {
          return doc.data()?['username'];
        }
      }
      return null;
    } catch (e) {
      print('GitHub kullanıcı adı alınırken hata: $e');
      return null;
    }
  }

  Future<void> signInWithGithub() async {
    try {
      isLoading.value = true;
      final token = await _socialAuth.signInWithGithub();

      if (token != null) {
        final githubAuthCredential = GithubAuthProvider.credential(token);
        final userCredential =
            await _auth.signInWithCredential(githubAuthCredential);

        // GitHub bilgilerini kaydet
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .collection('connections')
            .doc('github')
            .set({
          'accessToken': token,
          'username': githubUsernameController.text,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('GitHub ile giriş yapılırken hata: $e');
      Get.snackbar(
        'Hata',
        'GitHub ile giriş yapılamadı',
        snackPosition: SnackPosition.BOTTOM,
      );
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
      print('Google ile giriş yapılırken hata: $e');
      Get.snackbar(
        'Hata',
        'Google ile giriş yapılamadı',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

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

  // Sosyal medya işlemleri
  Future<void> signInWithApple() => _socialAuth.signInWithApple();
  Future<void> signInWithFacebook() => _socialAuth.signInWithFacebook();

  // Auth state işlemleri
  Future<void> signOut() => _authState.signOut();
  Future<void> deleteAccount() => _authState.deleteAccount();
  Future<void> verifyEmail() => _authState.verifyEmail();

  // Getters
  bool get isAuthLoading => _emailAuth.isLoading || _socialAuth.isLoading;
  String get lastError => _emailAuth.lastError.isEmpty
      ? _socialAuth.lastError
      : _emailAuth.lastError;
  AuthState get authState => _authState.authState;
  Map<String, dynamic>? get authProfile => _authState.userProfile;

  // Form controllers
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
