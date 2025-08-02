import 'package:get/get.dart';
import '../../controllers/community/community_announcement_controller.dart';
import '../../services/community/announcement_service.dart';

class CommunityAnnouncementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AnnouncementService());
    Get.lazyPut(() => CommunityAnnouncementController());
  }
}
