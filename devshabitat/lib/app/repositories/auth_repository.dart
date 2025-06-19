import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:github_signin_promax/github_signin_promax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/config/github_config.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:get/get.dart';

abstract class IAuthRepository {
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password);
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password, String username);
  Future<UserCredential> signInWithGoogle();
  Future<UserCredential> signInWithGithub();
  Future<UserCredential> signInWithFacebook();
  Future<UserCredential> signInWithApple();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> verifyEmail();
  Future<void> updatePassword(String newPassword);
  Future<void> updateEmail(String newEmail);
  Future<void> deleteAccount();
  Future<void> reauthenticate(String email, String password);
  Future<List<String>> getUserConnections();
  Future<void> addConnection(String userId);
  Future<void> removeConnection(String userId);
  Future<Map<String, dynamic>?> getUserProfile(String userId);
  Future<void> linkWithGithub();
  Future<void> unlinkProvider(String providerId);
  Stream<User?> get authStateChanges;
  User? get currentUser;
}

class AuthRepository implements IAuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;
  final Logger _logger;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
    FacebookAuth? facebookAuth,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _facebookAuth = facebookAuth ?? FacebookAuth.instance,
        _logger = Get.find<Logger>();

  @override
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _updateLastSeen();
      return credential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'email': email,
        'displayName': username,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google girişi iptal edildi');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      await _handleSocialSignIn(userCredential.user!);
      return userCredential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserCredential> signInWithGithub() async {
    try {
      final params = GithubSignInParams(
        clientId: GitHubConfig.clientId,
        clientSecret: GitHubConfig.clientSecret,
        redirectUrl: GitHubConfig.redirectUrl,
        scopes: GitHubConfig.scope,
      );

      final result =
          await Navigator.of(Get.context!).push<GithubSignInResponse>(
        MaterialPageRoute(
          builder: (context) => GithubSigninScreen(
            params: params,
            headerColor: Colors.black,
            title: 'GitHub ile Giriş Yap',
          ),
        ),
      );

      if (result == null ||
          result.status != 'success' ||
          result.accessToken == null) {
        throw Exception('GitHub girişi iptal edildi');
      }

      final githubAuthCredential =
          GithubAuthProvider.credential(result.accessToken!);
      final userCredential =
          await _auth.signInWithCredential(githubAuthCredential);
      await _handleSocialSignIn(userCredential.user!);
      return userCredential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserCredential> signInWithApple() async {
    try {
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

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      await _handleSocialSignIn(userCredential.user!);
      return userCredential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserCredential> signInWithFacebook() async {
    try {
      final LoginResult result = await _facebookAuth.login();
      if (result.status != LoginStatus.success) {
        throw Exception('Facebook girişi başarısız');
      }

      final AccessToken accessToken = result.accessToken!;
      final OAuthCredential credential =
          FacebookAuthProvider.credential(accessToken.token);

      final userCredential = await _auth.signInWithCredential(credential);
      await _handleSocialSignIn(userCredential.user!);
      return userCredential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
        _facebookAuth.logOut(),
      ]);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> verifyEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    try {
      await _auth.currentUser?.updateEmail(newEmail);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> reauthenticate(String email, String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturum açmamış');

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<List<String>> getUserConnections() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturum açmamış');

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) throw Exception('Kullanıcı profili bulunamadı');

      final data = doc.data();
      return List<String>.from(data?['connections'] ?? []);
    } catch (e) {
      _logger.e('Bağlantılar alınamadı: $e');
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> addConnection(String userId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturum açmamış');

      final batch = _firestore.batch();

      // Mevcut kullanıcının bağlantılarını güncelle
      batch.update(
        _firestore.collection('users').doc(user.uid),
        {
          'connections': FieldValue.arrayUnion([userId]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      // Hedef kullanıcının bağlantılarını güncelle
      batch.update(
        _firestore.collection('users').doc(userId),
        {
          'connections': FieldValue.arrayUnion([user.uid]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();
    } catch (e) {
      _logger.e('Bağlantı eklenemedi: $e');
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> removeConnection(String userId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturum açmamış');

      final batch = _firestore.batch();

      // Mevcut kullanıcının bağlantılarını güncelle
      batch.update(
        _firestore.collection('users').doc(user.uid),
        {
          'connections': FieldValue.arrayRemove([userId]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      // Hedef kullanıcının bağlantılarını güncelle
      batch.update(
        _firestore.collection('users').doc(userId),
        {
          'connections': FieldValue.arrayRemove([user.uid]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();
    } catch (e) {
      _logger.e('Bağlantı kaldırılamadı: $e');
      throw _handleAuthException(e);
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      _logger.e('Kullanıcı profili alınamadı: $e');
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> linkWithGithub() async {
    try {
      final params = GithubSignInParams(
        clientId: GitHubConfig.clientId,
        clientSecret: GitHubConfig.clientSecret,
        redirectUrl: GitHubConfig.redirectUrl,
        scopes: GitHubConfig.scope,
      );

      final result =
          await Navigator.of(Get.context!).push<GithubSignInResponse>(
        MaterialPageRoute(
          builder: (context) => GithubSigninScreen(
            params: params,
            headerColor: Colors.black,
            title: 'GitHub Hesabını Bağla',
          ),
        ),
      );

      if (result == null ||
          result.status != 'success' ||
          result.accessToken == null) {
        throw Exception('GitHub bağlantısı iptal edildi');
      }

      final githubAuthCredential =
          GithubAuthProvider.credential(result.accessToken!);
      await _auth.currentUser?.linkWithCredential(githubAuthCredential);
    } catch (e) {
      _logger.e('GitHub hesabı bağlanırken hata: $e');
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> unlinkProvider(String providerId) async {
    try {
      await _auth.currentUser?.unlink(providerId);
    } catch (e) {
      _logger.e('Provider bağlantısı kesilirken hata: $e');
      throw _handleAuthException(e);
    }
  }

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  // Yardımcı metodlar
  Future<void> _handleSocialSignIn(User user) async {
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'id': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastSeen': FieldValue.serverTimestamp(),
        });
      } else {
        await _updateLastSeen();
      }
    } catch (e) {
      _logger.e('Sosyal giriş işlenirken hata: $e');
      throw _handleAuthException(e);
    }
  }

  Future<void> _updateLastSeen() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      _logger.e('Son görülme zamanı güncellenemedi: $e');
    }
  }

  Exception _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return Exception('Kullanıcı bulunamadı');
        case 'wrong-password':
          return Exception('Hatalı şifre');
        case 'email-already-in-use':
          return Exception('Bu e-posta adresi zaten kullanımda');
        case 'weak-password':
          return Exception('Şifre çok zayıf');
        case 'invalid-email':
          return Exception('Geçersiz e-posta adresi');
        case 'operation-not-allowed':
          return Exception('Bu işlem şu anda kullanılamıyor');
        case 'account-exists-with-different-credential':
          return Exception(
              'Bu e-posta adresi farklı bir giriş yöntemi ile kullanılıyor');
        case 'requires-recent-login':
          return Exception(
              'Bu işlem için son zamanlarda giriş yapmanız gerekiyor');
        case 'credential-already-in-use':
          return Exception('Bu kimlik bilgisi zaten kullanımda');
        case 'provider-already-linked':
          return Exception('Bu giriş yöntemi zaten bağlı');
        case 'no-such-provider':
          return Exception('Böyle bir giriş yöntemi bulunamadı');
        case 'invalid-credential':
          return Exception('Geçersiz kimlik bilgisi');
        default:
          return Exception('Kimlik doğrulama hatası: ${e.message}');
      }
    }
    return Exception('Beklenmeyen bir hata oluştu: $e');
  }
}
