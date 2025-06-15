import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

abstract class IAuthRepository {
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password);
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password);
  Future<UserCredential> signInWithGoogle();
  Future<UserCredential> signInWithApple();
  Future<UserCredential> signInWithFacebook();
  Future<void> signOut();
  Stream<User?> get authStateChanges;
}

class AuthRepository implements IAuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;

  AuthRepository({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FacebookAuth? facebookAuth,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _facebookAuth = facebookAuth ?? FacebookAuth.instance;

  @override
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign in aborted');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
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

      return await _auth.signInWithCredential(oauthCredential);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserCredential> signInWithFacebook() async {
    try {
      final LoginResult result = await _facebookAuth.login();
      if (result.status != LoginStatus.success) {
        throw Exception('Facebook login failed');
      }

      final credential =
          FacebookAuthProvider.credential(result.accessToken!.tokenString);

      return await _auth.signInWithCredential(credential);
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
  Stream<User?> get authStateChanges => _auth.authStateChanges();

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
        default:
          return Exception('Kimlik doğrulama hatası: ${e.message}');
      }
    }
    return Exception('Beklenmeyen bir hata oluştu: $e');
  }
}
