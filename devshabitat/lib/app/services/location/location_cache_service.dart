import 'dart:async';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import '../../models/location/location_model.dart';

class LocationCacheService extends GetxService {
  static const String _locationBoxName = 'location_cache';
  static const int _maxCacheSize = 100;
  static const Duration _maxCacheAge = Duration(hours: 24);

  late Box<LocationModel> _locationBox;
  final Logger _logger = Get.find();

  Future<LocationCacheService> init() async {
    try {
      Hive.registerAdapter(LocationModelAdapter());
      _locationBox = await Hive.openBox<LocationModel>(_locationBoxName);
      await _cleanOldCache();
      return this;
    } catch (e) {
      _logger.e('Location cache initialization error: $e');
      rethrow;
    }
  }

  Future<void> cacheLocation(LocationModel location) async {
    try {
      if (_locationBox.length >= _maxCacheSize) {
        await _removeOldestLocation();
      }

      final key = DateTime.now().millisecondsSinceEpoch.toString();
      await _locationBox.put(key, location);
    } catch (e) {
      _logger.e('Location caching error: $e');
    }
  }

  Future<LocationModel?> getLastLocation() async {
    try {
      if (_locationBox.isEmpty) return null;

      final sortedKeys = _locationBox.keys.toList()
        ..sort((a, b) => b.toString().compareTo(a.toString()));

      return _locationBox.get(sortedKeys.first);
    } catch (e) {
      _logger.e('Get last location error: $e');
      return null;
    }
  }

  Future<List<LocationModel>> getLocationHistory({
    Duration duration = const Duration(hours: 1),
  }) async {
    try {
      final now = DateTime.now();
      final threshold = now.subtract(duration);

      return _locationBox.values
          .where((location) => location.timestamp.isAfter(threshold))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      _logger.e('Get location history error: $e');
      return [];
    }
  }

  Future<void> _cleanOldCache() async {
    try {
      final now = DateTime.now();
      final keysToDelete = _locationBox.keys.where((key) {
        final location = _locationBox.get(key);
        return location != null &&
            now.difference(location.timestamp) > _maxCacheAge;
      }).toList();

      await _locationBox.deleteAll(keysToDelete);
    } catch (e) {
      _logger.e('Cache cleaning error: $e');
    }
  }

  Future<void> _removeOldestLocation() async {
    try {
      final sortedKeys = _locationBox.keys.toList()
        ..sort((a, b) => a.toString().compareTo(b.toString()));

      if (sortedKeys.isNotEmpty) {
        await _locationBox.delete(sortedKeys.first);
      }
    } catch (e) {
      _logger.e('Remove oldest location error: $e');
    }
  }

  @override
  void onClose() {
    _locationBox.close();
    super.onClose();
  }
}
