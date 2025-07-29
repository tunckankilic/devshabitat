import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../models/message_model.dart';
import '../../models/conversation_model.dart';
import '../../services/messaging_service.dart';
import '../../core/services/error_handler_service.dart';
import '../../core/services/memory_manager_service.dart';
import '../../repositories/auth_repository.dart';

/// MessageBaseController - Tüm messaging controller'ları için temel sınıf
/// Ortak messaging işlemleri, UI state yönetimi ve error handling sağlar
abstract class MessageBaseController extends GetxController
    with MemoryManagementMixin {
  final MessagingService _messagingService;
  final ErrorHandlerService _errorHandler;
  final Logger _logger = Logger();

  // Base UI Controllers
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // Base reactive variables
  final _isLoading = false.obs;
  final _lastError = ''.obs;
  final _isTyping = false.obs;
  final _isSending = false.obs;
  final _isOnline = true.obs;
  final _lastActivity = DateTime.now().obs;

  // Message management
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxList<MessageModel> pendingMessages = <MessageModel>[].obs;
  final RxList<MessageModel> failedMessages = <MessageModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool hasUnsentMessages = false.obs;

  // Conversation management
  final Rx<ConversationModel?> currentConversation =
      Rx<ConversationModel?>(null);
  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;

  // Stream subscriptions
  StreamSubscription? _messageStreamSubscription;
  StreamSubscription? _conversationStreamSubscription;
  Timer? _typingTimer;
  Timer? _activityTimer;

  // Getters
  bool get isLoading => _isLoading.value;
  String get lastError => _lastError.value;
  bool get isTyping => _isTyping.value;
  bool get isSending => _isSending.value;
  bool get isOnline => _isOnline.value;
  DateTime get lastActivity => _lastActivity.value;
  MessagingService get messagingService => _messagingService;

  MessageBaseController({
    required MessagingService messagingService,
    required ErrorHandlerService errorHandler,
  })  : _messagingService = messagingService,
        _errorHandler = errorHandler;

  @override
  void onInit() {
    super.onInit();
    _initializeBaseFeatures();
    _startActivityMonitoring();
  }

  @override
  void onClose() {
    _disposeSubscriptions();
    _disposeTimers();
    super.onClose();
  }

  /// Temel özellikleri başlat
  void _initializeBaseFeatures() {
    try {
      _logger.i('MessageBaseController initialized');
      _setupErrorHandling();
      _setupNetworkMonitoring();
    } catch (e) {
      _logger.e('Base features initialization error: $e');
    }
  }

  /// Error handling kurulumu
  void _setupErrorHandling() {
    ever(_lastError, (error) {
      if (error.isNotEmpty) {
        _logger.e('Message error: $error');
        _errorHandler.handleError(error, ErrorHandlerService.MESSAGE_ERROR);
      }
    });
  }

  /// Network monitoring kurulumu
  void _setupNetworkMonitoring() {
    // Network connectivity monitoring burada eklenebilir
    // Örnek: Connectivity().onConnectivityChanged.listen(...)
  }

  /// Activity monitoring başlat
  void _startActivityMonitoring() {
    _activityTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _lastActivity.value = DateTime.now();
    });
  }

  // Base UI Operations
  void startLoading() {
    _isLoading.value = true;
    _lastError.value = '';
  }

  void stopLoading() {
    _isLoading.value = false;
  }

  void startSending() {
    _isSending.value = true;
    hasUnsentMessages.value = true;
  }

  void stopSending() {
    _isSending.value = false;
  }

  void setTyping(bool typing) {
    _isTyping.value = typing;
    if (typing) {
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 3), () {
        _isTyping.value = false;
      });
    }
  }

  void handleError(dynamic error) {
    _lastError.value = error.toString();
    _errorHandler.handleError(error, ErrorHandlerService.MESSAGE_ERROR);
  }

  // Message Operations
  Future<void> sendMessage(String content,
      {MessageType type = MessageType.text}) async {
    if (content.trim().isEmpty) return;

    try {
      startSending();

      final message = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: currentConversation.value?.id ?? '',
        senderId: _messagingService.currentUserId,
        senderName: Get.find<AuthRepository>().currentUser?.displayName ?? 'Me',
        content: content.trim(),
        timestamp: DateTime.now(),
        isRead: false,
        type: type,
      );

      // Add to pending messages
      pendingMessages.add(message);

      // Send message
      await _messagingService.sendMessage(message);

      // Remove from pending
      pendingMessages.remove(message);

      // Clear input
      messageController.clear();

      _logger.i('Message sent successfully');
    } catch (e) {
      handleError(e);
      _logger.e('Message send error: $e');
    } finally {
      stopSending();
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      startLoading();
      final conversationId = currentConversation.value?.id ?? '';
      await _messagingService.deleteMessage(conversationId, messageId);
      messages.removeWhere((msg) => msg.id == messageId);
      _logger.i('Message deleted: $messageId');
    } catch (e) {
      handleError(e);
    } finally {
      stopLoading();
    }
  }

  Future<void> markAsRead(String messageId) async {
    try {
      final conversationId = currentConversation.value?.id ?? '';
      await _messagingService.markAsRead(conversationId);
      final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
      if (messageIndex != -1) {
        messages[messageIndex] = messages[messageIndex].copyWith(isRead: true);
      }
    } catch (e) {
      handleError(e);
    }
  }

  // Conversation Operations
  Future<void> loadConversation(String conversationId) async {
    try {
      startLoading();
      final conversation =
          await _messagingService.fetchConversation(conversationId);
      currentConversation.value = conversation;
      await loadMessages(conversationId);
    } catch (e) {
      handleError(e);
    } finally {
      stopLoading();
    }
  }

  Future<void> loadMessages(String conversationId) async {
    try {
      final messageStream = _messagingService.listenToMessages(conversationId);
      _messageStreamSubscription = messageStream.listen(
        (messageList) {
          messages.assignAll(messageList);
          _updateUnreadCount();
        },
        onError: (error) {
          handleError(error);
        },
      );
      registerSubscription(_messageStreamSubscription!);
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> loadConversations() async {
    try {
      startLoading();
      final conversationStream = _messagingService.getConversations();
      _conversationStreamSubscription = conversationStream.listen(
        (conversationList) {
          conversations.assignAll(conversationList);
        },
        onError: (error) {
          handleError(error);
        },
      );
      registerSubscription(_conversationStreamSubscription!);
    } catch (e) {
      handleError(e);
    } finally {
      stopLoading();
    }
  }

  // Utility Methods
  void _updateUnreadCount() {
    unreadCount.value = messages.where((msg) => !msg.isRead).length;
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void clearError() {
    _lastError.value = '';
  }

  // Cleanup Methods
  void _disposeSubscriptions() {
    _messageStreamSubscription?.cancel();
    _conversationStreamSubscription?.cancel();
  }

  void _disposeTimers() {
    _typingTimer?.cancel();
    _activityTimer?.cancel();
  }

  // Template Methods - Alt sınıflar tarafından override edilebilir
  void onMessageReceived(MessageModel message) {
    // Alt sınıflar tarafından override edilebilir
  }

  void onConversationUpdated(ConversationModel conversation) {
    // Alt sınıflar tarafından override edilebilir
  }

  void onTypingStatusChanged(String userId, bool isTyping) {
    // Alt sınıflar tarafından override edilebilir
  }

  void onConnectionStatusChanged(bool isOnline) {
    _isOnline.value = isOnline;
    // Alt sınıflar tarafından override edilebilir
  }
}
