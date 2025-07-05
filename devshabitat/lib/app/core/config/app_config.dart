import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class AppConfig extends GetxService {
  static AppConfig get to => Get.find();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late final encrypt.Encrypter _encrypter;
  late final encrypt.IV _iv;

  // Güvenlik ayarları
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedFileTypes = ['jpg', 'jpeg', 'png', 'pdf'];
  static const int maxPasswordLength = 128;
  static const int minPasswordLength = 8;
  static const Duration tokenExpiration = Duration(hours: 24);
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 30);

  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

  @override
  void onInit() {
    super.onInit();
    _initializeEncryption();
  }

  Future<void> _initializeEncryption() async {
    final key = await _getOrGenerateKey();
    _encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key.fromBase64(key)));
    _iv = encrypt.IV.fromLength(16);
  }

  Future<String> _getOrGenerateKey() async {
    String? key = await _secureStorage.read(key: 'encryption_key');
    if (key == null) {
      final newKey = encrypt.Key.fromSecureRandom(32);
      key = newKey.base64;
      await _secureStorage.write(key: 'encryption_key', value: key);
    }
    return key;
  }

  // API Anahtarları Yönetimi
  Future<void> setApiKey(String service, String apiKey) async {
    final encrypted = _encrypter.encrypt(apiKey, iv: _iv);
    await _secureStorage.write(
        key: '${service}_api_key', value: encrypted.base64);
  }

  Future<String?> getApiKey(String service) async {
    final encrypted = await _secureStorage.read(key: '${service}_api_key');
    if (encrypted == null) return null;

    final decrypted = _encrypter.decrypt64(encrypted, iv: _iv);
    return decrypted;
  }

  // Input Validation
  bool isValidEmail(String email) {
    return GetUtils.isEmail(email);
  }

  bool isValidPassword(String password) {
    if (password.length < minPasswordLength ||
        password.length > maxPasswordLength) {
      return false;
    }

    // En az bir büyük harf
    if (!password.contains(RegExp(r'[A-Z]'))) return false;

    // En az bir küçük harf
    if (!password.contains(RegExp(r'[a-z]'))) return false;

    // En az bir rakam
    if (!password.contains(RegExp(r'[0-9]'))) return false;

    // En az bir özel karakter
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;

    return true;
  }

  bool isValidUsername(String username) {
    return RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(username);
  }

  String sanitizeInput(String input) {
    // HTML ve tehlikeli karakterleri temizle
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp("[<>\"'\\/`]"), "");
  }

  // Dosya Güvenliği
  bool isValidFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return allowedFileTypes.contains(extension);
  }

  bool isValidFileSize(int fileSize) {
    return fileSize <= maxFileSize;
  }

  // Token Yönetimi
  Future<void> setAuthToken(String token) async {
    final expiry = DateTime.now().add(tokenExpiration);
    await _secureStorage.write(key: 'auth_token', value: token);
    await _secureStorage.write(
      key: 'token_expiry',
      value: expiry.toIso8601String(),
    );
  }

  Future<String?> getAuthToken() async {
    final expiryStr = await _secureStorage.read(key: 'token_expiry');
    if (expiryStr == null) return null;

    final expiry = DateTime.parse(expiryStr);
    if (DateTime.now().isAfter(expiry)) {
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'token_expiry');
      return null;
    }

    return await _secureStorage.read(key: 'auth_token');
  }

  // Rate Limiting
  final Map<String, List<DateTime>> _loginAttempts = {};

  bool canAttemptLogin(String userId) {
    final attempts = _loginAttempts[userId] ?? [];
    final now = DateTime.now();

    // Eski girişimleri temizle
    attempts.removeWhere(
      (attempt) => now.difference(attempt) > lockoutDuration,
    );

    if (attempts.length >= maxLoginAttempts) {
      final oldestAttempt = attempts.first;
      if (now.difference(oldestAttempt) < lockoutDuration) {
        return false;
      }
      attempts.clear();
    }

    attempts.add(now);
    _loginAttempts[userId] = attempts;
    return true;
  }

  void clearLoginAttempts(String userId) {
    _loginAttempts.remove(userId);
  }
}
