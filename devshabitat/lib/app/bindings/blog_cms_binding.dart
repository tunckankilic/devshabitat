import 'package:get/get.dart';
import '../controllers/blog_cms_controller.dart';
import '../services/blog_management_service.dart';
import '../services/blog_editor_service.dart';

class BlogCMSBinding extends Bindings {
  @override
  void dependencies() {
    // Servisleri kaydet
    Get.lazyPut<BlogManagementService>(
      () => BlogManagementService(),
      fenix: true,
    );

    Get.lazyPut<BlogEditorService>(() => BlogEditorService(), fenix: true);

    // Controller'ı kaydet
    Get.lazyPut<BlogCMSController>(() => BlogCMSController());
  }
}
