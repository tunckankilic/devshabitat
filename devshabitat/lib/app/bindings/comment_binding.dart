import 'package:get/get.dart';
import '../controllers/comments_controller.dart';
import '../services/comment_service.dart';

class CommentBinding extends Bindings {
  @override
  void dependencies() {
    // Service
    Get.lazyPut<CommentService>(() => CommentService(), fenix: true);

    // Controller
    Get.lazyPut<CommentsController>(() => CommentsController(), fenix: true);
  }
}
