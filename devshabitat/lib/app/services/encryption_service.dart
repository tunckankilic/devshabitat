import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static const String _keyStorageKey = 'encryption_key';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late final Key _key;
  late final IV _iv;
  late final Encrypter _encrypter;

  // Singleton pattern
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  Future<void> initialize() async {
    try {
      // Kayıtlı anahtarı al veya yeni oluştur
      String? storedKey = await _secureStorage.read(key: _keyStorageKey);
      if (storedKey == null) {
        final key = Key.fromSecureRandom(32); // 256-bit key
        await _secureStorage.write(
          key: _keyStorageKey,
          value: key.base64,
        );
        _key = key;
      } else {
        _key = Key.fromBase64(storedKey);
      }

      // Initialization Vector (IV) oluştur
      _iv = IV.fromSecureRandom(16);

      // AES encrypter'ı yapılandır
      _encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
    } catch (e) {
      throw Exception('Encryption servisi başlatılamadı: $e');
    }
  }

  Future<String> encryptMessage(String content) async {
    try {
      if (content.isEmpty) {
        throw Exception('Şifrelenecek içerik boş olamaz');
      }

      final encrypted = _encrypter.encrypt(content, iv: _iv);
      // IV'yi encrypted data ile birlikte sakla
      return '${_iv.base64}:${encrypted.base64}';
    } catch (e) {
      throw Exception('Mesaj şifreleme hatası: $e');
    }
  }

  Future<String> decryptMessage(String encrypted) async {
    try {
      if (encrypted.isEmpty) {
        throw Exception('Şifresi çözülecek içerik boş olamaz');
      }

      // IV ve encrypted data'yı ayır
      final parts = encrypted.split(':');
      if (parts.length != 2) {
        throw Exception('Geçersiz şifrelenmiş veri formatı');
      }

      final iv = IV.fromBase64(parts[0]);
      final encryptedData = Encrypted.fromBase64(parts[1]);

      return _encrypter.decrypt(encryptedData, iv: iv);
    } catch (e) {
      throw Exception('Mesaj şifre çözme hatası: $e');
    }
  }

  // Güvenli temizleme
  Future<void> clearEncryptionKey() async {
    try {
      await _secureStorage.delete(key: _keyStorageKey);
    } catch (e) {
      throw Exception('Şifreleme anahtarı temizleme hatası: $e');
    }
  }
}
