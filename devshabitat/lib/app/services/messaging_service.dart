import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/message_model.dart';
import '../models/conversation_model.dart';
import 'auth_service.dart';

/// Mesajlaşma servisi sınıfı
/// Firebase Firestore ile entegre çalışan, gerçek zamanlı mesajlaşma işlemlerini yöneten servis
class MessagingService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  MessagingService() {
    FirebaseFirestore.instance.settings =
        const Settings(persistenceEnabled: true);
  }

  /// Yeni bir konuşma oluşturur
  Future<ConversationModel> createConversation(
      ConversationModel conversation) async {
    try {
      final docRef = await _firestore
          .collection('conversations')
          .add(conversation.toJson());
      return conversation.copyWith(id: docRef.id);
    } catch (e) {
      throw 'Konuşma oluşturulurken hata: $e';
    }
  }

  /// Mesaj gönderir
  Future<void> sendMessage(MessageModel message) async {
    try {
      final batch = _firestore.batch();

      // Mesajı kaydet
      final messageRef = _firestore
          .collection('conversations')
          .doc(message.conversationId)
          .collection('messages')
          .doc();

      batch.set(messageRef, message.toJson());

      // Konuşmayı güncelle
      final conversationRef =
          _firestore.collection('conversations').doc(message.conversationId);

      batch.update(conversationRef, {
        'lastMessage': message.content,
        'lastMessageTime': message.timestamp.toIso8601String(),
        'lastMessageSenderId': message.senderId,
      });

      await batch.commit();
    } catch (e) {
      throw 'Mesaj gönderilirken hata: $e';
    }
  }

  /// Konuşmaları gerçek zamanlı dinler
  Stream<List<ConversationModel>> getConversations() {
    final userId = _authService.currentUser.value?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ConversationModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    });
  }

  /// Belirli bir konuşmanın mesajlarını gerçek zamanlı dinler
  Stream<List<MessageModel>> getMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    });
  }

  /// Mesaj durumunu günceller
  Future<void> updateMessageStatus({
    required String conversationId,
    required String messageId,
    required MessageStatus status,
  }) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .update({'status': status.toString().split('.').last});
    } catch (e) {
      throw 'Mesaj durumu güncellenirken hata: $e';
    }
  }

  /// Okunmamış mesaj sayısını sıfırlar
  Future<void> resetUnreadCount(String conversationId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({'unreadCount': 0});
    } catch (e) {
      throw 'Okunmamış mesaj sayısı sıfırlanırken hata: $e';
    }
  }

  Future<void> markMessagesAsRead(String conversationId) async {
    final userId = _authService.currentUser.value?.uid;
    if (userId == null) return;

    final messages = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .where('status', isEqualTo: 'delivered')
        .where('senderId', isNotEqualTo: userId)
        .get();

    final batch = _firestore.batch();

    for (var doc in messages.docs) {
      batch.update(doc.reference, {'status': 'read'});
    }

    await batch.commit();
  }
}
