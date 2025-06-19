import 'package:devshabitat/app/controllers/auth_controller.dart';
import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../core/services/error_handler_service.dart';
import '../services/github_oauth_service.dart';
import '../services/post_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Servisleri başlat
    final logger = Get.put(Logger());
    final errorHandler = Get.put(ErrorHandlerService());

    final githubOAuthService = Get.put(GitHubOAuthService(
      logger: logger,
      errorHandler: errorHandler,
    ));

    Get.put(PostService(
      errorHandler: errorHandler,
    ));

    Get.put(AuthController(
      authRepository: Get.put(AuthRepository(
        githubOAuthService: githubOAuthService,
      )),
      errorHandler: errorHandler,
    ));
  }
}
