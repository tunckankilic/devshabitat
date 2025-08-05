import 'package:get/get.dart';
import '../controllers/blog_social_controller.dart';
import '../services/blog_social_service.dart';
import '../services/blog_notification_service.dart';

class BlogSocialBinding extends Bindings {
  @override
  void dependencies() {
    // Servisleri kaydet
    Get.lazyPut<BlogSocialService>(() => BlogSocialService(), fenix: true);

    Get.lazyPut<BlogNotificationService>(
      () => BlogNotificationService(),
      fenix: true,
    );

    // Controller'ı kaydet
    Get.lazyPut<BlogSocialController>(() => BlogSocialController());
  }
}
