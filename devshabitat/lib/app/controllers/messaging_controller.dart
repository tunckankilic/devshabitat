import 'dart:async';
import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:get/get.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../services/messaging_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/error_handler_service.dart';

class MessagingController extends GetxController {
  final MessagingService _messagingService;
  final AuthRepository _authService;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ErrorHandlerService _errorHandler;
  final Logger _logger = Logger();

  static const int pageSize = 20;
  static const int loadMoreThreshold = 5;

  final RxMap<String, List<MessageModel>> conversationMessages =
      RxMap<String, List<MessageModel>>();
  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt unreadCount = 0.obs;
  final RxString searchQuery = ''.obs;
  final Rx<ConversationModel?> selectedConversation =
      Rx<ConversationModel?>(null);

  StreamSubscription? _conversationsSubscription;
  final Map<String, int> _lastMessageTimestamp = {};
  final Map<String, bool> _isLoadingMore = {};
  final Map<String, bool> _hasMoreMessages = {};

  String get currentUserId => _auth.currentUser?.uid ?? '';

  MessagingController({
    required MessagingService messagingService,
    required AuthRepository authService,
    required ErrorHandlerService errorHandler,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _messagingService = messagingService,
        _authService = authService,
        _errorHandler = errorHandler,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    loadConversations();
  }

  @override
  void onClose() {
    _conversationsSubscription?.cancel();
    super.onClose();
  }

  Future<void> loadConversations() async {
    try {
      isLoading.value = true;
      _conversationsSubscription?.cancel();

      _conversationsSubscription = _messagingService.getConversations().listen(
        (List<ConversationModel> newConversations) {
          conversations.value = newConversations;
          _updateUnreadCount();
        },
        onError: (error) {
          _errorHandler.handleError('Konuşmalar yüklenirken hata: $error',
              ErrorHandlerService.SERVER_ERROR);
          errorMessage.value = 'Konuşmalar yüklenirken hata oluştu';
        },
      );
    } catch (e) {
      _errorHandler.handleError(
          'Beklenmeyen hata: $e', ErrorHandlerService.SERVER_ERROR);
      errorMessage.value = 'Konuşmalar yüklenirken beklenmeyen hata';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMessages(String conversationId,
      {bool loadMore = false}) async {
    if (_isLoadingMore[conversationId] == true) return;
    if (!loadMore && _hasMoreMessages[conversationId] == false) return;

    try {
      _isLoadingMore[conversationId] = true;

      if (!loadMore) {
        _lastMessageTimestamp[conversationId] =
            DateTime.now().millisecondsSinceEpoch;
        _hasMoreMessages[conversationId] = true;
      }

      final query = _buildMessageQuery(conversationId, loadMore);
      final snapshot = await query.get();
      final messages =
          snapshot.docs.map((doc) => MessageModel.fromMap(doc.data())).toList();

      _updateMessages(conversationId, messages, loadMore);
      _updateLastTimestamp(conversationId, messages);
      _hasMoreMessages[conversationId] = messages.length >= pageSize;
    } catch (e) {
      _errorHandler.handleError(
          'Mesajlar yüklenirken hata: $e', ErrorHandlerService.SERVER_ERROR);
    } finally {
      _isLoadingMore[conversationId] = false;
    }
  }

  Query<Map<String, dynamic>> _buildMessageQuery(
      String conversationId, bool loadMore) {
    var query = _firestore
        .collection('messages')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('timestamp', descending: true)
        .limit(pageSize);

    if (loadMore && _lastMessageTimestamp[conversationId] != null) {
      query = query.startAfter([_lastMessageTimestamp[conversationId]]);
    }

    return query;
  }

  void _updateMessages(
      String conversationId, List<MessageModel> newMessages, bool loadMore) {
    if (loadMore) {
      final existingMessages = conversationMessages[conversationId] ?? [];
      conversationMessages[conversationId] = [
        ...existingMessages,
        ...newMessages
      ];
    } else {
      conversationMessages[conversationId] = newMessages;
    }
  }

  void _updateLastTimestamp(
      String conversationId, List<MessageModel> messages) {
    if (messages.isNotEmpty) {
      _lastMessageTimestamp[conversationId] =
          messages.last.timestamp.millisecondsSinceEpoch;
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = conversations
        .where(
            (conv) => !conv.isRead && conv.lastMessageSenderId != currentUserId)
        .length;
  }

  Future<void> sendMessage(String conversationId, String content) async {
    try {
      if (content.trim().isEmpty) return;

      final message = MessageModel(
        id: '',
        conversationId: conversationId,
        senderId: currentUserId,
        senderName: _auth.currentUser?.displayName ?? 'Anonim',
        content: content.trim(),
        timestamp: DateTime.now(),
        isRead: false,
      );

      await _messagingService.sendMessage(message);

      // Optimistic update
      final messages = conversationMessages[conversationId] ?? [];
      messages.insert(0, message);
      conversationMessages[conversationId] = [...messages];
    } catch (e) {
      _errorHandler.handleError(
          'Mesaj gönderilirken hata: $e', ErrorHandlerService.SERVER_ERROR);
    }
  }

  Future<void> markConversationAsRead(String conversationId) async {
    try {
      await _messagingService.markConversationAsRead(conversationId);
      _updateUnreadCount();
    } catch (e) {
      _errorHandler.handleError(
          'Okundu işaretlenirken hata: $e', ErrorHandlerService.SERVER_ERROR);
    }
  }

  Future<void> deleteMessage(String conversationId, String messageId) async {
    try {
      await _messagingService.deleteMessage(conversationId, messageId);

      // Optimistic update
      final messages = conversationMessages[conversationId] ?? [];
      messages.removeWhere((message) => message.id == messageId);
      conversationMessages[conversationId] = [...messages];
    } catch (e) {
      _errorHandler.handleError(
          'Mesaj silinirken hata: $e', ErrorHandlerService.SERVER_ERROR);
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      await _messagingService.deleteConversation(conversationId);

      // Optimistic update
      conversations.removeWhere((conv) => conv.id == conversationId);
      conversationMessages.remove(conversationId);
    } catch (e) {
      _errorHandler.handleError(
          'Konuşma silinirken hata: $e', ErrorHandlerService.SERVER_ERROR);
    }
  }

  void selectConversation(ConversationModel conversation) {
    selectedConversation.value = conversation;
    loadMessages(conversation.id);
    _messagingService.markMessagesAsRead(conversation.id);
  }
}
