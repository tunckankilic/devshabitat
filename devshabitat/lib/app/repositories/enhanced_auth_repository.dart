import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../models/enhanced_user_model.dart';
import 'package:logger/logger.dart';
import 'package:get/get.dart';

abstract class BaseEnhancedAuthRepository {
  Stream<User?> get authStateChanges;
  Stream<EnhancedUserModel?> get userProfileChanges;

  Future<EnhancedUserModel> getUserProfile(String userId);
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
  Future<void> linkWithGoogle();
  Future<void> linkWithGithub();
  Future<void> linkWithFacebook();
  Future<void> linkWithApple();
  Future<void> unlinkProvider(String providerId);
  Future<void> updateUserProfile(EnhancedUserModel user);
  Future<void> updateUserPreferences(Map<String, dynamic> preferences);
  Future<void> updateLastSeen();
  Future<void> addConnection(String userId);
  Future<void> removeConnection(String userId);
  Future<void> updateUserConnections(Map<String, dynamic> connections);
  Future<List<String>> getUserConnections();
}

class EnhancedAuthRepository implements BaseEnhancedAuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;
  final Logger _logger;

  EnhancedAuthRepository({
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
      await updateLastSeen();
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

      // Kullanıcı profilini oluştur
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'email': email,
        'displayName': username,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } catch (e) {
      _logger.e('E-posta ile kayıt başarısız: $e');
      rethrow;
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
      await _handleProviderSignIn(userCredential.user!, 'google.com');
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
      await _handleProviderSignIn(userCredential.user!, 'apple.com');
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
      await _handleProviderSignIn(userCredential.user!, 'facebook.com');
      return userCredential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserCredential> signInWithGithub() async {
    try {
      // GitHub OAuth implementasyonu
      throw UnimplementedError('GitHub girişi henüz uygulanmadı');
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
  Future<void> linkWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google girişi iptal edildi');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.currentUser?.linkWithCredential(credential);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> linkWithApple() async {
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

      await _auth.currentUser?.linkWithCredential(oauthCredential);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> linkWithFacebook() async {
    try {
      final LoginResult result = await _facebookAuth.login();
      if (result.status != LoginStatus.success) {
        throw Exception('Facebook girişi başarısız');
      }

      final AccessToken accessToken = result.accessToken!;
      final OAuthCredential credential =
          FacebookAuthProvider.credential(accessToken.token);

      await _auth.currentUser?.linkWithCredential(credential);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> linkWithGithub() async {
    try {
      // GitHub hesap bağlama implementasyonu
      throw UnimplementedError('GitHub hesap bağlama henüz uygulanmadı');
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> unlinkProvider(String providerId) async {
    try {
      await _auth.currentUser?.unlink(providerId);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> updateUserProfile(EnhancedUserModel user) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Kullanıcı oturum açmamış');

      await currentUser.updateDisplayName(user.displayName ?? '');
      if (user.photoURL != null) {
        await currentUser.updatePhotoURL(user.photoURL);
      }

      await _updateUserProfileInFirestore(user);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> updateLastSeen() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Firestore'da son görülme zamanını güncelle
      await _updateLastSeenInFirestore();
    } catch (e) {
      _logger.e('Son görülme zamanı güncellenirken hata: $e');
    }
  }

  @override
  Future<void> addConnection(String userId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Kullanıcı oturum açmamış');

      // Firestore'da bağlantıyı ekle
      await _addConnectionInFirestore(currentUser.uid);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> removeConnection(String userId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Kullanıcı oturum açmamış');

      // Firestore'dan bağlantıyı kaldır
      await _removeConnectionInFirestore(currentUser.uid);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Kullanıcı oturum açmamış');

      // Firestore'da tercihleri güncelle
      await _updatePreferencesInFirestore(preferences);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> updateUserConnections(Map<String, dynamic> connections) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Kullanıcı oturum açmamış');

      await _firestore.collection('users').doc(currentUser.uid).update({
        'connections': connections,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Stream<EnhancedUserModel?> get userProfileChanges {
    // Firestore'dan kullanıcı profil değişikliklerini dinle
    throw UnimplementedError(
        'Kullanıcı profil değişiklikleri henüz uygulanmadı');
  }

  @override
  Future<EnhancedUserModel> getUserProfile(String userId) async {
    try {
      final user = await _getUserProfileFromFirestore(userId);
      if (user == null) {
        throw Exception('Kullanıcı profili bulunamadı');
      }
      return user;
    } catch (e) {
      _logger.e('Kullanıcı profili alınırken hata: $e');
      throw _handleAuthException(e);
    }
  }

  @override
  Future<List<String>> getUserConnections() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Kullanıcı oturum açmamış');

      final userProfile = await _getUserProfileFromFirestore(currentUser.uid);
      return userProfile?.connections ?? [];
    } catch (e) {
      _logger.e('Bağlantılar alınamadı: $e');
      throw _handleAuthException(e);
    }
  }

  // Yardımcı metodlar
  Future<void> _initializeUserProfile(User user) async {
    try {
      final enhancedUser = EnhancedUserModel(
        uid: user.uid,
        email: user.email!,
        displayName: user.displayName,
        photoURL: user.photoURL,
        connections: [],
        preferences: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastSeen: DateTime.now(),
      );

      await _updateUserProfileInFirestore(enhancedUser);
    } catch (e) {
      _logger.e('Kullanıcı profili oluşturulurken hata: $e');
      throw _handleAuthException(e);
    }
  }

  Future<void> _handleProviderSignIn(User user, String providerId) async {
    try {
      // Kullanıcı profili kontrolü ve güncelleme
      final existingProfile = await _getUserProfileFromFirestore(user.uid);
      if (existingProfile == null) {
        await _initializeUserProfile(user);
      } else {
        await updateLastSeen();
      }
    } catch (e) {
      _logger.e('Provider girişi işlenirken hata: $e');
      throw _handleAuthException(e);
    }
  }

  // Firestore işlemleri
  Future<void> _updateUserProfileInFirestore(EnhancedUserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id.value).update({
        ...user.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.e('Firestore\'da kullanıcı profili güncellenemedi: $e');
      rethrow;
    }
  }

  Future<void> _updateLastSeenInFirestore() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.e('Son görülme zamanı güncellenemedi: $e');
      rethrow;
    }
  }

  Future<void> _addConnectionInFirestore(String userId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Kullanıcı oturum açmamış');

      final batch = _firestore.batch();

      // Mevcut kullanıcının bağlantılarını güncelle
      batch.update(
        _firestore.collection('users').doc(currentUser.uid),
        {
          'connections': FieldValue.arrayUnion([userId.toString()]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      // Hedef kullanıcının bağlantılarını güncelle
      batch.update(
        _firestore.collection('users').doc(userId),
        {
          'connections': FieldValue.arrayUnion([currentUser.uid]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();
    } catch (e) {
      _logger.e('Bağlantı eklenemedi: $e');
      rethrow;
    }
  }

  Future<void> _removeConnectionInFirestore(String userId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Kullanıcı oturum açmamış');

      final batch = _firestore.batch();

      // Mevcut kullanıcının bağlantılarını güncelle
      batch.update(
        _firestore.collection('users').doc(currentUser.uid),
        {
          'connections': FieldValue.arrayRemove([userId]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      // Hedef kullanıcının bağlantılarını güncelle
      batch.update(
        _firestore.collection('users').doc(userId),
        {
          'connections': FieldValue.arrayRemove([currentUser.uid]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();
    } catch (e) {
      _logger.e('Bağlantı kaldırılamadı: $e');
      rethrow;
    }
  }

  Future<void> _updatePreferencesInFirestore(
      Map<String, dynamic> preferences) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturum açmamış');

      await _firestore.collection('users').doc(user.uid).update({
        'preferences': preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.e('Tercihler güncellenemedi: $e');
      rethrow;
    }
  }

  Future<EnhancedUserModel?> _getUserProfileFromFirestore(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        throw Exception('Kullanıcı profili bulunamadı');
      }
      return EnhancedUserModel.fromJson(doc.data()!);
    } catch (e) {
      _logger.e('Firestore\'dan kullanıcı profili alınamadı: $e');
      rethrow;
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
        case 'invalid-verification-code':
          return Exception('Geçersiz doğrulama kodu');
        case 'invalid-verification-id':
          return Exception('Geçersiz doğrulama kimliği');
        case 'quota-exceeded':
          return Exception('İstek kotası aşıldı');
        case 'network-request-failed':
          return Exception('Ağ isteği başarısız oldu');
        default:
          return Exception('Kimlik doğrulama hatası: ${e.message}');
      }
    }
    return Exception('Beklenmeyen bir hata oluştu: $e');
  }
}
