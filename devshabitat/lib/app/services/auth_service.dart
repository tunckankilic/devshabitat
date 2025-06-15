import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Rx<User?> _firebaseUser = Rx<User?>(null);

  User? get currentUser => _firebaseUser.value;
  Stream<User?> get userChanges => _auth.userChanges();

  @override
  void onInit() {
    super.onInit();
    _firebaseUser.bindStream(_auth.userChanges());
  }

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } catch (e) {
      print('Giriş yapılırken hata: $e');
      rethrow;
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } catch (e) {
      print('Kullanıcı oluşturulurken hata: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Çıkış yapılırken hata: $e');
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Şifre sıfırlama e-postası gönderilirken hata: $e');
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

  bool get isAuthenticated => currentUser != null;
}
