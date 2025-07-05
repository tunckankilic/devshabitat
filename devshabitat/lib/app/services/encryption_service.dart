import 'dart:convert';
import 'dart:math' show Random;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:crypto/crypto.dart';

class EncryptionService extends GetxService {
  static EncryptionService get to => Get.find();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Logger _logger = Logger();
  late encrypt.Encrypter _encrypter;
  late encrypt.IV _iv;

  // Şifreleme anahtarı için salt
  static const String _salt = 'devshabitat_secure_salt';

  Future<void> init() async {
    try {
      // Şifreleme anahtarını al veya oluştur
      String? encryptionKey = await _secureStorage.read(key: 'encryption_key');
      if (encryptionKey == null) {
        encryptionKey = _generateSecureKey();
        await _secureStorage.write(key: 'encryption_key', value: encryptionKey);
      }

      // Şifreleme için gerekli nesneleri oluştur
      final key = encrypt.Key.fromBase64(encryptionKey);
      _iv = encrypt.IV.fromLength(16);
      _encrypter = encrypt.Encrypter(encrypt.AES(key));

      _logger.i('Encryption service initialized successfully');
    } catch (e) {
      _logger.e('Error initializing encryption service: $e');
      rethrow;
    }
  }

  String _generateSecureKey() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final data = utf8.encode('$_salt$timestamp');
    final hash = sha256.convert(data);
    final key = base64.encode(hash.bytes);
    return key.substring(0, 32); // AES-256 için 32 byte
  }

  // API key'leri şifrele
  Future<void> secureApiKey(String keyName, String value) async {
    try {
      final encrypted = _encrypter.encrypt(value, iv: _iv);
      await _secureStorage.write(
        key: 'api_key_$keyName',
        value: encrypted.base64,
      );
    } catch (e) {
      _logger.e('Error encrypting API key: $e');
      rethrow;
    }
  }

  // API key'leri çöz
  Future<String?> getApiKey(String keyName) async {
    try {
      final encrypted = await _secureStorage.read(key: 'api_key_$keyName');
      if (encrypted == null) return null;

      final decrypted = _encrypter.decrypt64(encrypted, iv: _iv);
      return decrypted;
    } catch (e) {
      _logger.e('Error decrypting API key: $e');
      return null;
    }
  }

  // Hassas verileri şifrele
  String encryptSensitiveData(String data) {
    try {
      return _encrypter.encrypt(data, iv: _iv).base64;
    } catch (e) {
      _logger.e('Error encrypting sensitive data: $e');
      rethrow;
    }
  }

  // Şifrelenmiş verileri çöz
  String? decryptSensitiveData(String encryptedData) {
    try {
      return _encrypter.decrypt64(encryptedData, iv: _iv);
    } catch (e) {
      _logger.e('Error decrypting sensitive data: $e');
      return null;
    }
  }

  // Güvenli hash oluştur
  String generateSecureHash(String data) {
    final bytes = utf8.encode(data + _salt);
    return sha256.convert(bytes).toString();
  }

  // Güvenli rastgele string oluştur
  String generateSecureRandomString(int length) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url.encode(values).substring(0, length);
  }

  // Tüm API key'leri sil
  Future<void> clearAllApiKeys() async {
    try {
      final allKeys = await _secureStorage.readAll();
      for (var key in allKeys.keys) {
        if (key.startsWith('api_key_')) {
          await _secureStorage.delete(key: key);
        }
      }
    } catch (e) {
      _logger.e('Error clearing API keys: $e');
      rethrow;
    }
  }
}
