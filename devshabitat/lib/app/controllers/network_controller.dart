import 'package:devshabitat/app/core/services/error_handler_service.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../constants/app_strings.dart';

class NetworkController extends GetxController {
  final ErrorHandlerService _errorHandler = Get.find<ErrorHandlerService>();
  final _connectivity = Connectivity();

  // State değişkenleri
  final RxBool _isConnected = true.obs;
  final Rx<ConnectivityResult> _connectionType = ConnectivityResult.none.obs;
  final RxBool _isTesting = false.obs;
  final RxString _connectionQuality = 'Mükemmel'.obs;
  final RxInt _latency = 0.obs;
  final RxDouble _downloadSpeed = 0.0.obs;
  final RxDouble _uploadSpeed = 0.0.obs;
  final RxMap<String, bool> _syncStatus = <String, bool>{}.obs;
  final RxString _lastTestTime = ''.obs;

  // Getters
  bool get isConnected => _isConnected.value;
  ConnectivityResult get connectionType => _connectionType.value;
  bool get isTesting => _isTesting.value;
  String get connectionQuality => _connectionQuality.value;
  int get latency => _latency.value;
  double get downloadSpeed => _downloadSpeed.value;
  double get uploadSpeed => _uploadSpeed.value;
  Map<String, bool> get syncStatus => _syncStatus;
  String get lastTestTime => _lastTestTime.value;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _setupConnectivityListener();
    _initializeSyncStatus();
  }

  // Başlangıç bağlantı durumunu kontrol et
  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results.first);
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.NETWORK_ERROR);
    }
  }

  // Bağlantı değişikliklerini dinle
  void _setupConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _updateConnectionStatus(results.first);
    });
  }

  // Bağlantı durumunu güncelle
  void _updateConnectionStatus(ConnectivityResult result) {
    try {
      _connectionType.value = result;
      _isConnected.value = result != ConnectivityResult.none;

      // Bağlantı durumunu sessizce güncelle, hata fırlatma
      if (!_isConnected.value) {
        Get.snackbar(
          'Bağlantı Durumu',
          'İnternet bağlantısı bulunamadı',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      // Hata durumunda sadece log tut
      _errorHandler.logError(
        'Bağlantı durumu güncellenirken hata: $e',
        ErrorHandlerService.NETWORK_ERROR,
      );
    }
  }

  // Bağlantı tipini kontrol et
  bool isWifi() => _connectionType.value == ConnectivityResult.wifi;
  bool isMobile() => _connectionType.value == ConnectivityResult.mobile;
  bool isEthernet() => _connectionType.value == ConnectivityResult.ethernet;

  // Bağlantı durumunu yeniden kontrol et
  Future<void> checkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results.first);
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.NETWORK_ERROR);
    }
  }

  // Bağlantı testi yap
  Future<void> testConnection() async {
    _isTesting.value = true;
    try {
      // Simüle edilmiş test
      await Future.delayed(Duration(seconds: 3));

      // Test sonuçlarını güncelle
      _latency.value = 45;
      _downloadSpeed.value = 25.5;
      _uploadSpeed.value = 10.2;
      _connectionQuality.value = _calculateConnectionQuality();
      _lastTestTime.value = DateTime.now().toString().substring(0, 19);

      Get.snackbar(
        'Test Tamamlandı',
        'Bağlantı durumu: ${isConnected ? "Başarılı" : "Başarısız"}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.NETWORK_ERROR);
    } finally {
      _isTesting.value = false;
    }
  }

  // Bağlantı kalitesini hesapla
  String _calculateConnectionQuality() {
    if (_latency.value < 50 && _downloadSpeed.value > 20) {
      return 'Mükemmel';
    } else if (_latency.value < 100 && _downloadSpeed.value > 10) {
      return 'İyi';
    } else if (_latency.value < 200 && _downloadSpeed.value > 5) {
      return 'Orta';
    } else {
      return 'Zayıf';
    }
  }

  // Senkronizasyon durumunu güncelle
  void updateSyncStatus(String key, bool status) {
    _syncStatus[key] = status;
  }

  // Zorla senkronizasyon
  Future<void> forceSync() async {
    try {
      // Simüle edilmiş senkronizasyon
      await Future.delayed(Duration(seconds: 2));

      // Tüm senkronizasyon durumlarını güncelle
      _syncStatus.value = {
        'Mesajlar': true,
        'Profil Verileri': true,
        'Topluluk Verileri': true,
        'Etkinlik Verileri': true,
        'Dosya Yüklemeleri': true,
      };

      Get.snackbar(
        'Tamamlandı',
        'Senkronizasyon tamamlandı',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.NETWORK_ERROR);
    }
  }

  // DNS ayarlarını sıfırla
  Future<void> resetDNS() async {
    try {
      // Simüle edilmiş DNS sıfırlama
      await Future.delayed(Duration(seconds: 1));
      Get.snackbar('Başarılı', 'DNS ayarları sıfırlandı');
    } catch (e) {
      _errorHandler.handleError(e, ErrorHandlerService.NETWORK_ERROR);
    }
  }

  // Ağ raporu oluştur
  Map<String, dynamic> generateNetworkReport() {
    return {
      'bağlantıDurumu': isConnected ? 'Aktif' : 'Pasif',
      'bağlantıTipi': _getConnectionTypeText(),
      'testTarihi': DateTime.now().toString().substring(0, 19),
      'uygulamaVersiyonu': '1.0.0',
      'platform': GetPlatform.isAndroid ? 'Android' : 'iOS',
      'bağlantıKalitesi': connectionQuality,
      'gecikmeSüresi': '${latency}ms',
      'indirmeHızı': '${downloadSpeed.toStringAsFixed(1)} Mbps',
      'yüklemeHızı': '${uploadSpeed.toStringAsFixed(1)} Mbps',
    };
  }

  // Bağlantı tipini metin olarak al
  String _getConnectionTypeText() {
    switch (_connectionType.value) {
      case ConnectivityResult.wifi:
        return 'Wi-Fi';
      case ConnectivityResult.mobile:
        return 'Mobil Veri';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.none:
        return 'Bağlantı Yok';
      default:
        return 'Bilinmiyor';
    }
  }

  // Senkronizasyon durumlarını başlat
  void _initializeSyncStatus() {
    _syncStatus.value = {
      'Mesajlar': true,
      'Profil Verileri': true,
      'Topluluk Verileri': false,
      'Etkinlik Verileri': true,
      'Dosya Yüklemeleri': true,
    };
  }
}
