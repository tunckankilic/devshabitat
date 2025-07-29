import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:get/get.dart';
import '../services/github_oauth_service.dart';
import '../constants/app_strings.dart';

abstract class IAuthRepository {
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password);
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password, String username);
  Future<UserCredential> signInWithGoogle();
  Future<UserCredential> signInWithGithub();
//  Future<UserCredential> signInWithFacebook();
  Future<UserCredential> signInWithApple();
  Future<void> signOut();
  Future<void> signOutFromAllDevices();
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
  Future<void> updateUserProfile(Map<String, dynamic> data);
  Stream<User?> get authStateChanges;
  User? get currentUser;
}

class AuthRepository implements IAuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  // final FacebookAuth _facebookAuth;
  final GitHubOAuthService _githubOAuthService;
  final Logger _logger;

  // Getters for auth instances
  FirebaseAuth get auth => _auth;
  GoogleSignIn get googleSignIn => _googleSignIn;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
    required GitHubOAuthService githubOAuthService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
        _githubOAuthService = githubOAuthService,
        _logger = Get.find<Logger>() {
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    await _googleSignIn.initialize();
  }

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

  // Email çakışmalarını kontrol et ve yönet
  Future<void> _handleEmailCollision(String email, String provider) async {
    try {
      // Email için mevcut giriş yöntemlerini kontrol et
      final signInMethods = await _auth.fetchSignInMethodsForEmail(email);

      if (signInMethods.isEmpty) {
        return; // Email kullanılmıyor, sorun yok
      }

      // Mevcut hesabın sağlayıcılarını kontrol et
      if (signInMethods.contains(provider)) {
        throw Exception(AppStrings.emailAlreadyInUse);
      }

      // Kullanıcıya hangi sağlayıcıları kullanabileceğini bildir
      final availableProviders = signInMethods.map((method) {
        switch (method) {
          case 'google.com':
            return 'Google';
          case 'facebook.com':
            return 'Facebook';
          case 'apple.com':
            return 'Apple';
          case 'github.com':
            return 'GitHub';
          case 'password':
            return 'Email/Şifre';
          default:
            return method;
        }
      }).join(', ');

      throw Exception(
          'This email is already in use with the following providers: $availableProviders');
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sosyal giriş öncesi email kontrolü
  Future<void> _checkEmailBeforeSocialSignIn(
      String email, String provider) async {
    try {
      await _handleEmailCollision(email, provider);
    } catch (e) {
      _logger.e('Email collision detected: $e');
      throw Exception(e);
    }
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    try {
      if (!_googleSignIn.supportsAuthenticate()) {
        throw Exception(AppStrings.googleLoginNotSupported);
      }

      final googleUser = await _googleSignIn.authenticate();

      // Email çakışmasını kontrol et
      await _checkEmailBeforeSocialSignIn(googleUser.email, 'google.com');

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      await handleSocialSignIn(userCredential.user!);
      return userCredential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

/*
  @override

*/
  @override
  Future<UserCredential> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Email çakışmasını kontrol et
      if (appleCredential.email != null) {
        await _checkEmailBeforeSocialSignIn(
            appleCredential.email!, 'apple.com');
      }

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      await handleSocialSignIn(userCredential.user!);
      return userCredential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserCredential> signInWithGithub() async {
    try {
      final accessToken = await _githubOAuthService.getAccessToken();

      if (accessToken == null) {
        _logger.w('GitHub OAuth flow failed or was cancelled by user');
        throw Exception(AppStrings.githubLoginFailed);
      }

      // GitHub'dan kullanıcı bilgilerini al
      final userInfo = await _githubOAuthService.getUserInfo(accessToken);
      final email = userInfo?['email'] as String?;

      if (email != null) {
        // Email çakışmasını kontrol et
        await _checkEmailBeforeSocialSignIn(email, 'github.com');
      }

      final githubAuthCredential = GithubAuthProvider.credential(accessToken);
      final userCredential =
          await _auth.signInWithCredential(githubAuthCredential);

      if (userCredential.user == null) {
        _logger.e('Firebase authentication failed');
        throw Exception(AppStrings.errorAuth);
      }

      await handleSocialSignIn(userCredential.user!);

      _logger.i('GitHub login successful: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      _logger.e('Error during GitHub login: $e');
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> signOutFromAllDevices() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
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
      if (user == null) throw Exception(AppStrings.userNotLoggedIn);

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) throw Exception(AppStrings.userProfileNotFound);

      final data = doc.data();
      return List<String>.from(data?['connections'] ?? []);
    } catch (e) {
      _logger.e('Connections not found: $e');
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> addConnection(String userId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception(AppStrings.userNotLoggedIn);

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
      _logger.e('Connection not added: $e');
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> removeConnection(String userId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception(AppStrings.userNotLoggedIn);

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
      _logger.e('Connection not removed: $e');
      throw _handleAuthException(e);
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      _logger.e('User profile not found: $e');
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> linkWithGithub() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception(AppStrings.userNotLoggedIn);
      }

      // GitHub OAuth akışını başlat
      final accessToken = await _githubOAuthService.getAccessToken();

      if (accessToken == null) {
        _logger.w('GitHub OAuth flow failed or was cancelled by user');
        throw Exception(AppStrings.githubLoginFailed);
      }

      // GitHub hesabını mevcut hesaba bağla
      final githubAuthCredential = GithubAuthProvider.credential(accessToken);
      await currentUser.linkWithCredential(githubAuthCredential);

      _logger.i('GitHub account successfully linked: ${currentUser.email}');

      // Firestore'daki kullanıcı belgesini güncelle
      await _firestore.collection('users').doc(currentUser.uid).update({
        'linkedProviders': FieldValue.arrayUnion(['github.com']),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.e('Error linking GitHub account: $e');

      if (e is FirebaseAuthException) {
        if (e.code == 'provider-already-linked') {
          throw Exception(AppStrings.githubAccountAlreadyLinked);
        } else if (e.code == 'credential-already-in-use') {
          throw Exception(AppStrings.githubAccountAlreadyInUse);
        }
      }

      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> unlinkProvider(String providerId) async {
    try {
      await _auth.currentUser?.unlink(providerId);
    } catch (e) {
      _logger.e('Error unlinking provider: $e');
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      _logger.e('Error updating user profile: $e');
      throw _handleAuthException(e);
    }
  }

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  // Sosyal giriş sonrası kullanıcı profili oluştur veya güncelle
  Future<void> handleSocialSignIn(User user,
      {Map<String, dynamic>? additionalData}) async {
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final Map<String, dynamic> userData = {
        'id': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'lastSeen': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (!userDoc.exists) {
        // Yeni kullanıcı - ilk profil oluşturma
        userData.addAll({
          'createdAt': FieldValue.serverTimestamp(),
          'isProfileComplete': false,
          'registrationStep': 'basicInfo',
          'authProvider': _determineAuthProvider(user),
          'skills': [],
          'interests': [],
          'connections': [],
          'notifications': {
            'email': true,
            'push': true,
            'marketing': false,
          },
          'privacySettings': {
            'profileVisibility': 'public',
            'showEmail': false,
            'showLocation': true,
          },
          ...?additionalData,
        });

        // Sağlayıcıya özel varsayılan ayarlar
        _addProviderSpecificDefaults(userData, user);

        await _firestore.collection('users').doc(user.uid).set(userData);

        // Yeni kullanıcı için profil tamamlama yönlendirmesi
        Get.offAllNamed('/register/complete-profile', arguments: {
          'userId': user.uid,
          'isNewUser': true,
          'authProvider': userData['authProvider'],
        });
      } else {
        // Mevcut kullanıcı - sadece son görülme ve güncelleme zamanını güncelle
        await _firestore.collection('users').doc(user.uid).update({
          'lastSeen': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Profil tamamlanmamışsa yönlendir
        final existingData = userDoc.data() ?? {};
        if (existingData['isProfileComplete'] == false) {
          Get.offAllNamed('/register/complete-profile', arguments: {
            'userId': user.uid,
            'isNewUser': false,
            'authProvider': existingData['authProvider'],
            'currentStep': existingData['registrationStep'],
          });
        } else {
          Get.offAllNamed('/home');
        }
      }
    } catch (e) {
      _logger.e('Error handling social sign in: $e');
      throw _handleAuthException(e);
    }
  }

  // Auth provider'ı belirle
  String _determineAuthProvider(User user) {
    final providerData = user.providerData.firstOrNull;
    if (providerData == null) return 'email';

    switch (providerData.providerId) {
      case 'google.com':
        return 'google';
      case 'facebook.com':
        return 'facebook';
      case 'apple.com':
        return 'apple';
      case 'github.com':
        return 'github';
      default:
        return 'email';
    }
  }

  // Sağlayıcıya özel varsayılan ayarları ekle
  void _addProviderSpecificDefaults(Map<String, dynamic> userData, User user) {
    final authProvider = userData['authProvider'] as String;

    switch (authProvider) {
      case 'google':
        _addGoogleDefaults(userData, user);
        break;
      case 'apple':
        _addAppleDefaults(userData, user);
        break;
      case 'github':
        _addGitHubDefaults(userData, user);
        break;
      case 'facebook':
        _addFacebookDefaults(userData, user);
        break;
    }
  }

  void _addGoogleDefaults(Map<String, dynamic> userData, User user) {
    final googleData = user.providerData
        .firstWhere((element) => element.providerId == 'google.com');

    userData.addAll({
      'email': googleData.email,
      'displayName': googleData.displayName,
      'photoURL': googleData.photoURL,
      'isEmailVerified': true, // Google email'leri doğrulanmış kabul edilir
      'preferences': {
        'theme': 'system',
        'language': 'tr',
        'timezone': 'Europe/Istanbul',
      },
      'profile': {
        'bio': '',
        'title': '',
        'company': '',
        'location': '',
        'website': '',
        'github': '',
        'linkedin': '',
        'twitter': '',
      },
    });
  }

  void _addAppleDefaults(Map<String, dynamic> userData, User user) {
    final appleData = user.providerData
        .firstWhere((element) => element.providerId == 'apple.com');

    userData.addAll({
      'email': appleData.email,
      'displayName': appleData.displayName ??
          'Apple User', // Apple bazen isim vermeyebilir
      'photoURL': appleData.photoURL ?? '', // Apple foto vermez
      'isEmailVerified': true, // Apple email'leri doğrulanmış kabul edilir
      'preferences': {
        'theme': 'system',
        'language': 'tr',
        'timezone': 'Europe/Istanbul',
        'useSystemTheme':
            true, // Apple kullanıcıları için sistem teması varsayılan
      },
      'profile': {
        'bio': '',
        'title': '',
        'company': '',
        'location': '',
        'website': '',
        'github': '',
        'linkedin': '',
        'twitter': '',
      },
      'privacySettings': {
        'profileVisibility':
            'private', // Apple kullanıcıları için varsayılan olarak private
        'showEmail': false,
        'showLocation': false,
      },
    });
  }

  void _addGitHubDefaults(Map<String, dynamic> userData, User user) {
    final githubData = user.providerData
        .firstWhere((element) => element.providerId == 'github.com');

    userData.addAll({
      'email': githubData.email,
      'displayName': githubData.displayName,
      'photoURL': githubData.photoURL,
      'isEmailVerified': true,
      'preferences': {
        'theme': 'dark', // GitHub kullanıcıları için dark theme varsayılan
        'language': 'tr',
        'timezone': 'Europe/Istanbul',
        'codeEditor': {
          'theme': 'monokai',
          'fontSize': 14,
          'tabSize': 2,
        },
      },
      'profile': {
        'bio': '',
        'title': 'Software Developer', // GitHub kullanıcıları için varsayılan
        'company': '',
        'location': '',
        'website': '',
        'github':
            githubData.displayName, // GitHub kullanıcı adını otomatik ekle
        'linkedin': '',
        'twitter': '',
      },
      'skills': ['Git'], // Temel Git yeteneği varsayılan olarak ekle
    });
  }

  void _addFacebookDefaults(Map<String, dynamic> userData, User user) {
    final facebookData = user.providerData
        .firstWhere((element) => element.providerId == 'facebook.com');

    userData.addAll({
      'email': facebookData.email,
      'displayName': facebookData.displayName,
      'photoURL': facebookData.photoURL,
      'isEmailVerified': true,
      'preferences': {
        'theme': 'light', // Facebook kullanıcıları için light theme varsayılan
        'language': 'tr',
        'timezone': 'Europe/Istanbul',
      },
      'profile': {
        'bio': '',
        'title': '',
        'company': '',
        'location': '',
        'website': '',
        'github': '',
        'linkedin': '',
        'twitter': '',
      },
      'privacySettings': {
        'profileVisibility':
            'friends', // Facebook kullanıcıları için varsayılan olarak friends-only
        'showEmail': false,
        'showLocation': true,
      },
    });
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
      _logger.e('Last seen time not updated: $e');
    }
  }

  Exception _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return Exception(AppStrings.errorUserNotFound);
        case 'wrong-password':
          return Exception(AppStrings.errorWrongPassword);
        case 'email-already-in-use':
          return Exception(AppStrings.errorEmailInUse);
        case 'weak-password':
          return Exception(AppStrings.errorWeakPassword);
        case 'invalid-email':
          return Exception(AppStrings.errorInvalidEmail);
        case 'operation-not-allowed':
          return Exception(AppStrings.errorOperationNotAllowed);
        case 'account-exists-with-different-credential':
          return Exception(AppStrings.errorAccountExists);
        case 'requires-recent-login':
          return Exception(AppStrings.errorRequiresRecentLogin);
        case 'credential-already-in-use':
          return Exception(AppStrings.errorCredentialInUse);
        case 'provider-already-linked':
          return Exception(AppStrings.errorProviderAlreadyLinked);
        case 'no-such-provider':
          return Exception(AppStrings.errorNoSuchProvider);
        case 'invalid-credential':
          return Exception(AppStrings.errorInvalidCredential);
        default:
          return Exception('${AppStrings.errorGeneric}: ${e.message}');
      }
    }
    return Exception('${AppStrings.errorGeneric}: $e');
  }

  // GitHub metodları
  Future<String?> getGithubAccessToken() async {
    try {
      return await _githubOAuthService.getAccessToken();
    } catch (e) {
      _logger.e('GitHub access token not found: $e');
      throw _handleAuthException(e);
    }
  }

  Future<Map<String, dynamic>?> getGithubUserInfo(String accessToken) async {
    try {
      return await _githubOAuthService.getUserInfo(accessToken);
    } catch (e) {
      _logger.e('GitHub user info not found: $e');
      throw _handleAuthException(e);
    }
  }
}
