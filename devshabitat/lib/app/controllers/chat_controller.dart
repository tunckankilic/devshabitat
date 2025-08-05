import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../models/message_model.dart';
import '../models/conversation_model.dart';
import '../core/services/error_handler_service.dart';

class ChatController extends GetxController {
  final ChatService _chatService = Get.find<ChatService>();
  final ErrorHandlerService _errorHandler = Get.find<ErrorHandlerService>();

  // Form Controllers
  late TextEditingController messageController;
  late TextEditingController searchController;
  late ScrollController scrollController;

  // State Management
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxString errorMessage = ''.obs;

  // Chat Data
  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final Rx<ConversationModel?> currentConversation = Rx<ConversationModel?>(null);

  // New Chat
  final RxList<Map<String, dynamic>> searchResults = <Map<String, dynamic>>[].obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;

  // Streams
  StreamSubscription? _conversationsSubscription;
  StreamSubscription? _messagesSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _loadConversations();
  }

  @override
  void onClose() {
    _disposeControllers();
    _cancelSubscriptions();
    super.onClose();
  }

  void _initializeControllers() {
    messageController = TextEditingController();
    searchController = TextEditingController();
    scrollController = ScrollController();
  }

  void _disposeControllers() {
    messageController.dispose();
    searchController.dispose();
    scrollController.dispose();
  }

  void _cancelSubscriptions() {
    _conversationsSubscription?.cancel();
    _messagesSubscription?.cancel();
  }

  // Konuşmaları yükle
  void _loadConversations() {
    _conversationsSubscription?.cancel();
    _conversationsSubscription = _chatService.getConversationsStream().listen(
      (conversationList) {
        conversations.value = conversationList.cast<ConversationModel>();
      },
      onError: (error) {
        errorMessage.value = 'Konuşmalar yüklenemedi';
        _errorHandler.handleError('Konuşma yükleme hatası: $error', 'CONVERSATION_LOAD_ERROR');
      },
    );
  }

  // Konuşma seç ve mesajları yükle
  void selectConversation(ConversationModel conversation) {
    currentConversation.value = conversation;
    _loadMessages(conversation.id);
    _markConversationAsRead(conversation.id);
  }

  // Mesajları yükle
  void _loadMessages(String conversationId) {
    _messagesSubscription?.cancel();
    _messagesSubscription = _chatService.getMessagesStream(conversationId).listen(
      (messageList) {
        messages.value = messageList;
        _scrollToBottom();
      },
      onError: (error) {
        errorMessage.value = 'Mesajlar yüklenemedi';
        _errorHandler.handleError('Mesaj yükleme hatası: $error', 'MESSAGE_LOAD_ERROR');
      },
    );
  }

  // Mesaj gönder
  Future<void> sendMessage() async {
    final content = messageController.text.trim();
    if (content.isEmpty || currentConversation.value == null) return;

    isSending.value = true;
    messageController.clear();

    try {
      await _chatService.sendMessage(
        currentConversation.value!.id,
        content,
        MessageType.text,
      );

      _scrollToBottom();
    } catch (e) {
      errorMessage.value = 'Mesaj gönderilemedi';
      _errorHandler.handleError('Mesaj gönderme hatası: $e', 'MESSAGE_SEND_ERROR');
    } finally {
      isSending.value = false;
    }
  }

  // Yeni sohbet başlat
  Future<void> startNewChat(String targetUserId, String? initialMessage) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final conversationId = await _chatService.startNewChat(targetUserId, initialMessage);
      
      if (conversationId != null) {
        // Yeni konuşmayı bul ve seç
        await Future.delayed(const Duration(milliseconds: 500));
        final conversation = conversations.firstWhereOrNull((c) => c.id == conversationId);
        if (conversation != null) {
          selectConversation(conversation);
        }
        
        Get.back(); // New chat ekranından geri dön
      } else {
        errorMessage.value = 'Sohbet başlatılamadı';
      }
    } catch (e) {
      errorMessage.value = 'Sohbet başlatılırken hata oluştu';
      _errorHandler.handleError('Sohbet başlatma hatası: $e', 'CHAT_START_ERROR');
    } finally {
      isLoading.value = false;
    }
  }

  // Kullanıcı arama
  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    isSearching.value = true;
    searchQuery.value = query;

    try {
      final results = await _chatService.searchUsers(query);
      searchResults.value = results;
    } catch (e) {
      errorMessage.value = 'Kullanıcı arama hatası';
      _errorHandler.handleError('Kullanıcı arama hatası: $e', 'USER_SEARCH_ERROR');
    } finally {
      isSearching.value = false;
    }
  }

  // Arama temizle
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    searchResults.clear();
  }

  // Konuşmayı okundu işaretle
  Future<void> _markConversationAsRead(String conversationId) async {
    try {
      await _chatService.markConversationAsRead(conversationId);
    } catch (e) {
      // Sessizce hata yakala
    }
  }

  // Mesaj düzenle
  Future<void> editMessage(String messageId, String newContent) async {
    try {
      await _chatService.editMessage(messageId, newContent);
    } catch (e) {
      errorMessage.value = 'Mesaj düzenlenemedi';
      _errorHandler.handleError('Mesaj düzenleme hatası: $e', 'MESSAGE_EDIT_ERROR');
    }
  }

  // Mesaj sil
  Future<void> deleteMessage(String messageId) async {
    try {
      await _chatService.deleteMessage(messageId);
    } catch (e) {
      errorMessage.value = 'Mesaj silinemedi';
      _errorHandler.handleError('Mesaj silme hatası: $e', 'MESSAGE_DELETE_ERROR');
    }
  }

  // En alta kaydır
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Konuşma silme
  Future<void> deleteConversation(String conversationId) async {
    try {
      // Firestore'da konuşmayı pasif yap
      // Bu işlem ChatService'e eklenebilir
      conversations.removeWhere((c) => c.id == conversationId);
      
      if (currentConversation.value?.id == conversationId) {
        currentConversation.value = null;
        messages.clear();
      }
    } catch (e) {
      errorMessage.value = 'Konuşma silinemedi';
      _errorHandler.handleError('Konuşma silme hatası: $e', 'CONVERSATION_DELETE_ERROR');
    }
  }

  // Getters
  bool get hasConversations => conversations.isNotEmpty;
  bool get hasMessages => messages.isNotEmpty;
  bool get hasSearchResults => searchResults.isNotEmpty;
  
  int get unreadCount => conversations
      .map((c) => c.unreadCount)
      .fold(0, (total, count) => total + count);
}