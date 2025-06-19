import 'package:devshabitat/app/core/services/error_handler_service.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants/app_strings.dart';

class NetworkController extends GetxController {
  final ErrorHandlerService _errorHandler = Get.find<ErrorHandlerService>();
  final _connectivity = Connectivity();

  // State değişkenleri
  final RxBool _isConnected = true.obs;
  final Rx<ConnectivityResult> _connectionType = ConnectivityResult.none.obs;

  // Getters
  bool get isConnected => _isConnected.value;
  ConnectivityResult get connectionType => _connectionType.value;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _setupConnectivityListener();
  }

  // Başlangıç bağlantı durumunu kontrol et
  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results.first);
    } catch (e) {
      _errorHandler.handleError(e);
    }
  }

  // Bağlantı değişikliklerini dinle
  void _setupConnectivityListener() {
    _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results.first);
    });
  }

  // Bağlantı durumunu güncelle
  void _updateConnectionStatus(ConnectivityResult result) {
    _connectionType.value = result;
    _isConnected.value = result != ConnectivityResult.none;

    if (!_isConnected.value) {
      _errorHandler.handleError(AppStrings.errorNetwork);
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
      _errorHandler.handleError(e);
    }
  }
}
