import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/enhanced_user_model.dart';
import '../models/privacy_settings_model.dart';
import '../models/user_model.dart';

class UserService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Rxn<EnhancedUserModel> _currentUser = Rxn<EnhancedUserModel>();

  EnhancedUserModel? get currentUser => _currentUser.value;

  @override
  void onInit() {
    super.onInit();
    _initializeUserListener();
  }

  void _initializeUserListener() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          _currentUser.value = EnhancedUserModel.fromJson(userDoc.data()!);
        } else {
          final newUser = EnhancedUserModel(
            uid: user.uid,
            email: user.email ?? '',
            displayName: user.displayName,
            photoURL: user.photoURL,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            lastSeen: DateTime.now(),
          );
          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(newUser.toJson());
          _currentUser.value = newUser;
        }
      } else {
        _currentUser.value = null;
      }
    });
  }

  Future<List<EnhancedUserModel>> getAllDevelopers() async {
    final querySnapshot = await _firestore.collection('users').get();
    return querySnapshot.docs
        .map((doc) => EnhancedUserModel.fromJson(doc.data()))
        .toList();
  }

  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (displayName != null) {
      await user.updateDisplayName(displayName);
    }
    if (photoURL != null) {
      await user.updatePhotoURL(photoURL);
    }

    final updatedUser = EnhancedUserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: displayName ?? user.displayName,
      photoURL: photoURL ?? user.photoURL,
      createdAt: _currentUser.value?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      lastSeen: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .update(updatedUser.toJson());

    _currentUser.value = updatedUser;
  }

  Future<PrivacySettings> getPrivacySettings() async {
    final userId = Get.find<UserModel>().id;
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('privacy')
        .get();

    if (doc.exists) {
      return PrivacySettings.fromJson(doc.data()!);
    }
    return PrivacySettings(); // Return default settings
  }

  Future<void> updatePrivacySettings(PrivacySettings settings) async {
    final userId = Get.find<UserModel>().id;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('privacy')
        .set(settings.toJson());
  }
}
