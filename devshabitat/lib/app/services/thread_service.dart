import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/thread_model.dart';
import 'user_service.dart';

class ThreadService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxMap<String, ThreadModel> _threads = <String, ThreadModel>{}.obs;

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
    final currentUser = Get.find<UserService>().currentUser;
    if (currentUser == null) return;

    final threadData = ThreadModel(
      id: '',
      authorId: currentUser.id,
      authorName: currentUser.displayName,
      content: content,
      createdAt: DateTime.now(),
      attachments: [],
      replies: [],
    ).toJson();

    await _firestore.collection('threads').add(threadData);
  }

  Future<void> addReplyToThread(String threadId, String content) async {
    final currentUser = Get.find<UserService>().currentUser;
    if (currentUser == null) return;

    final replyData = ThreadReply(
      id: '',
      authorId: currentUser.id,
      authorName: currentUser.displayName,
      content: content,
      createdAt: DateTime.now(),
      attachments: [],
    ).toJson();

    await _firestore
        .collection('threads')
        .doc(threadId)
        .collection('replies')
        .add(replyData);
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
