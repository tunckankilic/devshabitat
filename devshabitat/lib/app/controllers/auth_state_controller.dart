import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/auth_repository.dart';
import '../routes/app_pages.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthStateController extends GetxController {
  final AuthRepository _authRepository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reactive state variables
  final _currentUser = Rxn<User>();
  final _userProfile = Rxn<Map<String, dynamic>>();
  final _authState = AuthState.initial.obs;

  // Getters
  User? get currentUser => _currentUser.value;
  Map<String, dynamic>? get userProfile => _userProfile.value;
  AuthState get authState => _authState.value;

  AuthStateController({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  @override
  void onInit() {
    super.onInit();
    _initializeAuthState();
  }

  void _initializeAuthState() {
    _authRepository.authStateChanges.listen((user) async {
      _currentUser.value = user;
      if (user != null) {
        _authState.value = AuthState.authenticated;
        // Kullanıcı profilini yükle
        _userProfile.value = await _authRepository.getUserProfile(user.uid);

        // Sadece login sayfasındaysa anasayfaya yönlendir
        if (Get.currentRoute == AppRoutes.login) {
          Get.offAllNamed(AppRoutes.home);
        }

        await _firestore.collection('users').doc(user.uid).set({
          'id': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastSeen': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        _authState.value = AuthState.unauthenticated;
        _userProfile.value = null;

        // Sadece korumalı sayfalardaysa login sayfasına yönlendir
        if (Get.currentRoute != AppRoutes.login &&
            Get.currentRoute != AppRoutes.register &&
            Get.currentRoute != AppRoutes.forgotPassword) {
          Get.offAllNamed(AppRoutes.login);
        }
      }
    });
  }

  Future<void> signOut() async {
    try {
      _authState.value = AuthState.loading;
      await _authRepository.signOut();
    } catch (e) {
      _authState.value = AuthState.error;
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      _authState.value = AuthState.loading;
      await _authRepository.deleteAccount();
    } catch (e) {
      _authState.value = AuthState.error;
      rethrow;
    }
  }

  Future<void> verifyEmail() async {
    try {
      await _authRepository.verifyEmail();
    } catch (e) {
      rethrow;
    }
  }
}
