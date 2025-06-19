import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    currentUser.bindStream(_auth.authStateChanges());
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

  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      if (_auth.currentUser != null) {
        await _auth.currentUser!.updateDisplayName(displayName);
        await _auth.currentUser!.updatePhotoURL(photoURL);
      }
    } catch (e) {
      _logger.e('Profil güncellenirken hata: $e');
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

  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } catch (e) {
      print('Hesap silinirken hata: $e');
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
}
