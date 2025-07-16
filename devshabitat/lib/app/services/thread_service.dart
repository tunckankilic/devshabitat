import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/thread_model.dart';
import 'user_service.dart';
import 'dart:async';

class ThreadService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxMap<String, ThreadModel> _threads = <String, ThreadModel>{}.obs;
  StreamSubscription<QuerySnapshot>? _threadsSubscription;

  Stream<Map<String, ThreadModel>> get threadsStream => _threads.stream;

  @override
  Future<void> onInit() async {
    super.onInit();
    await initialize();
  }

  Future<void> initialize() async {
    _listenToThreads();
  }

  void _listenToThreads() {
    _threadsSubscription?.cancel();
    _threadsSubscription =
        _firestore.collection('threads').snapshots().listen((snapshot) {
      final threads = <String, ThreadModel>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        threads[doc.id] = ThreadModel.fromJson(data);
      }
      _threads.assignAll(threads);
    });
  }

  Future<void> createThread(String parentMessageId, String content) async {
    try {
      final userService = Get.find<UserService>();
      final currentUser = userService.currentUser;

      if (currentUser == null) {
        throw Exception('Kullanıcı oturum açmamış');
      }

      final threadData = ThreadModel(
        id: '',
        authorId: currentUser.uid,
        authorName: currentUser.displayName ?? "Anonim Kullanıcı",
        content: content,
        createdAt: DateTime.now(),
        attachments: [],
        replies: [],
      ).toJson();

      await _firestore.collection('threads').add(threadData);
    } catch (e) {
      throw Exception('Thread oluşturulurken hata: $e');
    }
  }

  Future<void> addReplyToThread(String threadId, String content) async {
    try {
      final userService = Get.find<UserService>();
      final currentUser = userService.currentUser;

      if (currentUser == null) {
        throw Exception('Kullanıcı oturum açmamış');
      }

      final replyData = ThreadReply(
        id: '',
        authorId: currentUser.uid,
        authorName: currentUser.displayName ?? "Anonim Kullanıcı",
        content: content,
        createdAt: DateTime.now(),
        attachments: [],
      ).toJson();

      await _firestore
          .collection('threads')
          .doc(threadId)
          .collection('replies')
          .add(replyData);
    } catch (e) {
      throw Exception('Reply eklenirken hata: $e');
    }
  }

  @override
  void onClose() {
    _threadsSubscription?.cancel();
    super.onClose();
  }

  Future<ThreadModel?> getThread(String threadId) async {
    final doc = await _firestore.collection('threads').doc(threadId).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    data['id'] = doc.id;
    return ThreadModel.fromJson(data);
  }

  Future<void> markThreadAsRead(String threadId) async {
    await _firestore.collection('threads').doc(threadId).update({
      'isRead': true,
    });
  }

  Future<void> deleteThread(String threadId) async {
    await _firestore.collection('threads').doc(threadId).delete();
  }
}
