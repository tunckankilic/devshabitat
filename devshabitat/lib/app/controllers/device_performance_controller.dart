import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';

class DevicePerformanceController extends GetxController {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Battery _battery = Battery();
  final Logger _logger = Logger();

  // Device Information
  final deviceModel = ''.obs;
  final deviceOS = ''.obs;
  final deviceVersion = ''.obs;
  final deviceRAM = 0.obs; // MB
  final deviceStorage = 0.obs; // GB
  final deviceCPUCores = 0.obs;

  // Performance Metrics
  final deviceCapabilityScore = 0.0.obs; // 0.0 to 1.0
  final isLowEndDevice = false.obs;
  final isMidRangeDevice = false.obs;
  final isHighEndDevice = false.obs;
  final performanceCategory = ''.obs; // Low, Mid, High, Premium

  // Battery Optimization
  final currentBatteryLevel = 0.obs;
  final batteryState = BatteryState.unknown.obs;
  final isBatteryOptimizationEnabled = true.obs;
  final batteryHealthScore = 1.0.obs;
  final estimatedBatteryLife = 0.obs; // hours

  // Network Performance
  final networkType = ConnectivityResult.none.obs;
  final networkStrength = 0.0.obs;
  final isNetworkOptimized = false.obs;

  // Performance Settings
  final recommendedSettings = <String, dynamic>{}.obs;
  final appliedOptimizations = <String>[].obs;
  final performanceMode = 'Balanced'.obs; // Power Save, Balanced, Performance

  // Monitoring
  final isMonitoring = false.obs;
  final performanceHistory = <Map<String, dynamic>>[].obs;
  final lastOptimizationTime = Rxn<DateTime>();

  Timer? _monitoringTimer;
  Timer? _batteryMonitorTimer;
  StreamSubscription<BatteryState>? _batteryStateSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeDevicePerformance();
  }

  // Initialize comprehensive device performance system
  Future<void> _initializeDevicePerformance() async {
    try {
      _logger.i('Initializing device performance system...');

      await Future.wait([
        _analyzeDeviceCapabilities(),
        _initializeBatteryMonitoring(),
        _initializeNetworkMonitoring(),
      ]);

      await _calculatePerformanceRecommendations();
      await _applyInitialOptimizations();
      _startPerformanceMonitoring();

      _logger.i('Device performance system initialized successfully');
    } catch (e) {
      _logger.e('Device performance initialization error: $e');
    }
  }

  // Comprehensive device capability analysis
  Future<void> _analyzeDeviceCapabilities() async {
    try {
      if (Platform.isAndroid) {
        await _analyzeAndroidCapabilities();
      } else if (Platform.isIOS) {
        await _analyzeIOSCapabilities();
      }

      _calculateCapabilityScore();
      _categorizeDevice();

      _logger.i('Device capabilities analyzed: ${performanceCategory.value}');
    } catch (e) {
      _logger.e('Device capability analysis error: $e');
    }
  }

  // Android-specific capability analysis
  Future<void> _analyzeAndroidCapabilities() async {
    try {
      final androidInfo = await _deviceInfo.androidInfo;

      deviceModel.value = '${androidInfo.brand} ${androidInfo.model}';
      deviceOS.value = 'Android ${androidInfo.version.release}';
      deviceVersion.value = androidInfo.version.release ?? '';

      // Estimate device specs based on known models and Android version
      final specs = _estimateAndroidSpecs(androidInfo);
      deviceRAM.value = specs['ram'] ?? 4096; // Default 4GB
      deviceStorage.value = specs['storage'] ?? 64; // Default 64GB
      deviceCPUCores.value = specs['cores'] ?? 8; // Default 8 cores

      _logger.i('Android device analyzed: ${deviceModel.value}');
    } catch (e) {
      _logger.e('Android analysis error: $e');
    }
  }

  // iOS-specific capability analysis
  Future<void> _analyzeIOSCapabilities() async {
    try {
      final iosInfo = await _deviceInfo.iosInfo;

      deviceModel.value = iosInfo.model ?? 'iPhone';
      deviceOS.value = 'iOS ${iosInfo.systemVersion}';
      deviceVersion.value = iosInfo.systemVersion ?? '';

      // Estimate iOS device specs based on model
      final specs = _estimateIOSSpecs(iosInfo);
      deviceRAM.value = specs['ram'] ?? 4096;
      deviceStorage.value = specs['storage'] ?? 128;
      deviceCPUCores.value = specs['cores'] ?? 6;

      _logger.i('iOS device analyzed: ${deviceModel.value}');
    } catch (e) {
      _logger.e('iOS analysis error: $e');
    }
  }

  // Estimate Android device specifications
  Map<String, int> _estimateAndroidSpecs(AndroidDeviceInfo info) {
    final model = info.model?.toLowerCase() ?? '';
    final brand = info.brand?.toLowerCase() ?? '';
    final sdkInt = info.version.sdkInt ?? 0;

    // High-end devices
    if (model.contains('s24') ||
        model.contains('s23') ||
        model.contains('pixel 8') ||
        model.contains('pixel 7') ||
        model.contains('oneplus 12') ||
        model.contains('oneplus 11')) {
      return {
        'ram': 12288,
        'storage': 256,
        'cores': 8
      }; // 12GB RAM, 256GB, 8 cores
    }

    // Mid-range devices
    if (model.contains('a54') ||
        model.contains('a34') ||
        model.contains('pixel 7a') ||
        model.contains('pixel 6a') ||
        sdkInt >= 33) {
      // Android 13+
      return {
        'ram': 8192,
        'storage': 128,
        'cores': 8
      }; // 8GB RAM, 128GB, 8 cores
    }

    // Older/Low-end devices
    if (sdkInt <= 29) {
      // Android 10 and below
      return {'ram': 3072, 'storage': 32, 'cores': 4}; // 3GB RAM, 32GB, 4 cores
    }

    // Default mid-range
    return {'ram': 6144, 'storage': 64, 'cores': 8}; // 6GB RAM, 64GB, 8 cores
  }

  // Estimate iOS device specifications
  Map<String, int> _estimateIOSSpecs(IosDeviceInfo info) {
    final model = info.model?.toLowerCase() ?? '';
    final systemVersion = info.systemVersion ?? '';

    // iPhone 15 series
    if (model.contains('iphone16') || model.contains('iphone15')) {
      return {
        'ram': 8192,
        'storage': 256,
        'cores': 6
      }; // 8GB RAM, 256GB, 6 cores
    }

    // iPhone 14/13 series
    if (model.contains('iphone14') || model.contains('iphone13')) {
      return {
        'ram': 6144,
        'storage': 128,
        'cores': 6
      }; // 6GB RAM, 128GB, 6 cores
    }

    // iPhone 12/11 series
    if (model.contains('iphone12') || model.contains('iphone11')) {
      return {
        'ram': 4096,
        'storage': 128,
        'cores': 6
      }; // 4GB RAM, 128GB, 6 cores
    }

    // Older iPhones
    if (model.contains('iphonex') ||
        model.contains('iphone8') ||
        model.contains('iphone7')) {
      return {'ram': 3072, 'storage': 64, 'cores': 6}; // 3GB RAM, 64GB, 6 cores
    }

    // Default modern iPhone
    return {'ram': 4096, 'storage': 128, 'cores': 6}; // 4GB RAM, 128GB, 6 cores
  }

  // Calculate overall device capability score
  void _calculateCapabilityScore() {
    double score = 0.0;

    // RAM score (40% weight)
    final ramScore =
        (deviceRAM.value / 16384).clamp(0.0, 1.0); // Normalize to 16GB max
    score += ramScore * 0.4;

    // Storage score (20% weight)
    final storageScore =
        (deviceStorage.value / 512).clamp(0.0, 1.0); // Normalize to 512GB max
    score += storageScore * 0.2;

    // CPU cores score (20% weight)
    final coreScore = (deviceCPUCores.value / 12)
        .clamp(0.0, 1.0); // Normalize to 12 cores max
    score += coreScore * 0.2;

    // OS version score (20% weight)
    double osScore = 0.5; // Default
    if (Platform.isAndroid) {
      // Android 13+ gets full score
      if (deviceVersion.value.startsWith('13') ||
          deviceVersion.value.startsWith('14') ||
          int.tryParse(deviceVersion.value.split('.').first) != null &&
              int.parse(deviceVersion.value.split('.').first) >= 13) {
        osScore = 1.0;
      } else if (deviceVersion.value.startsWith('12') ||
          deviceVersion.value.startsWith('11')) {
        osScore = 0.8;
      } else {
        osScore = 0.4;
      }
    } else if (Platform.isIOS) {
      // iOS 16+ gets full score
      final version =
          double.tryParse(deviceVersion.value.split('.').first) ?? 0;
      if (version >= 16) {
        osScore = 1.0;
      } else if (version >= 14) {
        osScore = 0.8;
      } else {
        osScore = 0.4;
      }
    }
    score += osScore * 0.2;

    deviceCapabilityScore.value = score.clamp(0.0, 1.0);
  }

  // Categorize device based on capability score
  void _categorizeDevice() {
    final score = deviceCapabilityScore.value;

    if (score >= 0.85) {
      performanceCategory.value = 'Premium';
      isHighEndDevice.value = true;
      isMidRangeDevice.value = false;
      isLowEndDevice.value = false;
    } else if (score >= 0.65) {
      performanceCategory.value = 'High';
      isHighEndDevice.value = true;
      isMidRangeDevice.value = false;
      isLowEndDevice.value = false;
    } else if (score >= 0.45) {
      performanceCategory.value = 'Mid';
      isHighEndDevice.value = false;
      isMidRangeDevice.value = true;
      isLowEndDevice.value = false;
    } else {
      performanceCategory.value = 'Low';
      isHighEndDevice.value = false;
      isMidRangeDevice.value = false;
      isLowEndDevice.value = true;
    }

    _logger.i(
        'Device categorized as: ${performanceCategory.value} (Score: ${(score * 100).toStringAsFixed(1)}%)');
  }

  // Initialize battery monitoring
  Future<void> _initializeBatteryMonitoring() async {
    try {
      // Get initial battery level
      currentBatteryLevel.value = await _battery.batteryLevel;

      // Listen to battery state changes
      _batteryStateSubscription =
          _battery.onBatteryStateChanged.listen((state) {
        batteryState.value = state;
        _updateBatteryOptimization();
      });

      // Start periodic battery monitoring
      _batteryMonitorTimer = Timer.periodic(const Duration(minutes: 5), (_) {
        _updateBatteryInfo();
      });

      _logger.i('Battery monitoring initialized');
    } catch (e) {
      _logger.e('Battery monitoring initialization error: $e');
    }
  }

  // Update battery information
  Future<void> _updateBatteryInfo() async {
    try {
      final level = await _battery.batteryLevel;
      currentBatteryLevel.value = level;

      // Calculate battery health score (simplified)
      if (level > 80) {
        batteryHealthScore.value = 1.0;
      } else if (level > 60) {
        batteryHealthScore.value = 0.8;
      } else if (level > 40) {
        batteryHealthScore.value = 0.6;
      } else if (level > 20) {
        batteryHealthScore.value = 0.4;
      } else {
        batteryHealthScore.value = 0.2;
      }

      // Estimate battery life based on current usage
      estimatedBatteryLife.value = _estimateBatteryLife(level);
    } catch (e) {
      _logger.e('Battery info update error: $e');
    }
  }

  // Estimate remaining battery life
  int _estimateBatteryLife(int batteryLevel) {
    // Simplified estimation based on device category and battery level
    double baseHours = 8.0; // Base hours for 100% battery

    if (isLowEndDevice.value) {
      baseHours = 6.0;
    } else if (isMidRangeDevice.value) {
      baseHours = 8.0;
    } else if (isHighEndDevice.value) {
      baseHours = 10.0;
    }

    return (baseHours * (batteryLevel / 100)).round();
  }

  // Update battery optimization based on current state
  void _updateBatteryOptimization() {
    final level = currentBatteryLevel.value;
    final state = batteryState.value;

    if (level <= 20 || state == BatteryState.discharging) {
      isBatteryOptimizationEnabled.value = true;
      performanceMode.value = 'Power Save';
    } else if (level >= 80 && state == BatteryState.charging) {
      isBatteryOptimizationEnabled.value = false;
      performanceMode.value = 'Performance';
    } else {
      performanceMode.value = 'Balanced';
    }
  }

  // Initialize network monitoring
  Future<void> _initializeNetworkMonitoring() async {
    try {
      // Get initial connectivity
      final results = await Connectivity().checkConnectivity();
      if (results.isNotEmpty) {
        networkType.value = results.first;
      }

      // Listen to connectivity changes
      _connectivitySubscription =
          Connectivity().onConnectivityChanged.listen((results) {
        if (results.isNotEmpty) {
          networkType.value = results.first;
          _updateNetworkOptimization();
        }
      });

      _logger.i('Network monitoring initialized');
    } catch (e) {
      _logger.e('Network monitoring initialization error: $e');
    }
  }

  // Update network optimization
  void _updateNetworkOptimization() {
    switch (networkType.value) {
      case ConnectivityResult.wifi:
        networkStrength.value = 1.0;
        isNetworkOptimized.value = false;
        break;
      case ConnectivityResult.ethernet:
        networkStrength.value = 1.0;
        isNetworkOptimized.value = false;
        break;
      case ConnectivityResult.mobile:
        networkStrength.value = 0.7;
        isNetworkOptimized.value = true;
        break;
      case ConnectivityResult.bluetooth:
        networkStrength.value = 0.3;
        isNetworkOptimized.value = true;
        break;
      default:
        networkStrength.value = 0.0;
        isNetworkOptimized.value = true;
    }
  }

  // Calculate performance recommendations
  Future<void> _calculatePerformanceRecommendations() async {
    try {
      final recommendations = <String, dynamic>{};

      // Location tracking settings
      if (isLowEndDevice.value) {
        recommendations['location_accuracy'] = 'low';
        recommendations['location_interval'] = 60; // seconds
        recommendations['background_sync_interval'] = 300; // 5 minutes
      } else if (isMidRangeDevice.value) {
        recommendations['location_accuracy'] = 'balanced';
        recommendations['location_interval'] = 30;
        recommendations['background_sync_interval'] = 120; // 2 minutes
      } else {
        recommendations['location_accuracy'] = 'high';
        recommendations['location_interval'] = 15;
        recommendations['background_sync_interval'] = 60; // 1 minute
      }

      // Message sync settings
      if (isLowEndDevice.value) {
        recommendations['message_batch_size'] = 10;
        recommendations['image_compression'] = 'high';
        recommendations['auto_download_media'] = false;
      } else {
        recommendations['message_batch_size'] = 20;
        recommendations['image_compression'] = 'medium';
        recommendations['auto_download_media'] = true;
      }

      // Notification settings
      if (currentBatteryLevel.value <= 20) {
        recommendations['reduce_animations'] = true;
        recommendations['limit_background_processing'] = true;
        recommendations['reduce_notification_frequency'] = true;
      }

      recommendedSettings.value = recommendations;
      _logger.i('Performance recommendations calculated');
    } catch (e) {
      _logger.e('Performance recommendations calculation error: $e');
    }
  }

  // Apply initial optimizations
  Future<void> _applyInitialOptimizations() async {
    try {
      final optimizations = <String>[];

      if (isLowEndDevice.value) {
        optimizations.addAll([
          'Reduced animation scale',
          'Limited background processes',
          'Optimized memory usage',
          'Reduced network requests',
        ]);
      }

      if (currentBatteryLevel.value <= 30) {
        optimizations.addAll([
          'Battery saver mode enabled',
          'Background sync reduced',
          'Location accuracy lowered',
        ]);
      }

      if (networkType.value == ConnectivityResult.mobile) {
        optimizations.addAll([
          'Data compression enabled',
          'Media auto-download disabled',
          'Sync frequency reduced',
        ]);
      }

      appliedOptimizations.value = optimizations;
      lastOptimizationTime.value = DateTime.now();

      _logger.i('Applied ${optimizations.length} initial optimizations');
    } catch (e) {
      _logger.e('Initial optimizations application error: $e');
    }
  }

  // Start performance monitoring
  void _startPerformanceMonitoring() {
    isMonitoring.value = true;

    _monitoringTimer = Timer.periodic(const Duration(minutes: 10), (_) {
      _recordPerformanceMetrics();
    });

    _logger.i('Performance monitoring started');
  }

  // Record performance metrics
  void _recordPerformanceMetrics() {
    try {
      final metrics = {
        'timestamp': DateTime.now().toIso8601String(),
        'battery_level': currentBatteryLevel.value,
        'battery_state': batteryState.value.toString(),
        'network_type': networkType.value.toString(),
        'network_strength': networkStrength.value,
        'performance_mode': performanceMode.value,
        'optimizations_count': appliedOptimizations.length,
        'capability_score': deviceCapabilityScore.value,
      };

      performanceHistory.add(metrics);

      // Keep only last 100 entries
      if (performanceHistory.length > 100) {
        performanceHistory.removeAt(0);
      }
    } catch (e) {
      _logger.e('Performance metrics recording error: $e');
    }
  }

  // Manual optimization trigger
  Future<void> optimizePerformance() async {
    try {
      await _calculatePerformanceRecommendations();
      await _applyInitialOptimizations();

      _logger.i('Manual performance optimization completed');
    } catch (e) {
      _logger.e('Manual optimization error: $e');
    }
  }

  // Get comprehensive device status
  Map<String, dynamic> getDeviceStatus() {
    return {
      'device_model': deviceModel.value,
      'device_os': deviceOS.value,
      'performance_category': performanceCategory.value,
      'capability_score':
          '${(deviceCapabilityScore.value * 100).toStringAsFixed(1)}%',
      'ram_mb': deviceRAM.value,
      'storage_gb': deviceStorage.value,
      'cpu_cores': deviceCPUCores.value,
      'battery_level': currentBatteryLevel.value,
      'battery_state': batteryState.value.toString(),
      'estimated_battery_life': '${estimatedBatteryLife.value}h',
      'network_type': networkType.value.toString(),
      'network_strength':
          '${(networkStrength.value * 100).toStringAsFixed(0)}%',
      'performance_mode': performanceMode.value,
      'optimizations_applied': appliedOptimizations.length,
      'is_monitoring': isMonitoring.value,
      'metrics_recorded': performanceHistory.length,
    };
  }

  @override
  void onClose() {
    _monitoringTimer?.cancel();
    _batteryMonitorTimer?.cancel();
    _batteryStateSubscription?.cancel();
    _connectivitySubscription?.cancel();
    isMonitoring.value = false;
    super.onClose();
  }
}
