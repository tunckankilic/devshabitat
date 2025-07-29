import 'package:get/get.dart';
import '../../controllers/community/resource_controller.dart';
import '../../controllers/file_upload_controller.dart';
import '../../services/community/resource_service.dart';
import '../../services/file_storage_service.dart';

class CommunityResourcesBinding extends Bindings {
  @override
  void dependencies() {
    // Servisler
    Get.lazyPut<ResourceService>(() => ResourceService());
    Get.lazyPut<FileStorageService>(() => FileStorageService());

    // Controller'lar
    Get.lazyPut<ResourceController>(() => ResourceController());
    Get.lazyPut<FileUploadController>(() => FileUploadController());
  }
}
