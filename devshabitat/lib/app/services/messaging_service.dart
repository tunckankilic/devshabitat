import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/message_model.dart';
import '../models/conversation_model.dart';
import '../core/services/error_handler_service.dart';
import 'package:logger/logger.dart';

/// Mesajlaşma servisi sınıfı
/// Firebase Firestore ile entegre çalışan, gerçek zamanlı mesajlaşma işlemlerini yöneten servis
class MessagingService extends GetxService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ErrorHandlerService _errorHandler;
  final Logger _logger;

  MessagingService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    ErrorHandlerService? errorHandler,
    required Logger logger,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _errorHandler = errorHandler ?? Get.find(),
        _logger = logger;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  // Yardımcı metodlar
  String _handleError(String message) {
    _errorHandler.handleError(message, ErrorHandlerService.AUTH_ERROR);
    return message;
  }

  // Ana metodlar
  Future<ConversationModel> createNewConversation(
      ConversationModel conversation) async {
    try {
      final docRef = await _firestore
          .collection('conversations')
          .add(conversation.toMap());
      return conversation.copyWith(id: docRef.id);
    } catch (e) {
      _logger.e('Konuşma oluşturulurken hata: $e');
      throw _handleError('Konuşma oluşturulurken hata: $e');
    }
  }

  Future<ConversationModel> startConversation(String userId) async {
    try {
      final authService = Get.find<AuthRepository>();
      final currentUser = authService.currentUser?.uid;
      if (currentUser == null) throw _handleError('Kullanıcı bulunamadı');

      final doc = await _firestore.collection('conversations').add({
        'participantId': userId,
        'participantName': '',
        'lastMessage': '',
        'lastMessageSenderId': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'isRead': false,
        'unreadCount': 0,
      });

      return ConversationModel(
        id: doc.id,
        participantId: userId,
        participantName: '',
        lastMessage: '',
        lastMessageSenderId: '',
        lastMessageTime: DateTime.now(),
        isRead: false,
        unreadCount: 0,
      );
    } catch (e) {
      _logger.e('Konuşma oluşturulamadı: $e');
      throw _handleError('Konuşma oluşturulamadı: $e');
    }
  }

  Future<void> removeConversation(String conversationId) async {
    try {
      await _firestore.collection('conversations').doc(conversationId).delete();

      final messages = await _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      _logger.e('Konuşma silinemedi: $e');
      throw _handleError('Konuşma silinemedi: $e');
    }
  }

  Future<MessageModel> createMessage({
    required String conversationId,
    required String content,
    List<String> attachments = const [],
    String? replyToId,
  }) async {
    try {
      final authService = Get.find<AuthRepository>();
      final currentUser = authService.currentUser?.uid;
      if (currentUser == null) throw _handleError('Kullanıcı bulunamadı');

      final messageDoc = await _firestore.collection('messages').add({
        'conversationId': conversationId,
        'senderId': currentUser,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'isEdited': false,
        'replyToId': replyToId,
        'attachments': attachments,
      });

      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': content,
        'lastMessageSenderId': currentUser,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'isRead': false,
        'unreadCount': FieldValue.increment(1),
      });

      return MessageModel(
        id: messageDoc.id,
        conversationId: conversationId,
        senderId: currentUser,
        senderName: '',
        content: content,
        timestamp: DateTime.now(),
        isRead: false,
        type: MessageType.text,
        attachments: attachments
            .map((url) => MessageAttachment(
                  url: url,
                  name: url.split('/').last,
                  size: '',
                  type: MessageType.image,
                ))
            .toList(),
      );
    } catch (e) {
      _logger.e('Mesaj gönderilemedi: $e');
      throw _handleError('Mesaj gönderilemedi: $e');
    }
  }

  Future<void> removeMessage(String messageId) async {
    try {
      await _firestore.collection('messages').doc(messageId).delete();
    } catch (e) {
      _logger.e('Mesaj silinemedi: $e');
      throw _handleError('Mesaj silinemedi: $e');
    }
  }

  /// Mesaj gönderir
  Future<void> sendMessage(MessageModel message) async {
    try {
      if (currentUserId.isEmpty) {
        throw Exception('Kullanıcı kimliği bulunamadı');
      }

      final messageRef = _firestore.collection('messages').doc();
      final conversationRef =
          _firestore.collection('conversations').doc(message.conversationId);

      await _firestore.runTransaction((transaction) async {
        try {
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
        } catch (transactionError) {
          _logger.e('Transaction içinde hata: $transactionError');
          throw transactionError;
        }
      });
    } catch (e) {
      _logger.e('Mesaj gönderilirken hata: $e');
      _errorHandler.handleError(
          'Mesaj gönderilirken hata: $e', ErrorHandlerService.SERVER_ERROR);
      rethrow;
    }
  }

  /// Konuşmaları gerçek zamanlı dinler
  Stream<List<ConversationModel>> getConversations() {
    try {
      if (currentUserId.isEmpty) {
        throw Exception('Kullanıcı kimliği bulunamadı');
      }

      return _firestore
          .collection('conversations')
          .where('participantId', isEqualTo: currentUserId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ConversationModel.fromMap({
                    ...doc.data(),
                    'id': doc.id,
                  }))
              .toList())
          .handleError((error) {
        _logger.e('Konuşmalar alınırken hata: $error');
        _errorHandler.handleError(error, ErrorHandlerService.SERVER_ERROR);
        return <ConversationModel>[];
      });
    } catch (e) {
      _logger.e('Konuşmalar stream oluşturulurken hata: $e');
      _errorHandler.handleError(e, ErrorHandlerService.SERVER_ERROR);
      return Stream.value(<ConversationModel>[]);
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
      _logger.e('Mesaj durumu güncellenirken hata: $e');
      throw _handleError('Mesaj durumu güncellenirken hata: $e');
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
      _logger.e('Okunmamış mesaj sayısı sıfırlanırken hata: $e');
      throw _handleError('Okunmamış mesaj sayısı sıfırlanırken hata: $e');
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
      _logger.e('Mesajlar okundu işaretlenirken hata: $e');
      _handleError('Mesajlar okundu işaretlenirken hata: $e');
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
      _logger.e('Konuşma okundu işaretlenirken hata: $e');
      _handleError('Konuşma okundu işaretlenirken hata: $e');
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
      _logger.e('Mesaj silinirken hata: $e');
      _handleError('Mesaj silinirken hata: $e');
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
      _logger.e('Konuşma silinirken hata: $e');
      _handleError('Konuşma silinirken hata: $e');
      rethrow;
    }
  }

  // Konuşma işlemleri
  Future<ConversationModel> fetchConversation(String conversationId) async {
    try {
      final doc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (!doc.exists) {
        throw Exception('Konuşma bulunamadı');
      }

      return ConversationModel.fromMap({
        ...doc.data()!,
        'id': doc.id,
      });
    } catch (e) {
      _logger.e('Konuşma alınamadı: $e');
      throw _handleError('Konuşma alınamadı: $e');
    }
  }

  Stream<List<ConversationModel>> listenToConversations() {
    try {
      return _firestore
          .collection('conversations')
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ConversationModel.fromMap({
                    ...doc.data(),
                    'id': doc.id,
                  }))
              .toList());
    } catch (e) {
      _logger.e('Konuşmalar alınamadı: $e');
      _handleError('Konuşmalar alınamadı: $e');
      return Stream.value([]);
    }
  }

  Stream<List<MessageModel>> listenToMessages(String conversationId) {
    try {
      return _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromMap({
                    ...(doc.data()),
                    'id': doc.id,
                  }))
              .toList());
    } catch (e) {
      _logger.e('Mesajlar alınamadı: $e');
      _handleError('Mesajlar alınamadı: $e');
      return Stream.value([]);
    }
  }

  Future<ConversationModel> createConversation(String userId) async {
    try {
      final authService = Get.find<AuthRepository>();
      final currentUser = authService.currentUser?.uid;
      if (currentUser == null) throw _handleError('Kullanıcı bulunamadı');

      final doc = await _firestore.collection('conversations').add({
        'participantId': userId,
        'participantName': '',
        'lastMessage': '',
        'lastMessageSenderId': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'isRead': false,
        'unreadCount': 0,
      });

      return ConversationModel(
        id: doc.id,
        participantId: userId,
        participantName: '',
        lastMessage: '',
        lastMessageSenderId: '',
        lastMessageTime: DateTime.now(),
        isRead: false,
        unreadCount: 0,
      );
    } catch (e) {
      _logger.e('Konuşma oluşturulamadı: $e');
      throw _handleError('Konuşma oluşturulamadı: $e');
    }
  }

  Future<void> eraseConversation(String conversationId) async {
    try {
      await _firestore.collection('conversations').doc(conversationId).delete();

      final messages = await _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      _logger.e('Konuşma silinemedi: $e');
      throw _handleError('Konuşma silinemedi: $e');
    }
  }

  // Mesaj işlemleri
  Future<MessageModel> getMessage(String messageId) async {
    try {
      final doc = await _firestore.collection('messages').doc(messageId).get();

      if (!doc.exists) {
        throw Exception('Mesaj bulunamadı');
      }

      return MessageModel.fromMap({
        ...doc.data()!,
        'id': doc.id,
      });
    } catch (e) {
      _logger.e('Mesaj alınamadı: $e');
      throw _handleError('Mesaj alınamadı: $e');
    }
  }

  Future<MessageModel> editMessage({
    required String messageId,
    required String newContent,
  }) async {
    try {
      await _firestore.collection('messages').doc(messageId).update({
        'content': newContent,
        'isEdited': true,
      });

      final doc = await _firestore.collection('messages').doc(messageId).get();
      return MessageModel.fromMap({
        ...doc.data()!,
        'id': doc.id,
      });
    } catch (e) {
      _logger.e('Mesaj düzenlenemedi: $e');
      throw _handleError('Mesaj düzenlenemedi: $e');
    }
  }

  Future<void> markAsRead(String conversationId) async {
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
      _logger.e('Mesajlar okundu işaretlenirken hata: $e');
      _handleError('Mesajlar okundu işaretlenirken hata: $e');
      rethrow;
    }
  }

  Future<void> updateTypingStatus({
    required String conversationId,
    required bool isTyping,
  }) async {
    try {
      await _firestore.collection('conversations').doc(conversationId).update({
        'typing.$currentUserId': isTyping,
      });
    } catch (e) {
      _logger.e('Yazma durumu güncellenemedi: $e');
      throw _handleError('Yazma durumu güncellenemedi: $e');
    }
  }

  Future<List<MessageModel>> searchMessages({
    required String query,
    String? conversationId,
    DateTime? date,
    String? type,
  }) async {
    try {
      Query messagesQuery = _firestore.collection('messages');

      if (conversationId != null) {
        messagesQuery =
            messagesQuery.where('conversationId', isEqualTo: conversationId);
      }

      if (date != null) {
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));

        messagesQuery = messagesQuery
            .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
            .where('timestamp', isLessThan: endOfDay);
      }

      if (type != null) {
        messagesQuery = messagesQuery.where('type', isEqualTo: type);
      }

      final querySnapshot = await messagesQuery
          .where('content', isGreaterThanOrEqualTo: query)
          .where('content', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      return querySnapshot.docs
          .map((doc) => MessageModel.fromMap({
                ...(doc.data() as Map<String, dynamic>),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      _logger.e('Mesaj araması yapılamadı: $e');
      throw _handleError('Mesaj araması yapılamadı: $e');
    }
  }
}
