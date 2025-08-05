import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:get/get.dart';
import '../services/github_oauth_service.dart';
import '../models/profile_completion_model.dart';
import '../constants/app_strings.dart';
import 'package:flutter/material.dart'; // Added for snackbar

abstract class IAuthRepository {
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  );
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
    String username,
  );
  Future<UserCredential> signInWithGoogle();
  Future<UserCredential> signInWithGithub();
  //  Future<UserCredential> signInWithFacebook();
  Future<UserCredential> signInWithApple();
  Future<void> signOut();
  Future<void> signOutFromAllDevices();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> verifyEmail();
  Future<void> updatePassword(String newPassword);
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
  }) : _auth = auth ?? FirebaseAuth.instance,
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
    String email,
    String password,
  ) async {
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
      // Email çakışma kontrolü Firebase Auth tarafından otomatik yapılır
      // Burada sadece genel bir kontrol yapıyoruz
      return;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sosyal giriş öncesi email kontrolü
  Future<void> _checkEmailBeforeSocialSignIn(
    String email,
    String provider,
  ) async {
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
      await handleSocialSignIn(userCredential.user!, 'google');
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
          appleCredential.email!,
          'apple.com',
        );
      }

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      await handleSocialSignIn(userCredential.user!, 'apple');
      return userCredential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential> signInWithGitHub() async {
    try {
      final accessToken = await _githubOAuthService.getGithubAccessToken();

      if (accessToken == null) {
        _logger.w(
          'GitHub OAuth akışı başarısız oldu veya kullanıcı tarafından iptal edildi',
        );
        throw Exception('GitHub girişi başarısız oldu');
      }

      // GitHub'dan kullanıcı bilgilerini al
      final userInfo = await _githubOAuthService.getUserInfo(accessToken);

      final githubAuthCredential = GithubAuthProvider.credential(accessToken);
      final userCredential = await _auth.signInWithCredential(
        githubAuthCredential,
      );

      if (userCredential.user == null) {
        _logger.e('Firebase kimlik doğrulaması başarısız oldu');
        throw Exception('Kimlik doğrulama hatası');
      }

      // GitHub bilgilerini ek veri olarak geç
      final additionalData = userInfo != null
          ? {
              'githubUsername': userInfo['login'],
              'githubId': userInfo['id'].toString(),
              'githubBio': userInfo['bio'],
              'githubLocation': userInfo['location'],
              'githubCompany': userInfo['company'],
              'githubBlog': userInfo['blog'],
              'githubFollowers': userInfo['followers'].toString(),
              'githubFollowing': userInfo['following'].toString(),
              'githubPublicRepos': userInfo['public_repos'].toString(),
              'githubCreatedAt': userInfo['created_at'],
              'githubUpdatedAt': userInfo['updated_at'],
            }
          : null;

      await handleSocialSignIn(
        userCredential.user!,
        'github',
        additionalData: additionalData,
      );
      return userCredential;
    } catch (e) {
      _logger.e('GitHub girişi sırasında hata: $e');
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserCredential> signInWithGithub() => signInWithGitHub();

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> signOutFromAllDevices() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
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
      batch.update(_firestore.collection('users').doc(user.uid), {
        'connections': FieldValue.arrayUnion([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Hedef kullanıcının bağlantılarını güncelle
      batch.update(_firestore.collection('users').doc(userId), {
        'connections': FieldValue.arrayUnion([user.uid]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

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
      batch.update(_firestore.collection('users').doc(user.uid), {
        'connections': FieldValue.arrayRemove([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Hedef kullanıcının bağlantılarını güncelle
      batch.update(_firestore.collection('users').doc(userId), {
        'connections': FieldValue.arrayRemove([user.uid]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

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
      final accessToken = await _githubOAuthService.getGithubAccessToken();

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
  Future<void> handleSocialSignIn(
    User user,
    String provider, {
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // Yeni kullanıcı - minimal profil oluştur
        await _createMinimalSocialProfile(
          user,
          provider,
          additionalData: additionalData,
        );
        Get.offAllNamed('/home'); // Direkt home'a git
      } else {
        // Mevcut kullanıcı kontrolü
        final userData = userDoc.data()!;
        final completionLevel = _calculateCompletionLevelFromMap(userData);

        if (completionLevel.index >= ProfileCompletionLevel.minimal.index) {
          Get.offAllNamed('/home');
        } else {
          Get.offAllNamed('/onboarding/quick-setup');
        }
      }
    } catch (e) {
      _logger.e('Social sign in error: $e');
      throw _handleAuthException(e);
    }
  }

  // Sosyal giriş için minimal profil oluştur
  Future<void> _createMinimalSocialProfile(
    User user,
    String provider, {
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final userData = {
        'id': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
        'authProvider': provider,
        'onboardingStep': 'minimal_complete',
        'isProfileComplete': false,
        'profileCompletionLevel': 'minimal',
        'canUseApp': true,
        'skills': [],
        'interests': [],
        'connections': [],
        'notifications': {'email': true, 'push': true, 'marketing': false},
        'privacySettings': {
          'profileVisibility': 'public',
          'showEmail': false,
          'showLocation': true,
        },
        ...?additionalData,
      };

      // Smart defaults from social providers
      await _addSmartSocialDefaults(userData, user, provider);

      await _firestore.collection('users').doc(user.uid).set(userData);
      _showProfileCompletionReminder();
    } catch (e) {
      _logger.e('Error creating minimal social profile: $e');
      throw _handleAuthException(e);
    }
  }

  // Map'ten ProfileCompletionLevel hesapla
  ProfileCompletionLevel _calculateCompletionLevelFromMap(
    Map<String, dynamic> userData,
  ) {
    final profileCompletionLevel =
        userData['profileCompletionLevel'] as String?;
    switch (profileCompletionLevel) {
      case 'minimal':
        return ProfileCompletionLevel.minimal;
      case 'basic':
        return ProfileCompletionLevel.basic;
      case 'standard':
        return ProfileCompletionLevel.standard;
      case 'complete':
        return ProfileCompletionLevel.complete;
      default:
        return ProfileCompletionLevel.minimal;
    }
  }

  // Kullanıcıya profil tamamlama hatırlatması
  void _showProfileCompletionReminder() {
    Future.delayed(Duration(seconds: 3), () {
      Get.snackbar(
        'Hoş geldin!',
        'Profilini tamamlayarak daha iyi öneriler alabilirsin',
        backgroundColor: Colors.blue.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: () => Get.toNamed('/profile/complete'),
          child: Text('Tamamla', style: TextStyle(color: Colors.white)),
        ),
      );
    });
  }

  // Smart social defaults for modern social login
  Future<void> _addSmartSocialDefaults(
    Map<String, dynamic> userData,
    User user,
    String provider,
  ) async {
    switch (provider) {
      case 'google':
        await _addGoogleSmartDefaults(userData, user);
        break;
      case 'apple':
        await _addAppleSmartDefaults(userData, user);
        break;
      case 'github':
        await _addGitHubSmartDefaults(userData, user);
        break;
    }
  }

  // Google People API'dan akıllı defaults
  Future<void> _addGoogleSmartDefaults(
    Map<String, dynamic> userData,
    User user,
  ) async {
    try {
      // Basic Google data
      userData.addAll({
        'isEmailVerified': true,
        'preferences': {
          'theme': 'system',
          'language': 'tr',
          'timezone': 'Europe/Istanbul',
        },
      });

      // Google People API integration için future improvement
      // Şimdilik basic defaults
      if (user.displayName?.isNotEmpty == true) {
        final nameParts = user.displayName!.split(' ');
        userData['firstName'] = nameParts.first;
        if (nameParts.length > 1) {
          userData['lastName'] = nameParts.sublist(1).join(' ');
        }
      }

      // Google hesap region detection
      userData['region'] = 'TR'; // Default
    } catch (e) {
      _logger.w('Google smart defaults failed: $e');
    }
  }

  // Apple UserInfo'dan akıllı defaults
  Future<void> _addAppleSmartDefaults(
    Map<String, dynamic> userData,
    User user,
  ) async {
    try {
      userData.addAll({
        'isEmailVerified': true,
        'preferences': {
          'theme': 'system',
          'language': 'tr',
          'timezone': 'Europe/Istanbul',
          'useSystemTheme': true,
        },
        'privacySettings': {
          'profileVisibility': 'private', // Apple users prefer privacy
          'showEmail': false,
          'showLocation': false,
        },
      });

      // Apple name parsing
      if (user.displayName?.isNotEmpty == true) {
        final nameParts = user.displayName!.split(' ');
        userData['firstName'] = nameParts.first;
        if (nameParts.length > 1) {
          userData['lastName'] = nameParts.sublist(1).join(' ');
        }
      } else {
        userData['displayName'] = 'Apple User';
      }

      // Apple account region
      userData['region'] = 'TR'; // Default
    } catch (e) {
      _logger.w('Apple smart defaults failed: $e');
    }
  }

  // GitHub için gelişmiş defaults
  Future<void> _addGitHubSmartDefaults(
    Map<String, dynamic> userData,
    User user,
  ) async {
    try {
      userData.addAll({
        'isEmailVerified': true,
        'preferences': {
          'theme': 'dark',
          'language': 'tr',
          'timezone': 'Europe/Istanbul',
          'codeEditor': {'theme': 'monokai', 'fontSize': 14, 'tabSize': 2},
        },
        'skills': ['Git'], // Base skill
      });

      if (user.displayName?.isNotEmpty == true) {
        userData['githubUsername'] = user.displayName;
        userData['profile'] = {
          'bio': '',
          'title': 'Software Developer',
          'github': user.displayName,
        };
      }
    } catch (e) {
      _logger.w('GitHub smart defaults failed: $e');
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
      return await _githubOAuthService.getGithubAccessToken();
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

  // Oturum kalıcılığını ayarla
  Future<void> setPersistence(bool isPersistent) async {
    try {
      if (isPersistent) {
        await _auth.setPersistence(Persistence.LOCAL);
      } else {
        await _auth.setPersistence(Persistence.SESSION);
      }
    } catch (e) {
      throw Exception('Oturum kalıcılığı ayarlanırken bir hata oluştu: $e');
    }
  }
}
