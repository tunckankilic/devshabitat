import 'package:devshabitat/app/controllers/auth_controller.dart';
import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../core/services/error_handler_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Servisleri başlat
    Get.put(Logger());
    Get.put(ErrorHandlerService());

    Get.put(AuthController(
      authRepository: Get.put(AuthRepository()),
      errorHandler: Get.find<ErrorHandlerService>(),
    ));
  }
}
