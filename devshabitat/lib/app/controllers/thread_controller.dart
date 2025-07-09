import 'package:get/get.dart';
import '../models/thread_model.dart';
import '../services/thread_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/attachment_model.dart';

class ThreadController extends GetxController {
  final ThreadService _threadService = Get.find<ThreadService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  String get currentUserId => _auth.currentUser?.uid ?? '';

  final RxMap<String, ThreadModel> activeThreads = <String, ThreadModel>{}.obs;
  final RxString currentThreadId = ''.obs;
  final RxBool isLoading = false.obs;
  final RxMap<String, bool> threadNotifications = <String, bool>{}.obs;

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

  Future<void> toggleThreadNotifications(String threadId) async {
    try {
      final currentStatus = threadNotifications[threadId] ?? true;
      final newStatus = !currentStatus;

      await _firestore
          .collection('thread_notifications')
          .doc(currentUserId)
          .set({
        threadId: newStatus,
      }, SetOptions(merge: true));

      threadNotifications[threadId] = newStatus;
    } catch (e) {
      _logger.e('Bildirim tercihi güncellenirken hata: $e');
    }
  }

  Future<void> loadNotificationPreferences() async {
    try {
      final doc = await _firestore
          .collection('thread_notifications')
          .doc(currentUserId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        threadNotifications.value = Map<String, bool>.from(data);
      }
    } catch (e) {
      _logger.e('Bildirim tercihleri yüklenirken hata: $e');
    }
  }

  Future<void> handleAttachment(MessageAttachment attachment) async {
    try {
      switch (attachment.type) {
        case AttachmentType.image:
          await Get.toNamed(
            '/image-viewer',
            arguments: {'url': attachment.url},
          );
          break;
        case AttachmentType.document:
          await _downloadAndOpenFile(attachment.url);
          break;
        case AttachmentType.video:
          await Get.toNamed(
            '/video-player',
            arguments: {'url': attachment.url},
          );
          break;
      }
    } catch (e) {
      _logger.e('Dosya işlenirken hata: $e');
      Get.snackbar(
        'Hata',
        'Dosya açılırken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _downloadAndOpenFile(String url) async {
    try {
      final result = await Get.toNamed(
        '/file-viewer',
        arguments: {'url': url},
      );

      if (result == null) {
        Get.snackbar(
          'Hata',
          'Dosya açılamadı',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      _logger.e('Dosya indirilirken hata: $e');
      rethrow;
    }
  }
}
