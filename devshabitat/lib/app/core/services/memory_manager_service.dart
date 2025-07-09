import 'dart:async';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../interfaces/disposable.dart';

class MemoryManagerService extends GetxService {
  static MemoryManagerService get to => Get.find();

  final Logger _logger = Logger();
  final Map<String, StreamSubscription> _subscriptions = {};
  final Map<String, Timer> _timers = {};
  final Map<String, dynamic> _resources = {};

  // Stream subscription'ları yönet
  void registerSubscription(String id, StreamSubscription subscription) {
    if (_subscriptions.containsKey(id)) {
      _logger.w('Subscription with id $id already exists. Cancelling old one.');
      _subscriptions[id]?.cancel();
    }
    _subscriptions[id] = subscription;
  }

  void unregisterSubscription(String id) {
    _subscriptions[id]?.cancel();
    _subscriptions.remove(id);
  }

  // Timer'ları yönet
  void registerTimer(String id, Timer timer) {
    if (_timers.containsKey(id)) {
      _logger.w('Timer with id $id already exists. Cancelling old one.');
      _timers[id]?.cancel();
    }
    _timers[id] = timer;
  }

  void unregisterTimer(String id) {
    _timers[id]?.cancel();
    _timers.remove(id);
  }

  // Kaynakları yönet
  void registerResource(String id, dynamic resource) {
    if (_resources.containsKey(id)) {
      _logger.w('Resource with id $id already exists. Disposing old one.');
      disposeResource(id);
    }
    _resources[id] = resource;
  }

  void unregisterResource(String id) {
    disposeResource(id);
    _resources.remove(id);
  }

  // Kaynağı dispose et
  void disposeResource(String id) {
    final resource = _resources[id];
    if (resource == null) return;

    try {
      if (resource is Disposable) {
        resource.dispose();
      } else if (resource is StreamController) {
        resource.close();
      } else if (resource is Timer) {
        resource.cancel();
      } else if (resource is StreamSubscription) {
        resource.cancel();
      }
    } catch (e) {
      _logger.e('Error disposing resource $id: $e');
    }
  }

  // Tüm kaynakları temizle
  void disposeAll() {
    // Stream subscription'ları temizle
    for (var subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // Timer'ları temizle
    for (var timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();

    // Diğer kaynakları temizle
    for (var id in _resources.keys) {
      disposeResource(id);
    }
    _resources.clear();
  }

  // Memory kullanımını kontrol et
  void checkMemoryUsage() {
    _logger.i('Active subscriptions: ${_subscriptions.length}');
    _logger.i('Active timers: ${_timers.length}');
    _logger.i('Active resources: ${_resources.length}');
  }

  // Debug için detaylı bilgi
  void printDetailedMemoryInfo() {
    _logger.i('=== MEMORY MANAGER DETAILED INFO ===');
    _logger.i('Active subscriptions: ${_subscriptions.length}');
    _subscriptions.forEach((id, subscription) {
      _logger.i('  - Subscription: $id');
    });

    _logger.i('Active timers: ${_timers.length}');
    _timers.forEach((id, timer) {
      _logger.i('  - Timer: $id');
    });

    _logger.i('Active resources: ${_resources.length}');
    _resources.forEach((id, resource) {
      _logger.i('  - Resource: $id (${resource.runtimeType})');
    });
    _logger.i('=====================================');
  }

  // Belirli bir controller'ın kaynaklarını temizle
  void disposeControllerResources(String controllerId) {
    final pattern = RegExp('^${controllerId}_');

    _subscriptions.removeWhere((key, value) {
      if (pattern.hasMatch(key)) {
        value.cancel();
        _logger.i('Disposed subscription: $key');
        return true;
      }
      return false;
    });

    _timers.removeWhere((key, value) {
      if (pattern.hasMatch(key)) {
        value.cancel();
        _logger.i('Disposed timer: $key');
        return true;
      }
      return false;
    });

    _resources.removeWhere((key, value) {
      if (pattern.hasMatch(key)) {
        disposeResource(key);
        _logger.i('Disposed resource: $key');
        return true;
      }
      return false;
    });
  }

  @override
  void onClose() {
    disposeAll();
    super.onClose();
  }
}

// Controller'lar için mixin
mixin MemoryManagementMixin on GetxController {
  final String _controllerId = DateTime.now().millisecondsSinceEpoch.toString();
  final MemoryManagerService _memoryManager = Get.find();

  void registerSubscription(StreamSubscription subscription) {
    final id = '${_controllerId}_sub_${DateTime.now().millisecondsSinceEpoch}';
    _memoryManager.registerSubscription(id, subscription);
  }

  void registerTimer(Timer timer) {
    final id =
        '${_controllerId}_timer_${DateTime.now().millisecondsSinceEpoch}';
    _memoryManager.registerTimer(id, timer);
  }

  void registerResource(dynamic resource) {
    final id = '${_controllerId}_res_${DateTime.now().millisecondsSinceEpoch}';
    _memoryManager.registerResource(id, resource);
  }

  @override
  void onClose() {
    // Controller'a ait tüm kaynakları temizle
    final pattern = RegExp('^${_controllerId}_');
    _memoryManager._subscriptions.removeWhere((key, value) {
      if (pattern.hasMatch(key)) {
        value.cancel();
        return true;
      }
      return false;
    });

    _memoryManager._timers.removeWhere((key, value) {
      if (pattern.hasMatch(key)) {
        value.cancel();
        return true;
      }
      return false;
    });

    _memoryManager._resources.removeWhere((key, value) {
      if (pattern.hasMatch(key)) {
        _memoryManager.disposeResource(key);
        return true;
      }
      return false;
    });

    super.onClose();
  }
}
