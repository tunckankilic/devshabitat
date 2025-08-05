import 'package:get/get.dart';
import '../controllers/code_snippet_controller.dart';
import '../services/code_snippet_service.dart';
import '../services/code_discussion_service.dart';

class CodeSnippetBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<CodeSnippetService>(() => CodeSnippetService(), fenix: true);
    Get.lazyPut<CodeDiscussionService>(
      () => CodeDiscussionService(),
      fenix: true,
    );

    // Controller
    Get.lazyPut<CodeSnippetController>(
      () => CodeSnippetController(),
      fenix: true,
    );
  }
}
