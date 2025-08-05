import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/message_model.dart';
import '../models/conversation_model.dart';
import '../repositories/auth_repository.dart';
import '../core/services/error_handler_service.dart';

class ChatService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final ErrorHandlerService _errorHandler = Get.find<ErrorHandlerService>();

  // Yeni sohbet başlatma
  Future<String?> startNewChat(
    String targetUserId,
    String? initialMessage,
  ) async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) throw Exception('Kullanıcı oturum açmamış');

      // Mevcut sohbet var mı kontrol et
      final existingChat = await _findExistingChat(
        currentUser.uid,
        targetUserId,
      );
      if (existingChat != null) {
        return existingChat;
      }

      // Yeni konuşma oluştur
      final conversationData = {
        'participants': [currentUser.uid, targetUserId],
        'participantDetails': {
          currentUser.uid: {
            'name': currentUser.displayName ?? 'Anonim',
            'photoUrl': currentUser.photoURL,
            'lastSeen': FieldValue.serverTimestamp(),
          },
        },
        'lastMessage': initialMessage ?? '',
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        'lastMessageSenderId': currentUser.uid,
        'unreadCount': {currentUser.uid: 0, targetUserId: 1},
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Hedef kullanıcı bilgilerini al
      final targetUserDoc = await _firestore
          .collection('users')
          .doc(targetUserId)
          .get();
      if (targetUserDoc.exists) {
        final targetUserData = targetUserDoc.data() as Map<String, dynamic>;
        (conversationData['participantDetails']
            as Map<String, dynamic>)[targetUserId] = {
          'name': targetUserData['displayName'] ?? 'Anonim',
          'photoUrl': targetUserData['photoURL'],
          'lastSeen': FieldValue.serverTimestamp(),
        };
      }

      final docRef = await _firestore
          .collection('conversations')
          .add(conversationData);

      // İlk mesajı gönder
      if (initialMessage != null && initialMessage.isNotEmpty) {
        await sendMessage(docRef.id, initialMessage, MessageType.text);
      }

      return docRef.id;
    } catch (e) {
      _logger.e('Yeni sohbet başlatılırken hata: $e');
      _errorHandler.handleError('Sohbet başlatılamadı: $e', 'CHAT_START_ERROR');
      return null;
    }
  }

  // Mevcut sohbet bulma
  Future<String?> _findExistingChat(String userId1, String userId2) async {
    try {
      final query = await _firestore
          .collection('conversations')
          .where('participants', arrayContains: userId1)
          .get();

      for (final doc in query.docs) {
        final data = doc.data();
        final participants = List<String>.from(data['participants'] ?? []);
        if (participants.contains(userId2) && participants.length == 2) {
          return doc.id;
        }
      }

      return null;
    } catch (e) {
      _logger.e('Mevcut sohbet aranırken hata: $e');
      return null;
    }
  }

  // Mesaj gönderme
  Future<String?> sendMessage(
    String conversationId,
    String content,
    MessageType type, {
    List<MessageAttachment>? attachments,
    String? replyToId,
  }) async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) throw Exception('Kullanıcı oturum açmamış');

      final messageData = {
        'conversationId': conversationId,
        'senderId': currentUser.uid,
        'senderName': currentUser.displayName ?? 'Anonim',
        'content': content,
        'type': type.toString().split('.').last,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'attachments': attachments?.map((a) => a.toJson()).toList() ?? [],
        'replyToId': replyToId,
        'isEdited': false,
        'links': _extractLinks(content),
      };

      final docRef = await _firestore.collection('messages').add(messageData);

      // Konuşma son mesaj bilgilerini güncelle
      await _updateConversationLastMessage(
        conversationId,
        content,
        currentUser.uid,
      );

      return docRef.id;
    } catch (e) {
      _logger.e('Mesaj gönderilirken hata: $e');
      _errorHandler.handleError(
        'Mesaj gönderilemedi: $e',
        'MESSAGE_SEND_ERROR',
      );
      return null;
    }
  }

  // Konuşmadaki mesajları dinleme
  Stream<List<MessageModel>> getMessagesStream(String conversationId) {
    return _firestore
        .collection('messages')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromMap({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  // Kullanıcının konuşmalarını dinleme
  Stream<List<Conversation>> getConversationsStream() {
    final currentUser = _authRepository.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: currentUser.uid)
        .where('isActive', isEqualTo: true)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Conversation.fromFirestore(doc))
              .toList(),
        );
  }

  // Mesaj okundu işaretleme
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _firestore.collection('messages').doc(messageId).update({
        'isRead': true,
      });
    } catch (e) {
      _logger.e('Mesaj okundu işaretlenirken hata: $e');
    }
  }

  // Konuşmayı okundu işaretleme
  Future<void> markConversationAsRead(String conversationId) async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) return;

      await _firestore.collection('conversations').doc(conversationId).update({
        'unreadCount.${currentUser.uid}': 0,
      });
    } catch (e) {
      _logger.e('Konuşma okundu işaretlenirken hata: $e');
    }
  }

  // Konuşma son mesaj güncelleme
  Future<void> _updateConversationLastMessage(
    String conversationId,
    String message,
    String senderId,
  ) async {
    try {
      // Konuşmadaki diğer katılımcıları bul
      final conversationDoc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (conversationDoc.exists) {
        final data = conversationDoc.data() as Map<String, dynamic>;
        final participants = List<String>.from(data['participants'] ?? []);

        // Okunmamış mesaj sayılarını güncelle
        final unreadCount = <String, dynamic>{};
        for (final participantId in participants) {
          if (participantId == senderId) {
            unreadCount[participantId] = 0;
          } else {
            final currentUnread = data['unreadCount']?[participantId] ?? 0;
            unreadCount[participantId] = currentUnread + 1;
          }
        }

        await _firestore
            .collection('conversations')
            .doc(conversationId)
            .update({
              'lastMessage': message,
              'lastMessageTimestamp': FieldValue.serverTimestamp(),
              'lastMessageSenderId': senderId,
              'unreadCount': unreadCount,
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      _logger.e('Konuşma son mesaj güncellenirken hata: $e');
    }
  }

  // Link çıkarma
  List<String> _extractLinks(String text) {
    final urlPattern = RegExp(r'https?://[^\s]+', caseSensitive: false);

    return urlPattern.allMatches(text).map((match) => match.group(0)!).toList();
  }

  // Mesaj düzenleme
  Future<bool> editMessage(String messageId, String newContent) async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) throw Exception('Kullanıcı oturum açmamış');

      await _firestore.collection('messages').doc(messageId).update({
        'content': newContent,
        'isEdited': true,
        'links': _extractLinks(newContent),
      });

      return true;
    } catch (e) {
      _logger.e('Mesaj düzenlenirken hata: $e');
      _errorHandler.handleError(
        'Mesaj düzenlenemedi: $e',
        'MESSAGE_EDIT_ERROR',
      );
      return false;
    }
  }

  // Mesaj silme
  Future<bool> deleteMessage(String messageId) async {
    try {
      await _firestore.collection('messages').doc(messageId).update({
        'content': '[Bu mesaj silindi]',
        'isDeleted': true,
      });

      return true;
    } catch (e) {
      _logger.e('Mesaj silinirken hata: $e');
      _errorHandler.handleError('Mesaj silinemedi: $e', 'MESSAGE_DELETE_ERROR');
      return false;
    }
  }

  // Kullanıcı arama (yeni sohbet için)
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThan: '${query}z')
          .limit(20)
          .get();

      return snapshot.docs
          .where((doc) => doc.id != currentUser.uid) // Kendini hariç tut
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      _logger.e('Kullanıcı aranırken hata: $e');
      return [];
    }
  }
}
