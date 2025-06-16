import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../services/messaging_service.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class MessagingController extends GetxController {
  final MessagingService _messagingService = Get.find<MessagingService>();
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  // Getters
  String? get currentUserId => _authService.currentUser.value?.uid;

  // Reactive Variables
  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;
  final RxMap<String, List<MessageModel>> conversationMessages =
      <String, List<MessageModel>>{}.obs;
  final Rx<ConversationModel?> selectedConversation =
      Rx<ConversationModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt unreadCount = 0.obs;
  final RxString searchQuery = ''.obs;

  // Stream Subscriptions
  late final StreamSubscription _conversationsSubscription;
  StreamSubscription? _messagesSubscription;

  // Pagination değişkenleri
  final int pageSize = 20;
  final RxMap<String, int> lastMessageTimestamp = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadConversations();
    _setupSearchListener();
  }

  void _setupSearchListener() {
    debounce(searchQuery, (String query) {
      if (query.isNotEmpty) {
        _searchConversations(query);
      } else {
        loadConversations();
      }
    }, time: const Duration(milliseconds: 500));
  }

  Future<void> loadConversations() async {
    try {
      isLoading.value = true;
      _conversationsSubscription = _messagingService.getConversations().listen(
          (List<ConversationModel> newConversations) {
        conversations.value = newConversations;
        _updateUnreadCount();
      }, onError: (error) {
        errorMessage.value = 'Konuşmalar yüklenirken hata oluştu: $error';
      });
    } catch (e) {
      errorMessage.value = 'Konuşmalar yüklenirken beklenmeyen hata: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMessages(String conversationId,
      {bool loadMore = false}) async {
    try {
      if (!loadMore) {
        lastMessageTimestamp[conversationId] =
            DateTime.now().millisecondsSinceEpoch;
      }

      final lastTimestamp = lastMessageTimestamp[conversationId];
      final query = _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .orderBy('timestamp', descending: true)
          .limit(pageSize);

      if (loadMore && lastTimestamp != null) {
        query.startAfter([lastTimestamp]);
      }

      final snapshot = await query.get();
      final messages =
          snapshot.docs.map((doc) => MessageModel.fromMap(doc.data())).toList();

      if (loadMore) {
        final existingMessages = conversationMessages[conversationId] ?? [];
        conversationMessages[conversationId] = [
          ...existingMessages,
          ...messages
        ];
      } else {
        conversationMessages[conversationId] = messages;
      }

      if (messages.isNotEmpty) {
        lastMessageTimestamp[conversationId] =
            messages.last.timestamp.millisecondsSinceEpoch;
      }
    } catch (e) {
      _logger.e('Mesajlar yüklenirken hata: $e');
    }
  }

  Future<void> sendMessage(String conversationId, String content) async {
    try {
      isLoading.value = true;
      final message = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: conversationId,
        content: content,
        senderId: _authService.currentUser.value?.uid ?? '',
        senderName: _authService.currentUser.value?.displayName ?? 'Anonim',
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
        type: 'text',
      );

      await _messagingService.sendMessage(message);
    } catch (e) {
      errorMessage.value = 'Mesaj gönderilirken hata oluştu: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createConversation(ConversationModel newConversation) async {
    try {
      isLoading.value = true;
      final conversation =
          await _messagingService.createConversation(newConversation);
      selectedConversation.value = conversation;
      await loadMessages(conversation.id);
    } catch (e) {
      errorMessage.value = 'Konuşma oluşturulurken hata oluştu: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void _searchConversations(String query) {
    try {
      final filteredConversations = conversations.where((conversation) {
        final participantName = conversation.participantName.toLowerCase();
        final lastMessage = conversation.lastMessage?.toLowerCase() ?? '';
        final searchLower = query.toLowerCase();

        return participantName.contains(searchLower) ||
            lastMessage.contains(searchLower);
      }).toList();

      conversations.value = filteredConversations;
    } catch (e) {
      errorMessage.value = 'Arama yapılırken hata oluştu: $e';
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = conversations.fold(0, (sum, conversation) {
      return sum + (conversation.unreadCount ?? 0);
    });
  }

  void selectConversation(ConversationModel conversation) {
    selectedConversation.value = conversation;
    loadMessages(conversation.id);
    _messagingService.markMessagesAsRead(conversation.id);
  }

  @override
  void onClose() {
    _conversationsSubscription.cancel();
    _messagesSubscription?.cancel();
    super.onClose();
  }
}
