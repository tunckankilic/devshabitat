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
import 'email_auth_controller.dart';
import 'auth_state_controller.dart';
import '../core/config/github_config.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthController extends GetxController {
  final EmailAuthController _emailAuth;
  final AuthStateController _authState;
  final AuthRepository _authRepository;
  final ErrorHandlerService _errorHandler;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FacebookAuth _facebookAuth = FacebookAuth.instance;
  final AuthService _authService = AuthService();
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

  Future<void> signInWithGoogle() async {
    try {
      _isLoading.value = true;
      _lastError.value = '';

      await _googleSignIn.initialize();

      final GoogleSignInAccount? googleUser =
          await _googleSignIn.authenticate();
      if (googleUser == null) throw Exception('Google girişi iptal edildi');

      final methods = await _auth.fetchSignInMethodsForEmail(googleUser.email);
      if (methods.isEmpty) {
        Get.toNamed('/register', arguments: {
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
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
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
        final methods =
            await _auth.fetchSignInMethodsForEmail(appleCredential.email!);
        if (methods.isEmpty) {
          Get.toNamed('/register', arguments: {
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

      final userCredential = await _auth.signInWithCredential(oauthCredential);
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

      final LoginResult result = await _facebookAuth.login();
      if (result.status != LoginStatus.success) {
        throw Exception('Facebook girişi başarısız');
      }

      final userData = await _facebookAuth.getUserData();
      if (userData['email'] == null) {
        throw Exception('Facebook email bilgisi alınamadı');
      }

      final methods = await _auth.fetchSignInMethodsForEmail(userData['email']);
      if (methods.isEmpty) {
        Get.toNamed('/register', arguments: {
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
      final userCredential = await _auth.signInWithCredential(credential);
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
      await _authService.signOut();
    } catch (e) {
      Get.snackbar('Hata', 'Çıkış yapılırken bir hata oluştu');
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _authService.deleteAccount();
      Get.snackbar('Başarılı', 'Hesabınız başarıyla silindi');
    } catch (e) {
      Get.snackbar('Hata', 'Hesap silinirken bir hata oluştu');
      rethrow;
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
