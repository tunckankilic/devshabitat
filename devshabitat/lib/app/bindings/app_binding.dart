import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../core/services/error_handler_service.dart';
import '../repositories/enhanced_auth_repository.dart';
import '../controllers/enhanced_auth_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Servisleri başlat
    Get.put(Logger());
    Get.put(ErrorHandlerService());
    Get.put(EnhancedAuthRepository());
    Get.put(EnhancedAuthController(
      errorHandler: Get.find<ErrorHandlerService>(),
    ));
  }
}
