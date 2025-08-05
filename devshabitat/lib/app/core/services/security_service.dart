import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class SecurityService extends GetxService {
  final FlutterSecureStorage _secureStorage;

  SecurityService({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // Hassas veriyi güvenli şekilde sakla
  Future<void> secureStore(String key, String value) async {
    await _secureStorage.write(key: _hashKey(key), value: value);
  }

  // Güvenli depodan veri al
  Future<String?> secureRetrieve(String key) async {
    return await _secureStorage.read(key: _hashKey(key));
  }

  // Güvenli depodan veri sil
  Future<void> secureDelete(String key) async {
    await _secureStorage.delete(key: _hashKey(key));
  }

  // Tüm hassas veriyi temizle
  Future<void> clearAllSecureData() async {
    await _secureStorage.deleteAll();
  }

  // Anahtar hash'leme
  String _hashKey(String key) {
    var bytes = utf8.encode(key);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Bellek temizleme yardımcısı
  void secureClearMemory(List<String> sensitiveData) {
    for (var data in sensitiveData) {
      data = List.filled(data.length, '*').join();
    }
  }

  // Token yönetimi
  Future<void> storeToken({
    required String token,
    required String type,
    Duration expiry = const Duration(hours: 1),
  }) async {
    final expiryTime = DateTime.now()
        .add(expiry)
        .millisecondsSinceEpoch
        .toString();
    await secureStore('${type}_token', token);
    await secureStore('${type}_token_expiry', expiryTime);
  }

  Future<String?> getToken(String type) async {
    final token = await secureRetrieve('${type}_token');
    final expiryStr = await secureRetrieve('${type}_token_expiry');

    if (token == null || expiryStr == null) return null;

    final expiry = int.tryParse(expiryStr);
    if (expiry == null) return null;

    if (DateTime.now().millisecondsSinceEpoch > expiry) {
      await secureDelete('${type}_token');
      await secureDelete('${type}_token_expiry');
      return null;
    }

    return token;
  }

  // Konum verisi sanitizasyonu
  Map<String, double>? sanitizeLocation(Map<String, dynamic> rawLocation) {
    try {
      final lat = double.parse(rawLocation['latitude'].toString());
      final lng = double.parse(rawLocation['longitude'].toString());

      if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
        return null;
      }

      return {'latitude': lat, 'longitude': lng};
    } catch (e) {
      return null;
    }
  }
}
