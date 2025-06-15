import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

class EnhancedAuthRepositoryImpl extends GetxService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;

  // GitHub OAuth2 yapılandırması
  static const String _githubClientId = 'YOUR_GITHUB_CLIENT_ID';
  static const String _githubClientSecret = 'YOUR_GITHUB_CLIENT_SECRET';
  static const String _githubRedirectUri =
      'YOUR_APP_SCHEME://oauth2redirect/github';
  static const String _githubAuthUrl =
      'https://github.com/login/oauth/authorize';
  static const String _githubTokenUrl =
      'https://github.com/login/oauth/access_token';
  static const String _githubApiUrl = 'https://api.github.com/user';

  EnhancedAuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FacebookAuth? facebookAuth,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _facebookAuth = facebookAuth ?? FacebookAuth.instance;

  // E-posta/Şifre ile Giriş
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  // Google ile Giriş
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw 'Google girişi iptal edildi';

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      developer.log('Google girişi hatası: $e');
      rethrow;
    }
  }

  // Facebook ile Giriş
  Future<UserCredential> signInWithFacebook() async {
    try {
      final LoginResult result = await _facebookAuth.login();
      if (result.status != LoginStatus.success) {
        throw 'Facebook girişi başarısız';
      }

      final AccessToken accessToken = result.accessToken!;
      final OAuthCredential credential =
          FacebookAuthProvider.credential(accessToken.token);

      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      developer.log('Facebook girişi hatası: $e');
      rethrow;
    }
  }

  // Apple ile Giriş
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

      return await _firebaseAuth.signInWithCredential(oauthCredential);
    } catch (e) {
      developer.log('Apple girişi hatası: $e');
      rethrow;
    }
  }

  // GitHub ile Giriş
  Future<UserCredential> signInWithGithub() async {
    try {
      // 1. GitHub OAuth URL'ini oluştur
      final authUrl = Uri.parse(_githubAuthUrl).replace(
        queryParameters: {
          'client_id': _githubClientId,
          'redirect_uri': _githubRedirectUri,
          'scope': 'user:email',
          'state': _generateRandomString(32),
        },
      );

      // 2. Kullanıcıyı GitHub giriş sayfasına yönlendir
      final result = await FlutterWebAuth.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: _githubRedirectUri.split('://')[0],
      );

      // 3. Authorization code'u al
      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) throw 'GitHub girişi iptal edildi';

      // 4. Access token al
      final tokenResponse = await http.post(
        Uri.parse(_githubTokenUrl),
        headers: {'Accept': 'application/json'},
        body: {
          'client_id': _githubClientId,
          'client_secret': _githubClientSecret,
          'code': code,
          'redirect_uri': _githubRedirectUri,
        },
      );

      if (tokenResponse.statusCode != 200) {
        throw 'Access token alınamadı';
      }

      final tokenData = json.decode(tokenResponse.body);
      final accessToken = tokenData['access_token'];

      // 5. GitHub kullanıcı bilgilerini al
      final userResponse = await http.get(
        Uri.parse(_githubApiUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );

      if (userResponse.statusCode != 200) {
        throw 'Kullanıcı bilgileri alınamadı';
      }

      final userData = json.decode(userResponse.body);

      // 6. Firebase Custom Token oluştur
      final customToken = await _createFirebaseCustomToken(
        userData['id'].toString(),
        userData['login'],
        userData['email'] ?? '${userData['login']}@github.com',
      );

      // 7. Firebase ile giriş yap
      return await _firebaseAuth.signInWithCustomToken(customToken);
    } catch (e) {
      developer.log('GitHub girişi hatası: $e');
      rethrow;
    }
  }

  // E-posta Doğrulama
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      developer.log('E-posta doğrulama hatası: $e');
      rethrow;
    }
  }

  // Şifre Sıfırlama
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      developer.log('Şifre sıfırlama hatası: $e');
      rethrow;
    }
  }

  // Hesap Bağlama
  Future<void> linkWithCredential(AuthCredential credential) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.linkWithCredential(credential);
      }
    } catch (e) {
      developer.log('Hesap bağlama hatası: $e');
      rethrow;
    }
  }

  // Sağlayıcı Bağlama
  Future<void> linkWithProvider(String providerId) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        switch (providerId) {
          case 'google.com':
            await linkWithGoogle();
            break;
          case 'facebook.com':
            await linkWithFacebook();
            break;
          case 'apple.com':
            await linkWithApple();
            break;
          case 'github.com':
            await linkWithGithub();
            break;
        }
      }
    } catch (e) {
      developer.log('Sağlayıcı bağlama hatası: $e');
      rethrow;
    }
  }

  // Sağlayıcı Bağlantısını Kaldırma
  Future<void> unlinkProvider(String providerId) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.unlink(providerId);
      }
    } catch (e) {
      developer.log('Sağlayıcı bağlantısını kaldırma hatası: $e');
      rethrow;
    }
  }

  // Çıkış Yapma
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
        _facebookAuth.logOut(),
      ]);
    } catch (e) {
      developer.log('Çıkış yapma hatası: $e');
      rethrow;
    }
  }

  // Firebase Auth Hata Yönetimi
  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı';
      case 'wrong-password':
        return 'Hatalı şifre';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda';
      case 'weak-password':
        return 'Şifre çok zayıf';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi';
      case 'operation-not-allowed':
        return 'Bu işlem şu anda kullanılamıyor';
      case 'account-exists-with-different-credential':
        return 'Bu e-posta adresi farklı bir giriş yöntemiyle kullanılıyor';
      case 'credential-already-in-use':
        return 'Bu kimlik bilgisi zaten kullanımda';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakıldı';
      case 'invalid-verification-code':
        return 'Geçersiz doğrulama kodu';
      case 'invalid-verification-id':
        return 'Geçersiz doğrulama kimliği';
      case 'network-request-failed':
        return 'Ağ bağlantısı hatası';
      default:
        return 'Bir hata oluştu: ${e.message}';
    }
  }

  // Yardımcı Metodlar
  Future<void> linkWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw 'Google girişi iptal edildi';

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await linkWithCredential(credential);
  }

  Future<void> linkWithFacebook() async {
    final LoginResult result = await _facebookAuth.login();
    if (result.status != LoginStatus.success) {
      throw 'Facebook girişi başarısız';
    }

    final AccessToken accessToken = result.accessToken!;
    final OAuthCredential credential =
        FacebookAuthProvider.credential(accessToken.token);

    await linkWithCredential(credential);
  }

  Future<void> linkWithApple() async {
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

    await linkWithCredential(oauthCredential);
  }

  Future<void> linkWithGithub() async {
    final userCredential = await signInWithGithub();
    if (userCredential.user == null) throw 'GitHub bağlantısı başarısız';
  }

  // Yardımcı metodlar
  String _generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  Future<String> _createFirebaseCustomToken(
    String githubId,
    String githubUsername,
    String email,
  ) async {
    // Bu kısım backend'de yapılmalıdır
    // Firebase Admin SDK kullanarak custom token oluşturulmalıdır
    // Örnek bir backend endpoint'i:
    final response = await http.post(
      Uri.parse('YOUR_BACKEND_URL/create-custom-token'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'githubId': githubId,
        'githubUsername': githubUsername,
        'email': email,
      }),
    );

    if (response.statusCode != 200) {
      throw 'Custom token oluşturulamadı';
    }

    final data = json.decode(response.body);
    return data['token'];
  }
}
