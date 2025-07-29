import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/event/event_model.dart';
import '../../services/event/event_detail_service.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';

enum RSVPStatus { going, maybe, notGoing, notResponded }

class EventComment {
  final String id;
  final String userId;
  final String userName;
  final String comment;
  final DateTime createdAt;
  final List<String> likes;

  EventComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.comment,
    required this.createdAt,
    required this.likes,
  });

  factory EventComment.fromMap(Map<String, dynamic> map) {
    return EventComment(
      id: map['id'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      comment: map['comment'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      likes: List<String>.from(map['likes'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
    };
  }
}

class EventDetailController extends GetxController {
  final EventDetailService eventService;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  // Observable variables
  final event = Rxn<EventModel>();
  final isLoading = false.obs;
  final comments = <EventComment>[].obs;
  final rsvpStatus = RSVPStatus.notResponded.obs;
  final isReminderSet = false.obs;
  final isLiked = false.obs;
  final isCommenting = false.obs;
  final commentController = TextEditingController();
  final isLoadingComments = false.obs;
  final rsvpCounts = <RSVPStatus, int>{}.obs;

  EventDetailController({required this.eventService});

  @override
  void onInit() {
    super.onInit();
    _initializeRSVPCounts();
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }

  void _initializeRSVPCounts() {
    rsvpCounts.value = {
      RSVPStatus.going: 0,
      RSVPStatus.maybe: 0,
      RSVPStatus.notGoing: 0,
      RSVPStatus.notResponded: 0,
    };
  }

  Future<void> loadEventDetails(String eventId) async {
    try {
      isLoading.value = true;
      event.value = await eventService.getEventDetails(eventId);

      if (event.value != null) {
        // Increment view count
        await eventService.incrementEventViews(eventId);

        await Future.wait([
          loadComments(eventId),
          loadRSVPStatus(eventId),
          loadReminderStatus(eventId),
          loadRSVPCounts(eventId),
        ]);
      }
    } catch (e) {
      _logger.e('Etkinlik detayları yüklenirken hata: $e');
      Get.snackbar('Hata', 'Etkinlik detayları yüklenirken bir hata oluştu');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadComments(String eventId) async {
    try {
      isLoadingComments.value = true;
      final snapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .get();

      comments.value = snapshot.docs
          .map((doc) => EventComment.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      _logger.e('Yorumlar yüklenirken hata: $e');
    } finally {
      isLoadingComments.value = false;
    }
  }

  Future<void> loadRSVPStatus(String eventId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final doc = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('rsvp')
          .doc(userId)
          .get();

      if (doc.exists) {
        final status = doc.data()?['status'] as String?;
        if (status != null) {
          if (status == 'RSVPStatus.going') {
            rsvpStatus.value = RSVPStatus.going;
          } else if (status == 'RSVPStatus.maybe') {
            rsvpStatus.value = RSVPStatus.maybe;
          } else if (status == 'RSVPStatus.notGoing') {
            rsvpStatus.value = RSVPStatus.notGoing;
          } else {
            rsvpStatus.value = RSVPStatus.notResponded;
          }
        }
      }
    } catch (e) {
      _logger.e('RSVP durumu yüklenirken hata: $e');
    }
  }

  Future<void> loadReminderStatus(String eventId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final doc = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('reminders')
          .doc(userId)
          .get();

      isReminderSet.value = doc.exists;
    } catch (e) {
      _logger.e('Hatırlatıcı durumu yüklenirken hata: $e');
    }
  }

  Future<void> loadRSVPCounts(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('rsvp')
          .get();

      final counts = <RSVPStatus, int>{
        RSVPStatus.going: 0,
        RSVPStatus.maybe: 0,
        RSVPStatus.notGoing: 0,
        RSVPStatus.notResponded: 0,
      };

      for (final doc in snapshot.docs) {
        final status = doc.data()['status'] as String?;
        if (status != null) {
          RSVPStatus rsvpStatus;
          if (status == 'RSVPStatus.going') {
            rsvpStatus = RSVPStatus.going;
          } else if (status == 'RSVPStatus.maybe') {
            rsvpStatus = RSVPStatus.maybe;
          } else if (status == 'RSVPStatus.notGoing') {
            rsvpStatus = RSVPStatus.notGoing;
          } else {
            rsvpStatus = RSVPStatus.notResponded;
          }
          counts[rsvpStatus] = (counts[rsvpStatus] ?? 0) + 1;
        }
      }

      rsvpCounts.value = counts;
    } catch (e) {
      _logger.e('RSVP sayıları yüklenirken hata: $e');
    }
  }

  Future<void> updateRSVPStatus(RSVPStatus status) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        Get.snackbar('Hata', 'Giriş yapmanız gerekiyor');
        return;
      }

      final eventId = event.value?.id;
      if (eventId == null) return;

      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('rsvp')
          .doc(userId)
          .set({
        'status': 'RSVPStatus.${status.name}',
        'userId': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      rsvpStatus.value = status;
      await loadRSVPCounts(eventId);

      String message = '';
      switch (status) {
        case RSVPStatus.going:
          message = 'Etkinliğe katılacağınızı belirttiniz';
          break;
        case RSVPStatus.maybe:
          message = 'Belki katılacağınızı belirttiniz';
          break;
        case RSVPStatus.notGoing:
          message = 'Katılmayacağınızı belirttiniz';
          break;
        case RSVPStatus.notResponded:
          break;
      }

      if (message.isNotEmpty) {
        Get.snackbar('Başarılı', message);
      }
    } catch (e) {
      _logger.e('RSVP güncellenirken hata: $e');
      Get.snackbar('Hata', 'RSVP durumu güncellenirken bir hata oluştu');
    }
  }

  Future<void> toggleReminder() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        Get.snackbar('Hata', 'Giriş yapmanız gerekiyor');
        return;
      }

      final eventId = event.value?.id;
      if (eventId == null) return;

      if (isReminderSet.value) {
        // Remove reminder
        await _firestore
            .collection('events')
            .doc(eventId)
            .collection('reminders')
            .doc(userId)
            .delete();
        isReminderSet.value = false;
        Get.snackbar('Başarılı', 'Hatırlatıcı kaldırıldı');
      } else {
        // Add reminder
        await _firestore
            .collection('events')
            .doc(eventId)
            .collection('reminders')
            .doc(userId)
            .set({
          'userId': userId,
          'eventId': eventId,
          'createdAt': FieldValue.serverTimestamp(),
          'reminderTime': FieldValue.serverTimestamp(),
        });
        isReminderSet.value = true;
        Get.snackbar('Başarılı', 'Hatırlatıcı eklendi');
      }
    } catch (e) {
      _logger.e('Hatırlatıcı güncellenirken hata: $e');
      Get.snackbar('Hata', 'Hatırlatıcı güncellenirken bir hata oluştu');
    }
  }

  Future<void> addComment() async {
    try {
      if (commentController.text.trim().isEmpty) return;

      isCommenting.value = true;
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        Get.snackbar('Hata', 'Giriş yapmanız gerekiyor');
        return;
      }

      final eventId = event.value?.id;
      if (eventId == null) return;

      // Get user name
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userName = userDoc.data()?['displayName'] ?? 'Anonim';

      final comment = EventComment(
        id: '',
        userId: userId,
        userName: userName,
        comment: commentController.text.trim(),
        createdAt: DateTime.now(),
        likes: [],
      );

      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('comments')
          .add(comment.toMap());

      commentController.clear();
      await loadComments(eventId);
      Get.snackbar('Başarılı', 'Yorum eklendi');
    } catch (e) {
      _logger.e('Yorum eklenirken hata: $e');
      Get.snackbar('Hata', 'Yorum eklenirken bir hata oluştu');
    } finally {
      isCommenting.value = false;
    }
  }

  Future<void> likeComment(String commentId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        Get.snackbar('Hata', 'Giriş yapmanız gerekiyor');
        return;
      }

      final eventId = event.value?.id;
      if (eventId == null) return;

      final commentRef = _firestore
          .collection('events')
          .doc(eventId)
          .collection('comments')
          .doc(commentId);

      final commentDoc = await commentRef.get();
      if (!commentDoc.exists) return;

      final likes = List<String>.from(commentDoc.data()?['likes'] ?? []);

      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }

      await commentRef.update({'likes': likes});
      await loadComments(eventId);
    } catch (e) {
      _logger.e('Yorum beğenilirken hata: $e');
      Get.snackbar('Hata', 'İşlem sırasında bir hata oluştu');
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final eventId = event.value?.id;
      if (eventId == null) return;

      // Check if user is the comment owner
      final comment = comments.firstWhere((c) => c.id == commentId);
      if (comment.userId != userId) {
        Get.snackbar('Hata', 'Bu yorumu silemezsiniz');
        return;
      }

      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('comments')
          .doc(commentId)
          .delete();

      await loadComments(eventId);
      Get.snackbar('Başarılı', 'Yorum silindi');
    } catch (e) {
      _logger.e('Yorum silinirken hata: $e');
      Get.snackbar('Hata', 'Yorum silinirken bir hata oluştu');
    }
  }

  Future<void> shareEvent() async {
    try {
      final eventData = event.value;
      if (eventData == null) return;

      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await eventService.addEventShare(eventData.id, userId);
      }

      final shareText = '''
${eventData.title}

${eventData.description}

Tarih: ${_formatDate(eventData.startDate)}
${eventData.type == EventType.online ? 'Online' : 'Yer: ${eventData.venueAddress}'}

Katılımcılar: ${eventData.participants.length}/${eventData.participantLimit}

DevShabitat uygulamasından paylaşıldı.
      ''';

      await Share.share(shareText, subject: eventData.title);
    } catch (e) {
      _logger.e('Etkinlik paylaşılırken hata: $e');
      Get.snackbar('Hata', 'Paylaşım sırasında bir hata oluştu');
    }
  }

  Future<void> reportEvent() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        Get.snackbar('Hata', 'Giriş yapmanız gerekiyor');
        return;
      }

      final eventId = event.value?.id;
      if (eventId == null) return;

      await _firestore.collection('reports').add({
        'type': 'event',
        'eventId': eventId,
        'reportedBy': userId,
        'reason': 'Inappropriate content',
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      Get.snackbar('Başarılı', 'Rapor gönderildi. İnceleme sürecinde.');
    } catch (e) {
      _logger.e('Etkinlik raporlanırken hata: $e');
      Get.snackbar('Hata', 'Rapor gönderilirken bir hata oluştu');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String getRSVPStatusText(RSVPStatus status) {
    switch (status) {
      case RSVPStatus.going:
        return 'Katılıyorum';
      case RSVPStatus.maybe:
        return 'Belki';
      case RSVPStatus.notGoing:
        return 'Katılmıyorum';
      case RSVPStatus.notResponded:
        return 'Yanıtlanmadı';
    }
  }

  Color getRSVPStatusColor(RSVPStatus status) {
    switch (status) {
      case RSVPStatus.going:
        return Colors.green;
      case RSVPStatus.maybe:
        return Colors.orange;
      case RSVPStatus.notGoing:
        return Colors.red;
      case RSVPStatus.notResponded:
        return Colors.grey;
    }
  }

  bool canJoinEvent() {
    final eventData = event.value;
    if (eventData == null) return false;

    return !eventData.isFull &&
        !eventData.hasEnded &&
        !eventData.isParticipant(_auth.currentUser?.uid ?? '');
  }

  bool canLeaveEvent() {
    final eventData = event.value;
    if (eventData == null) return false;

    return eventData.isParticipant(_auth.currentUser?.uid ?? '');
  }

  bool isEventOwner() {
    return event.value?.createdBy == _auth.currentUser?.uid;
  }

  Future<void> submitEventFeedback(int rating, String feedback) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        Get.snackbar('Hata', 'Giriş yapmanız gerekiyor');
        return;
      }

      final eventId = event.value?.id;
      if (eventId == null) return;

      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('feedback')
          .add({
        'userId': userId,
        'rating': rating,
        'feedback': feedback,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar('Başarılı', 'Geri bildiriminiz için teşekkürler!');
    } catch (e) {
      _logger.e('Geri bildirim gönderilirken hata: $e');
      Get.snackbar('Hata', 'Geri bildirim gönderilirken bir hata oluştu');
    }
  }

  Future<void> joinEvent() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        Get.snackbar('Hata', 'Giriş yapmanız gerekiyor');
        return;
      }

      final eventData = event.value;
      if (eventData == null) return;

      if (eventData.isFull) {
        Get.snackbar('Hata', 'Etkinlik dolu');
        return;
      }

      if (eventData.hasEnded) {
        Get.snackbar('Hata', 'Etkinlik sona ermiş');
        return;
      }

      if (eventData.isParticipant(userId)) {
        Get.snackbar('Bilgi', 'Zaten bu etkinliğe katılıyorsunuz');
        return;
      }

      // Add user to participants
      await _firestore.collection('events').doc(eventData.id).update({
        'participants': FieldValue.arrayUnion([userId]),
      });

      // Update local event data
      final updatedParticipants = List<String>.from(eventData.participants)
        ..add(userId);
      event.value = EventModel(
        id: eventData.id,
        title: eventData.title,
        description: eventData.description,
        type: eventData.type,
        onlineMeetingUrl: eventData.onlineMeetingUrl,
        venueAddress: eventData.venueAddress,
        startDate: eventData.startDate,
        endDate: eventData.endDate,
        participantLimit: eventData.participantLimit,
        categories: eventData.categories,
        participants: updatedParticipants,
        communityId: eventData.communityId,
        createdBy: eventData.createdBy,
        createdAt: eventData.createdAt,
        updatedAt: eventData.updatedAt,
        location: eventData.location,
      );

      // Update RSVP status to going
      rsvpStatus.value = RSVPStatus.going;

      Get.snackbar('Başarılı', 'Etkinliğe başarıyla katıldınız!');
    } catch (e) {
      _logger.e('Etkinliğe katılırken hata: $e');
      Get.snackbar('Hata', 'Etkinliğe katılırken bir hata oluştu');
    }
  }

  Future<void> leaveEvent() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        Get.snackbar('Hata', 'Giriş yapmanız gerekiyor');
        return;
      }

      final eventData = event.value;
      if (eventData == null) return;

      if (!eventData.isParticipant(userId)) {
        Get.snackbar('Bilgi', 'Bu etkinliğe katılmıyorsunuz');
        return;
      }

      // Remove user from participants
      await _firestore.collection('events').doc(eventData.id).update({
        'participants': FieldValue.arrayRemove([userId]),
      });

      // Update local event data
      final updatedParticipants = List<String>.from(eventData.participants)
        ..remove(userId);
      event.value = EventModel(
        id: eventData.id,
        title: eventData.title,
        description: eventData.description,
        type: eventData.type,
        onlineMeetingUrl: eventData.onlineMeetingUrl,
        venueAddress: eventData.venueAddress,
        startDate: eventData.startDate,
        endDate: eventData.endDate,
        participantLimit: eventData.participantLimit,
        categories: eventData.categories,
        participants: updatedParticipants,
        communityId: eventData.communityId,
        createdBy: eventData.createdBy,
        createdAt: eventData.createdAt,
        updatedAt: eventData.updatedAt,
        location: eventData.location,
      );

      // Update RSVP status to not going
      rsvpStatus.value = RSVPStatus.notGoing;

      Get.snackbar('Başarılı', 'Etkinlikten ayrıldınız');
    } catch (e) {
      _logger.e('Etkinlikten ayrılırken hata: $e');
      Get.snackbar('Hata', 'Etkinlikten ayrılırken bir hata oluştu');
    }
  }
}
