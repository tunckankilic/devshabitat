import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/message_model.dart';
import '../models/conversation_model.dart';
import '../core/services/error_handler_service.dart';

/// Mesajlaşma servisi sınıfı
/// Firebase Firestore ile entegre çalışan, gerçek zamanlı mesajlaşma işlemlerini yöneten servis
class MessagingService extends GetxService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ErrorHandlerService _errorHandler;

  MessagingService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    ErrorHandlerService? errorHandler,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _errorHandler = errorHandler ?? Get.find();

  String get currentUserId => _auth.currentUser?.uid ?? '';

  /// Yeni bir konuşma oluşturur
  Future<ConversationModel> createConversation(
      ConversationModel conversation) async {
    try {
      final docRef = await _firestore
          .collection('conversations')
          .add(conversation.toMap());
      return conversation.copyWith(id: docRef.id);
    } catch (e) {
      throw 'Konuşma oluşturulurken hata: $e';
    }
  }

  /// Mesaj gönderir
  Future<void> sendMessage(MessageModel message) async {
    try {
      final messageRef = _firestore.collection('messages').doc();
      final conversationRef =
          _firestore.collection('conversations').doc(message.conversationId);

      await _firestore.runTransaction((transaction) async {
        // Mesajı ekle
        transaction.set(messageRef, {
          ...message.toMap(),
          'id': messageRef.id,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Konuşmayı güncelle
        transaction.update(conversationRef, {
          'lastMessage': message.content,
          'lastMessageSenderId': message.senderId,
          'lastMessageTime': FieldValue.serverTimestamp(),
          'isRead': false,
          'unreadCount': FieldValue.increment(1),
        });
      });
    } catch (e) {
      _errorHandler.handleError('Mesaj gönderilirken hata: $e');
      rethrow;
    }
  }

  /// Konuşmaları gerçek zamanlı dinler
  Stream<List<ConversationModel>> getConversations() {
    try {
      return _firestore
          .collection('conversations')
          .where('participants', arrayContains: currentUserId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => ConversationModel.fromMap({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList();
      });
    } catch (e) {
      _errorHandler.handleError('Konuşmalar alınırken hata: $e');
      return Stream.value([]);
    }
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
          .map((doc) => MessageModel.fromMap({
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
    try {
      final batch = _firestore.batch();
      final messagesRef = _firestore.collection('messages');
      final conversationRef =
          _firestore.collection('conversations').doc(conversationId);

      // Okunmamış mesajları bul
      final unreadMessages = await messagesRef
          .where('conversationId', isEqualTo: conversationId)
          .where('isRead', isEqualTo: false)
          .where('senderId', isNotEqualTo: currentUserId)
          .get();

      // Mesajları okundu olarak işaretle
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      // Konuşmayı güncelle
      batch.update(conversationRef, {
        'isRead': true,
        'unreadCount': 0,
      });

      await batch.commit();
    } catch (e) {
      _errorHandler.handleError('Mesajlar okundu işaretlenirken hata: $e');
      rethrow;
    }
  }

  Future<void> markConversationAsRead(String conversationId) async {
    try {
      await _firestore.collection('conversations').doc(conversationId).update({
        'isRead': true,
        'unreadCount': 0,
      });
    } catch (e) {
      _errorHandler.handleError('Konuşma okundu işaretlenirken hata: $e');
      rethrow;
    }
  }

  Future<void> deleteMessage(String conversationId, String messageId) async {
    try {
      final messageRef = _firestore.collection('messages').doc(messageId);
      final conversationRef =
          _firestore.collection('conversations').doc(conversationId);

      await _firestore.runTransaction((transaction) async {
        // Mesajı sil
        transaction.delete(messageRef);

        // Son mesajı kontrol et ve konuşmayı güncelle
        final messages = await _firestore
            .collection('messages')
            .where('conversationId', isEqualTo: conversationId)
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (messages.docs.isNotEmpty) {
          final lastMessage = messages.docs.first;
          transaction.update(conversationRef, {
            'lastMessage': lastMessage['content'],
            'lastMessageSenderId': lastMessage['senderId'],
            'lastMessageTime': lastMessage['timestamp'],
          });
        } else {
          // Konuşmada mesaj kalmadıysa
          transaction.update(conversationRef, {
            'lastMessage': null,
            'lastMessageSenderId': null,
            'lastMessageTime': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      _errorHandler.handleError('Mesaj silinirken hata: $e');
      rethrow;
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      final batch = _firestore.batch();

      // Konuşmayı sil
      final conversationRef =
          _firestore.collection('conversations').doc(conversationId);
      batch.delete(conversationRef);

      // Konuşmaya ait tüm mesajları sil
      final messages = await _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .get();

      for (var message in messages.docs) {
        batch.delete(message.reference);
      }

      await batch.commit();
    } catch (e) {
      _errorHandler.handleError('Konuşma silinirken hata: $e');
      rethrow;
    }
  }
}
