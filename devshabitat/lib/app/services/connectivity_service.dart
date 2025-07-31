import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/error_handler_service.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity;
  final ErrorHandlerService _errorHandler;
  final SharedPreferences _prefs;
  final RxBool isOnline = true.obs;
  final RxBool isOfflineModeEnabled = false.obs;

  ConnectivityService({
    required SharedPreferences prefs,
    required ErrorHandlerService errorHandler,
    Connectivity? connectivity,
  })  : _prefs = prefs,
        _errorHandler = errorHandler,
        _connectivity = connectivity ?? Get.find<Connectivity>();

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _loadOfflinePreference();
    _setupConnectivityStream();
  }

  // Başlangıç bağlantı durumunu kontrol et
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result.first);
    } catch (e) {
      _errorHandler.handleError(
          'Bağlantı durumu kontrol edilirken hata oluştu: $e',
          ErrorHandlerService.NETWORK_ERROR);
    }
  }

  // Offline mod tercihini yükle
  void _loadOfflinePreference() {
    isOfflineModeEnabled.value =
        _prefs.getBool('offline_mode_enabled') ?? false;
  }

  // Bağlantı durumu değişikliklerini dinle
  void _setupConnectivityStream() {
    _connectivity.onConnectivityChanged.listen(
      (result) {
        _updateConnectionStatus(result.first);
      },
      onError: (error) {
        _errorHandler.handleError(
            'Bağlantı durumu izlenirken hata oluştu: $error',
            ErrorHandlerService.NETWORK_ERROR);
      },
    );
  }

  // Bağlantı durumunu güncelle
  void _updateConnectionStatus(ConnectivityResult result) {
    isOnline.value = result != ConnectivityResult.none;
    if (!isOnline.value && isOfflineModeEnabled.value) {
      _errorHandler.handleInfo('Offline moda geçildi');
    } else if (isOnline.value && isOfflineModeEnabled.value) {
      _errorHandler.handleInfo('Online moda geçildi');
    }
  }

  // Offline modu etkinleştir/devre dışı bırak
  Future<void> toggleOfflineMode(bool enabled) async {
    try {
      isOfflineModeEnabled.value = enabled;
      await _prefs.setBool('offline_mode_enabled', enabled);

      if (enabled) {
        _errorHandler.handleSuccess('Offline mod etkinleştirildi');
      } else {
        _errorHandler.handleSuccess('Offline mod devre dışı bırakıldı');
      }
    } catch (e) {
      _errorHandler.handleError('Offline mod ayarlanırken hata oluştu: $e',
          ErrorHandlerService.NETWORK_ERROR);
    }
  }

  // Bağlantı durumunu kontrol et
  bool canPerformOperation() {
    return isOnline.value || isOfflineModeEnabled.value;
  }

  // Offline modda çalışabilir mi kontrol et
  bool canWorkOffline() {
    return isOfflineModeEnabled.value;
  }
}
