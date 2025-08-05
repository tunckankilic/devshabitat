import 'package:devshabitat/app/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'package:add_2_calendar/add_2_calendar.dart' as calendar;
import 'package:devshabitat/app/models/event/event_model.dart';
import 'package:devshabitat/app/models/event/event_registration_model.dart'
    as registration_model;
import 'package:devshabitat/app/services/event/event_registration_service.dart';
import 'package:devshabitat/app/services/event/event_participation_service.dart';
import 'package:devshabitat/app/services/event/event_reminder_service.dart';
import 'package:devshabitat/app/services/event/event_detail_service.dart';

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
  final EventRegistrationService _registrationService =
      EventRegistrationService();
  final EventParticipationService _participationService =
      EventParticipationService();
  final EventReminderService _reminderService = EventReminderService();

  final Rx<EventModel?> event = Rx<EventModel?>(null);
  final RxList<registration_model.EventRegistrationModel> registrations =
      <registration_model.EventRegistrationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRegistered = false.obs;
  final RxString registrationStatus = ''.obs;
  final RxMap<String, dynamic> participationStats = <String, dynamic>{}.obs;
  final Rx<RSVPStatus> rsvpStatus = RSVPStatus.notResponded.obs;
  final RxMap<RSVPStatus, int> rsvpCounts = <RSVPStatus, int>{}.obs;

  // Yorum özellikleri
  final RxList<EventComment> comments = <EventComment>[].obs;
  final RxBool isLoadingComments = false.obs;
  final RxBool isCommenting = false.obs;
  final TextEditingController commentController = TextEditingController();
  final RxBool isReminderSet = false.obs;

  EventDetailController({required this.eventService});

  @override
  void onInit() {
    super.onInit();
    ever(event, (_) {
      if (event.value != null) {
        loadComments();
      }
    });
  }

  // Etkinlik detaylarını yükle
  Future<void> loadEventDetails(String eventId) async {
    isLoading.value = true;
    try {
      event.value = await eventService.getEventById(eventId);
      await loadRegistrations(eventId);
      await checkRegistrationStatus(eventId);
      await loadParticipationStats(eventId);
    } catch (e) {
      Get.snackbar('Hata', 'Etkinlik detayları yüklenirken bir hata oluştu');
    } finally {
      isLoading.value = false;
    }
  }

  // Kayıtları yükle
  Future<void> loadRegistrations(String eventId) async {
    try {
      registrations.value = await _registrationService.getRegistrationsByEvent(
        eventId,
      );
    } catch (e) {
      Get.snackbar('Hata', 'Kayıtlar yüklenirken bir hata oluştu');
    }
  }

  // Kayıt durumunu kontrol et
  Future<void> checkRegistrationStatus(String eventId) async {
    final userId = Get.find<AuthController>().currentUser?.uid;
    if (userId == null) return;

    final registration = await _registrationService
        .getRegistrationByEventAndUser(eventId, userId);
    isRegistered.value = registration != null;
    registrationStatus.value = registration?.status.toString() ?? '';
  }

  // Katılım istatistiklerini yükle
  Future<void> loadParticipationStats(String eventId) async {
    try {
      participationStats.value = await _participationService
          .getParticipationStats(eventId);
    } catch (e) {
      Get.snackbar('Hata', 'İstatistikler yüklenirken bir hata oluştu');
    }
  }

  // Etkinliğe kayıt ol
  Future<void> registerForEvent() async {
    final userId = Get.find<AuthController>().currentUser?.uid;
    if (userId == null || event.value == null) return;

    isLoading.value = true;
    try {
      await _registrationService.registerForEvent(event.value!.id, userId);
      await checkRegistrationStatus(event.value!.id);
      await loadParticipationStats(event.value!.id);

      // Varsayılan hatırlatıcıları oluştur
      await _reminderService.createDefaultReminders(event.value!.id, userId);

      Get.snackbar('Başarılı', 'Etkinliğe kaydınız alındı');
    } catch (e) {
      Get.snackbar('Hata', 'Kayıt işlemi sırasında bir hata oluştu');
    } finally {
      isLoading.value = false;
    }
  }

  // Katılımcı listesini dışa aktar
  Future<void> exportParticipants() async {
    if (event.value == null) return;

    isLoading.value = true;
    try {
      final csvData = await _participationService.exportParticipantsToCSV(
        event.value!.id,
      );

      // CSV dosyasını paylaş
      await Share.shareXFiles([
        XFile.fromData(
          Uint8List.fromList(csvData.codeUnits),
          name: 'participants.csv',
          mimeType: 'text/csv',
        ),
      ], subject: '${event.value!.title} - Katılımcı Listesi');

      Get.snackbar('Başarılı', 'Katılımcı listesi dışa aktarıldı');
    } catch (e) {
      Get.snackbar('Hata', 'Dışa aktarma işlemi sırasında bir hata oluştu');
    } finally {
      isLoading.value = false;
    }
  }

  // Takvime ekle
  Future<void> addToCalendar() async {
    if (event.value == null) return;

    try {
      final calendarEvent = calendar.Event(
        title: event.value!.title,
        description: event.value!.description,
        location: event.value!.location != null
            ? '${event.value!.location!.latitude}, ${event.value!.location!.longitude}'
            : '',
        startDate: event.value!.startDate,
        endDate: event.value!.endDate,
        allDay: false,
        iosParams: calendar.IOSParams(reminder: Duration(minutes: 30)),
        androidParams: calendar.AndroidParams(
          emailInvites: [], // Opsiyonel: Davet edilecek e-postalar
        ),
      );

      final success = await calendar.Add2Calendar.addEvent2Cal(calendarEvent);
      if (success) {
        Get.snackbar('Başarılı', 'Etkinlik takviminize eklendi');
      } else {
        Get.snackbar('Hata', 'Etkinlik takvime eklenemedi');
      }
    } catch (e) {
      Get.snackbar('Hata', 'Takvime ekleme işlemi sırasında bir hata oluştu');
    }
  }

  // Özel hatırlatıcı oluştur
  Future<void> createCustomReminder(DateTime reminderTime, String? note) async {
    final userId = Get.find<AuthController>().currentUser?.uid;
    if (userId == null || event.value == null) return;

    try {
      await _reminderService.createReminder(
        eventId: event.value!.id,
        userId: userId,
        reminderTime: reminderTime,
        note: note,
        isCustom: true,
      );
      Get.snackbar('Başarılı', 'Hatırlatıcı oluşturuldu');
    } catch (e) {
      Get.snackbar('Hata', 'Hatırlatıcı oluşturulurken bir hata oluştu');
    }
  }

  // Toplu katılımcı durumu güncelleme
  Future<void> bulkUpdateParticipantStatus(
    List<String> registrationIds,
    registration_model.RegistrationStatus newStatus,
  ) async {
    if (event.value == null) return;

    isLoading.value = true;
    try {
      await _participationService.bulkUpdateStatus(
        event.value!.id,
        registrationIds,
        newStatus,
      );
      await loadRegistrations(event.value!.id);
      await loadParticipationStats(event.value!.id);
      Get.snackbar('Başarılı', 'Katılımcı durumları güncellendi');
    } catch (e) {
      Get.snackbar('Hata', 'Güncelleme işlemi sırasında bir hata oluştu');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reportEvent() async {
    try {
      final eventId = event.value?.id;
      if (eventId == null) return;

      await Get.dialog(
        AlertDialog(
          title: const Text('Etkinliği Raporla'),
          content: const Text(
            'Bu etkinliği uygunsuz içerik olarak bildirmek istediğinize emin misiniz?',
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () async {
                Get.back();
                await eventService.reportEvent(eventId);
                Get.snackbar('Başarılı', 'Etkinlik rapor edildi');
              },
              child: const Text('Raporla'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar('Hata', 'Etkinlik raporlanırken bir hata oluştu');
    }
  }

  // RSVP durumunu güncelle
  void updateRSVPStatus(RSVPStatus status) {
    rsvpStatus.value = status;
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

  // Etkinliği paylaş
  Future<void> shareEvent() async {
    if (event.value == null) return;

    try {
      final eventUrl = 'https://devshabitat.app/events/${event.value!.id}';
      await Share.share(
        '${event.value!.title}\n\n${event.value!.description}\n\nEtkinlik detayları için: $eventUrl',
      );
    } catch (e) {
      Get.snackbar('Hata', 'Etkinlik paylaşılırken bir hata oluştu');
    }
  }

  // Etkinliğe katıl
  Future<void> joinEvent() async {
    if (event.value == null) return;
    await registerForEvent();
  }

  // Etkinlikten ayrıl
  Future<void> leaveEvent() async {
    if (event.value == null) return;

    try {
      final userId = Get.find<AuthController>().currentUser?.uid;
      if (userId == null) return;

      final registration = await _registrationService
          .getRegistrationByEventAndUser(event.value!.id, userId);
      if (registration == null) return;

      await _registrationService.cancelRegistration(registration.id);
      await checkRegistrationStatus(event.value!.id);
      await loadParticipationStats(event.value!.id);
      Get.snackbar('Başarılı', 'Etkinlikten ayrıldınız');
    } catch (e) {
      Get.snackbar('Hata', 'Etkinlikten ayrılırken bir hata oluştu');
    }
  }

  // Hatırlatıcıyı aç/kapat
  Future<void> toggleReminder() async {
    isReminderSet.value = !isReminderSet.value;
    if (event.value == null) return;

    try {
      final userId = Get.find<AuthController>().currentUser?.uid;
      if (userId == null) return;

      if (isReminderSet.value) {
        await _reminderService.createDefaultReminders(event.value!.id, userId);
        Get.snackbar('Başarılı', 'Hatırlatıcı ayarlandı');
      } else {
        await _reminderService.removeAllReminders(event.value!.id, userId);
        Get.snackbar('Başarılı', 'Hatırlatıcı kaldırıldı');
      }
    } catch (e) {
      Get.snackbar('Hata', 'Hatırlatıcı ayarlanırken bir hata oluştu');
    }
  }

  // Geri bildirim gönder
  Future<void> submitEventFeedback(int rating, String comment) async {
    if (event.value == null) return;

    try {
      final userId = Get.find<AuthController>().currentUser?.uid;
      if (userId == null) return;

      await eventService.submitFeedback(
        eventId: event.value!.id,
        userId: userId,
        rating: rating,
        comment: comment,
      );
      Get.snackbar('Başarılı', 'Geri bildiriminiz için teşekkürler');
    } catch (e) {
      Get.snackbar('Hata', 'Geri bildirim gönderilirken bir hata oluştu');
    }
  }

  // Yorum ekle
  Future<void> addComment() async {
    if (event.value == null || commentController.text.trim().isEmpty) return;

    isCommenting.value = true;
    try {
      final userId = Get.find<AuthController>().currentUser?.uid;
      final userName = Get.find<AuthController>().currentUser?.displayName;
      if (userId == null || userName == null) return;

      final comment = EventComment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        userName: userName,
        comment: commentController.text.trim(),
        createdAt: DateTime.now(),
        likes: [],
      );

      await eventService.addComment(event.value!.id, comment);
      commentController.clear();
      await loadComments();
      Get.snackbar('Başarılı', 'Yorumunuz eklendi');
    } catch (e) {
      Get.snackbar('Hata', 'Yorum eklenirken bir hata oluştu');
    } finally {
      isCommenting.value = false;
    }
  }

  // Yorumu sil
  Future<void> deleteComment(String commentId) async {
    if (event.value == null) return;

    try {
      await eventService.deleteComment(event.value!.id, commentId);
      await loadComments();
      Get.snackbar('Başarılı', 'Yorum silindi');
    } catch (e) {
      Get.snackbar('Hata', 'Yorum silinirken bir hata oluştu');
    }
  }

  // Yorumu beğen
  Future<void> likeComment(String commentId) async {
    if (event.value == null) return;

    try {
      final userId = Get.find<AuthController>().currentUser?.uid;
      if (userId == null) return;

      await eventService.toggleCommentLike(event.value!.id, commentId, userId);
      await loadComments();
    } catch (e) {
      Get.snackbar('Hata', 'Yorum beğenilirken bir hata oluştu');
    }
  }

  // Yorumları yükle
  Future<void> loadComments() async {
    if (event.value == null) return;

    isLoadingComments.value = true;
    try {
      final loadedComments = await eventService.getComments(event.value!.id);
      comments.value = loadedComments;
    } catch (e) {
      Get.snackbar('Hata', 'Yorumlar yüklenirken bir hata oluştu');
    } finally {
      isLoadingComments.value = false;
    }
  }

  // RSVP durum metni
  String getRSVPStatusText(RSVPStatus status) {
    switch (status) {
      case RSVPStatus.going:
        return 'Katılıyor';
      case RSVPStatus.maybe:
        return 'Belki';
      case RSVPStatus.notGoing:
        return 'Katılmıyor';
      case RSVPStatus.notResponded:
        return 'Yanıt Yok';
    }
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
}
