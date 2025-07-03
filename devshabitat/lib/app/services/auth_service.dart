import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:devshabitat/app/models/user_model.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    currentUser.bindStream(_auth.authStateChanges());
    _googleSignIn.initialize();
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      _logger.e('Giriş yapılırken hata: $e');
      return null;
    }
  }

  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        await _firestore.collection('users').doc(result.user!.uid).set({
          'username': username,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'fcmTokens': [],
        });
      }

      return result.user;
    } catch (e) {
      _logger.e('Kayıt olunurken hata: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      _logger.e('Çıkış yapılırken hata: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      _logger.e('Şifre sıfırlama maili gönderilirken hata: $e');
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } catch (e) {
      print('Şifre güncellenirken hata: $e');
      rethrow;
    }
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      await _auth.currentUser?.updateEmail(newEmail);
    } catch (e) {
      print('E-posta güncellenirken hata: $e');
      rethrow;
    }
  }

  Future<void> reauthenticate(String email, String password) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await _auth.currentUser?.reauthenticateWithCredential(credential);
    } catch (e) {
      print('Yeniden kimlik doğrulama yapılırken hata: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    required String name,
    required String bio,
    required String location,
    required String githubUsername,
  }) async {
    try {
      final user = currentUser.value;
      if (user != null) {
        await _auth.currentUser?.updateDisplayName(name);
        await _firestore.collection('users').doc(user.uid).update({
          'displayName': name,
          'bio': bio,
          'location': location,
          'githubUsername': githubUsername,
          'updatedAt': DateTime.now(),
        });
        await _auth.currentUser?.reload();
      }
    } catch (e) {
      rethrow;
    }
  }

  bool get isAuthenticated => currentUser.value != null;

  // Auth state changes
  Stream<UserModel?> authStateChanges() {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserModel(
        id: user.uid,
        email: user.email!,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        phoneNumber: user.phoneNumber,
        emailVerified: user.emailVerified,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });
  }

  // Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize();

      final GoogleSignInAccount? googleUser =
          await _googleSignIn.authenticate();
      if (googleUser == null) throw Exception('Google hesabı seçilmedi');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase kimlik bilgilerini oluştur
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Firebase ile giriş yap
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Firestore'a kullanıcı bilgilerini kaydet
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
        'provider': 'google',
        'lastSignInTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return UserModel(
        id: user.uid,
        email: user.email!,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        phoneNumber: user.phoneNumber,
        emailVerified: user.emailVerified,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Google ile giriş yapılırken bir hata oluştu');
    }
  }

  // Sign in with Apple
  Future<UserModel> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthProvider = OAuthProvider('apple.com');
      final credentialAuth = oAuthProvider.credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(credentialAuth);
      final user = userCredential.user!;

      // Save additional user data to Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
        'provider': 'apple',
        'lastSignInTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return UserModel(
        id: user.uid,
        email: user.email!,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        phoneNumber: user.phoneNumber,
        emailVerified: user.emailVerified,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Apple ile giriş yapılırken bir hata oluştu');
    }
  }

  // Sign up with email and password
  Future<UserModel> signUp(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;

      // Save additional user data to Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'provider': 'email',
      });

      return UserModel(
        id: user.uid,
        email: user.email!,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        phoneNumber: user.phoneNumber,
        emailVerified: user.emailVerified,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Kayıt olurken bir hata oluştu');
    }
  }

  // Update profile
  Future<void> updateProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update({
        'displayName': user.displayName,
        'photoUrl': user.photoUrl,
        'phoneNumber': user.phoneNumber,
        'metadata': user.metadata,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Profil güncellenirken bir hata oluştu');
    }
  }

  // Change password
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu bulunamadı');

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } catch (e) {
      throw Exception('Şifre değiştirilirken bir hata oluştu');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu bulunamadı');

      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete user account
      await user.delete();
    } catch (e) {
      throw Exception('Hesap silinirken bir hata oluştu');
    }
  }

  // Sign in with GitHub
  Future<UserModel> signInWithGithub() async {
    try {
      final githubProvider = GithubAuthProvider();
      final userCredential = await _auth.signInWithPopup(githubProvider);
      final user = userCredential.user!;

      // Save additional user data to Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
        'provider': 'github',
        'lastSignInTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return UserModel(
        id: user.uid,
        email: user.email!,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        phoneNumber: user.phoneNumber,
        emailVerified: user.emailVerified,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('GitHub ile giriş yapılırken bir hata oluştu');
    }
  }
}
