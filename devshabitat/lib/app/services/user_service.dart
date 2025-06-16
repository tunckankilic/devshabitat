import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String displayName;
  final String? email;
  final String? photoURL;

  const UserModel({
    required this.id,
    required this.displayName,
    this.email,
    this.photoURL,
  });

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      displayName: user.displayName ?? 'Anonim Kullanıcı',
      email: user.email,
      photoURL: user.photoURL,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String?,
      photoURL: json['photoURL'] as String?,
    );
  }
}

class UserService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Rxn<UserModel> _currentUser = Rxn<UserModel>();

  UserModel? get currentUser => _currentUser.value;

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
          _currentUser.value = UserModel.fromJson(userDoc.data()!);
        } else {
          final newUser = UserModel.fromFirebaseUser(user);
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

    final updatedUser = UserModel(
      id: user.uid,
      displayName: displayName ?? user.displayName ?? 'Anonim Kullanıcı',
      email: user.email,
      photoURL: photoURL ?? user.photoURL,
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .update(updatedUser.toJson());

    _currentUser.value = updatedUser;
  }
}
