// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import '../../services/encryption_service.dart';

class SecurityConfig {
  static final EncryptionService _encryptionService =
      Get.find<EncryptionService>();

  // API Key'ler için güvenli isimler
  static const String GOOGLE_MAPS_API_KEY = 'google_maps_api_key';
  static const String FIREBASE_API_KEY = 'firebase_api_key';
  static const String AGORA_APP_ID = 'agora_app_id';
  static const String FACEBOOK_APP_ID = 'facebook_app_id';

  // Dosya yükleme güvenlik limitleri
  static const int MAX_FILE_SIZE_MB = 10;
  static const List<String> ALLOWED_IMAGE_TYPES = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> ALLOWED_DOCUMENT_TYPES = ['pdf', 'doc', 'docx'];
  static const int MAX_FILE_NAME_LENGTH = 100;

  // Input validation sabitleri
  static const int MIN_PASSWORD_LENGTH = 8;
  static const int MAX_PASSWORD_LENGTH = 32;
  static const int MAX_USERNAME_LENGTH = 50;
  static const int MAX_EMAIL_LENGTH = 100;
  static const int MAX_PHONE_LENGTH = 15;
  static const String PASSWORD_PATTERN =
      r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$';
  static const String EMAIL_PATTERN = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String PHONE_PATTERN = r'^\+?[\d\s-]{8,}$';

  // Rate limiting
  static const int MAX_LOGIN_ATTEMPTS = 5;
  static const int LOGIN_LOCKOUT_MINUTES = 30;
  static const int MAX_API_REQUESTS_PER_MINUTE = 100;

  // Session güvenliği
  static const int SESSION_TIMEOUT_MINUTES = 60;
  static const bool FORCE_HTTPS = true;
  static const String JWT_SECRET_KEY = 'jwt_secret';

  // API Key'leri güvenli şekilde sakla
  static Future<void> secureApiKeys(Map<String, String> apiKeys) async {
    for (var entry in apiKeys.entries) {
      await _encryptionService.secureApiKey(entry.key, entry.value);
    }
  }

  // API Key'i güvenli şekilde al
  static Future<String?> getApiKey(String keyName) async {
    return await _encryptionService.getApiKey(keyName);
  }

  // Dosya güvenlik kontrolü
  static bool isFileSecure({
    required String fileName,
    required String fileType,
    required int fileSizeInBytes,
    List<String>? allowedTypes,
  }) {
    // Dosya adı kontrolü
    if (fileName.length > MAX_FILE_NAME_LENGTH) return false;
    if (!isFileNameSafe(fileName)) return false;

    // Dosya tipi kontrolü
    final type = fileType.toLowerCase();
    if (allowedTypes != null && !allowedTypes.contains(type)) return false;

    // Dosya boyutu kontrolü (MB cinsinden)
    final fileSizeMB = fileSizeInBytes / (1024 * 1024);
    if (fileSizeMB > MAX_FILE_SIZE_MB) return false;

    return true;
  }

  // Güvenli dosya adı kontrolü
  static bool isFileNameSafe(String fileName) {
    // Tehlikeli karakterleri ve path traversal girişimlerini engelle
    final dangerousPatterns = [
      r'\.\.', // Path traversal
      r'[<>:"/\\|?*]', // Tehlikeli karakterler
      r'(\.exe|\.php|\.js)$', // Tehlikeli uzantılar
    ];

    for (var pattern in dangerousPatterns) {
      if (RegExp(pattern).hasMatch(fileName)) return false;
    }

    return true;
  }

  // Input validation
  static bool isPasswordValid(String password) {
    if (password.length < MIN_PASSWORD_LENGTH) return false;
    if (password.length > MAX_PASSWORD_LENGTH) return false;
    return RegExp(PASSWORD_PATTERN).hasMatch(password);
  }

  static bool isEmailValid(String email) {
    if (email.length > MAX_EMAIL_LENGTH) return false;
    return RegExp(EMAIL_PATTERN).hasMatch(email);
  }

  static bool isPhoneValid(String phone) {
    if (phone.length > MAX_PHONE_LENGTH) return false;
    return RegExp(PHONE_PATTERN).hasMatch(phone);
  }

  static bool isUsernameValid(String username) {
    if (username.length > MAX_USERNAME_LENGTH) return false;
    // Sadece alfanumerik karakterler ve alt çizgi
    return RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username);
  }

  // XSS koruması için input sanitization
  static String sanitizeInput(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
  }

  // SQL Injection koruması için input sanitization
  static String sanitizeSqlInput(String input) {
    return input
        .replaceAll("'", "''")
        .replaceAll(';', '')
        .replaceAll('--', '')
        .replaceAll('/*', '')
        .replaceAll('*/', '');
  }
}
