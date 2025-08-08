import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/connection_model.dart';

class CacheService extends GetxService {
  late SharedPreferences _prefs;

  Future<CacheService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  Future<void> setData(String key, dynamic data) async {
    final jsonData = json.encode(data);
    await _prefs.setString(key, jsonData);
  }

  Future<dynamic> getData(String key) async {
    final jsonData = _prefs.getString(key);
    if (jsonData == null) return null;
    return json.decode(jsonData);
  }

  Future<void> removeData(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }

  Future<T> getOrFetch<T>(
    String key,
    Future<T> Function() fetchData, {
    Duration expiration = const Duration(minutes: 5),
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final data = await getData(key);
    if (data != null) {
      final timestamp = DateTime.parse(data['timestamp']);
      if (DateTime.now().difference(timestamp) < expiration) {
        if (fromJson != null && data['data'] is Map<String, dynamic>) {
          return fromJson(data['data'] as Map<String, dynamic>);
        } else if (data['data'] is List && T.toString().startsWith('List<')) {
          final list = data['data'] as List;
          if (T.toString() == 'List<ConnectionModel>') {
            return list
                    .map(
                      (item) => ConnectionModel.fromJson(
                        item as Map<String, dynamic>,
                      ),
                    )
                    .toList()
                as T;
          }
        }
        return data['data'] as T;
      }
    }

    final freshData = await fetchData();
    await setData(key, {
      'data': freshData,
      'timestamp': DateTime.now().toIso8601String(),
    });
    return freshData;
  }

  Set<String> get keys => _prefs.getKeys();

  Future<void> removeMultiple(List<String> keys) async {
    for (final key in keys) {
      await removeData(key);
    }
  }

  Map<String, dynamic> getStats() {
    return {
      'totalKeys': _prefs.getKeys().length,
      'keys': _prefs.getKeys().toList(),
    };
  }

  Duration? getTimeToExpiration(String key) {
    final data = _prefs.getString(key);
    if (data == null) return null;

    final decoded = json.decode(data);
    if (decoded['timestamp'] == null) return null;

    final timestamp = DateTime.parse(decoded['timestamp']);
    return DateTime.now().difference(timestamp);
  }
}
