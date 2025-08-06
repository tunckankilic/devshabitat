import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:devshabitat/app/models/user/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AuthService();

  // Kullanıcı bilgilerini getir
  Future<UserModel?> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // Email ile kayıt ol
  Future<UserModel> signUpWithEmail(String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user!;
    final userModel = UserModel(
      id: user.uid,
      email: user.email!,
      displayName: user.displayName,
      photoURL: user.photoURL,
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toFirestore());

    return userModel;
  }

  // Email ile giriş yap
  Future<UserModel> signInWithEmail(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final userDoc = await _firestore
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();

    return UserModel.fromFirestore(userDoc);
  }

  // Oturumu kapat
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Şifre sıfırlama
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Profil güncelleme
  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? photoURL,
    String? bio,
  }) async {
    final data = <String, dynamic>{
      if (displayName != null) 'displayName': displayName,
      if (photoURL != null) 'photoURL': photoURL,
      if (bio != null) 'bio': bio,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('users').doc(userId).update(data);
  }

  // Email güncelleme
  Future<void> updateEmail(String newEmail) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı oturumu bulunamadı');

    await user.verifyBeforeUpdateEmail(newEmail);
  }

  // Şifre güncelleme
  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı oturumu bulunamadı');

    await user.updatePassword(newPassword);
  }

  // Hesap silme
  Future<void> deleteAccount(String userId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı oturumu bulunamadı');

    // Firestore'dan kullanıcı verilerini sil
    await _firestore.collection('users').doc(userId).delete();

    // Firebase Auth'dan hesabı sil
    await user.delete();
  }
}
