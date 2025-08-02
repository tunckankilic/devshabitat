import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:devshabitat/app/models/user/user_model.dart';
import 'package:devshabitat/app/services/auth/auth_service.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAuthState();
  }

  void _initializeAuthState() {
    _auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        // Kullanıcı oturum açtığında
        final userModel = await _authService.getUserById(firebaseUser.uid);
        user.value = userModel;
      } else {
        // Kullanıcı oturumu kapattığında
        user.value = null;
      }
    });
  }

  // Oturum açma durumunu kontrol et
  bool get isAuthenticated => user.value != null;

  // Kullanıcı ID'sini al
  String? get userId => user.value?.id;

  // Kullanıcı adını al
  String get userName => user.value?.displayName ?? 'Misafir';

  // Email ile kayıt ol
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      await _authService.signUpWithEmail(email, password);
    } finally {
      isLoading.value = false;
    }
  }

  // Email ile giriş yap
  Future<void> signInWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      await _authService.signInWithEmail(email, password);
    } finally {
      isLoading.value = false;
    }
  }

  // Google ile giriş yap
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      await _authService.signInWithGoogle();
    } finally {
      isLoading.value = false;
    }
  }

  // Apple ile giriş yap
  Future<void> signInWithApple() async {
    try {
      isLoading.value = true;
      await _authService.signInWithApple();
    } finally {
      isLoading.value = false;
    }
  }

  // Oturumu kapat
  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _authService.signOut();
    } finally {
      isLoading.value = false;
    }
  }

  // Şifre sıfırlama
  Future<void> resetPassword(String email) async {
    try {
      isLoading.value = true;
      await _authService.resetPassword(email);
      Get.snackbar('Başarılı', 'Şifre sıfırlama bağlantısı gönderildi');
    } finally {
      isLoading.value = false;
    }
  }

  // Profil güncelleme
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
    String? bio,
  }) async {
    try {
      isLoading.value = true;
      await _authService.updateProfile(
        userId: user.value!.id,
        displayName: displayName,
        photoURL: photoURL,
        bio: bio,
      );
      // Kullanıcı bilgilerini yenile
      final updatedUser = await _authService.getUserById(user.value!.id);
      user.value = updatedUser;
      Get.snackbar('Başarılı', 'Profil güncellendi');
    } finally {
      isLoading.value = false;
    }
  }

  // Email güncelleme
  Future<void> updateEmail(String newEmail) async {
    try {
      isLoading.value = true;
      await _authService.updateEmail(newEmail);
      Get.snackbar('Başarılı', 'Email güncellendi');
    } finally {
      isLoading.value = false;
    }
  }

  // Şifre güncelleme
  Future<void> updatePassword(String newPassword) async {
    try {
      isLoading.value = true;
      await _authService.updatePassword(newPassword);
      Get.snackbar('Başarılı', 'Şifre güncellendi');
    } finally {
      isLoading.value = false;
    }
  }

  // Hesap silme
  Future<void> deleteAccount() async {
    try {
      isLoading.value = true;
      await _authService.deleteAccount(user.value!.id);
      Get.snackbar('Başarılı', 'Hesabınız silindi');
    } finally {
      isLoading.value = false;
    }
  }
}
