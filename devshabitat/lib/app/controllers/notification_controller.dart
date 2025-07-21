import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../repositories/auth_repository.dart';

class NotificationController extends GetxController {
  final NotificationService _notificationService = Get.find();
  final AuthRepository _authRepository = Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString currentFilter = 'all'.obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _setupNotificationListener();
    refreshNotifications();
  }

  void _setupNotificationListener() {
    final userId = _authRepository.currentUser?.uid;
    if (userId != null) {
      _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .snapshots()
          .listen((snapshot) {
        _updateNotifications(snapshot.docs);
      });
    }
  }

  void _updateNotifications(List<QueryDocumentSnapshot> docs) {
    notifications.value = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return NotificationModel.fromJson({...data, 'id': doc.id});
    }).toList();

    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _updateUnreadCount();
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  Future<void> refreshNotifications() async {
    try {
      isLoading.value = true;
      final userId = _authRepository.currentUser?.uid;
      if (userId != null) {
        final snapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .get();
        _updateNotifications(snapshot.docs);
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Bildirimler yüklenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final userId = _authRepository.currentUser?.uid;
      if (userId != null) {
        final batch = _firestore.batch();
        final unreadNotifications =
            notifications.where((notification) => !notification.isRead);

        for (var notification in unreadNotifications) {
          final ref = _firestore
              .collection('users')
              .doc(userId)
              .collection('notifications')
              .doc(notification.id);
          batch.update(ref, {'isRead': true});
        }

        await batch.commit();
        await refreshNotifications();
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Bildirimler işaretlenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final userId = _authRepository.currentUser?.uid;
      if (userId != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .doc(notificationId)
            .delete();

        notifications.removeWhere((n) => n.id == notificationId);
        _updateUnreadCount();
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Bildirim silinirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void updateFilter(String filter) {
    currentFilter.value = filter;
    refreshNotifications();
  }

  Future<void> handleNotificationTap(NotificationModel notification) async {
    try {
      if (!notification.isRead) {
        final userId = _authRepository.currentUser?.uid;
        if (userId != null) {
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('notifications')
              .doc(notification.id)
              .update({'isRead': true});
        }
      }

      // Bildirim tipine göre yönlendirme yap
      if (notification.data != null) {
        _notificationService.handleNotificationNavigation(notification.data!);
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Bildirim işlenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
