import 'package:get/get.dart';
import '../models/thread_model.dart';
import '../services/thread_service.dart';
import '../services/messaging_service.dart';

class ThreadController extends GetxController {
  final ThreadService _threadService = Get.find<ThreadService>();
  final MessagingService _messagingService = Get.find<MessagingService>();

  final RxMap<String, ThreadModel> activeThreads = <String, ThreadModel>{}.obs;
  final RxString currentThreadId = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeThreadListener();
  }

  void _initializeThreadListener() {
    _threadService.threadsStream.listen((threads) {
      activeThreads.assignAll(threads);
    });
  }

  Future<void> createThread(String parentMessageId, String content) async {
    try {
      isLoading.value = true;
      await _threadService.createThread(parentMessageId, content);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> replyToThread(String threadId, String content) async {
    try {
      isLoading.value = true;
      await _threadService.addReplyToThread(threadId, content);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadThread(String threadId) async {
    try {
      isLoading.value = true;
      currentThreadId.value = threadId;
      final thread = await _threadService.getThread(threadId);
      if (thread != null) {
        activeThreads[threadId] = thread;
      }
    } finally {
      isLoading.value = false;
    }
  }

  void markThreadAsRead(String threadId) {
    _threadService.markThreadAsRead(threadId);
  }

  Future<void> deleteThread(String threadId) async {
    try {
      await _threadService.deleteThread(threadId);
      activeThreads.remove(threadId);
    } catch (e) {
      Get.snackbar('Hata', 'Thread silinirken bir hata oluştu');
    }
  }

  List<ThreadModel> getUnreadThreads() {
    return activeThreads.values.where((thread) => !thread.isRead).toList();
  }
}
