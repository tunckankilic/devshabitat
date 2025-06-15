import 'package:get/get.dart';
import '../core/services/error_handler_service.dart';
import '../repositories/auth_repository.dart';
import '../controllers/auth_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Servisler
    Get.put(ErrorHandlerService(), permanent: true);

    // Repository'ler
    Get.put(AuthRepository(), permanent: true);

    // Controller'lar
    Get.put(AuthController(), permanent: true);
  }
}
