import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../models/message_model.dart';
import '../../models/conversation_model.dart';
import '../../services/messaging_service.dart';
import '../../services/background_sync_service.dart';
import '../../controllers/auth_controller.dart';
import '../../core/services/error_handler_service.dart';
import '../../core/services/memory_manager_service.dart';

class MessageChatController extends GetxController with MemoryManagementMixin {
  final MessagingService _messagingService;
  final BackgroundSyncService _syncService = Get.find<BackgroundSyncService>();
  final ErrorHandlerService _errorHandler = Get.find<ErrorHandlerService>();
  final Logger _logger = Logger();

  // UI Controllers
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // Enhanced reactive variables
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final Rx<ConversationModel?> currentConversation =
      Rx<ConversationModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxBool isTyping = false.obs;
  final RxBool isSyncing = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString syncStatus = ''.obs;

  // Enhanced message management
  final RxList<MessageModel> pendingMessages = <MessageModel>[].obs;
  final RxList<MessageModel> failedMessages = <MessageModel>[].obs;
  final RxInt unseenMessageCount = 0.obs;
  final RxBool batteryOptimized = true.obs;
  final RxInt offlineQueueSize = 0.obs;

  StreamSubscription? _messageStreamSubscription;
  Timer? _typingTimer;
  Timer? _syncTimer;

  MessageChatController({
    required MessagingService messagingService,
  }) : _messagingService = messagingService;

  @override
  void onInit() {
    super.onInit();
    _initializeSyncIntegration();
    _startPeriodicSync();
  }

  // Initialize enhanced sync service integration
  void _initializeSyncIntegration() {
    try {
      // Monitor sync service status
      isSyncing.value = _syncService.isSyncing;

      // Get sync status updates
      syncStatus.value = _syncService.syncStatus;

      _logger.i('Sync integration initialized');
    } catch (e) {
      _logger.e('Sync integration error: $e');
    }
  }

  // Enhanced message loading with sync awareness
  Future<void> loadMessages(String conversationId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Load conversation
      final conversation =
          await _messagingService.fetchConversation(conversationId);
      currentConversation.value = conversation;

      // Setup real-time message listener
      final messageStream = _messagingService.listenToMessages(conversationId);
      _messageStreamSubscription = messageStream.listen(
        (messageList) {
          _processIncomingMessages(messageList);
        },
        onError: (error) {
          errorMessage.value = 'Message stream error: $error';
          _logger.e('Message stream error: $error');
          _errorHandler.handleError(error, ErrorHandlerService.MESSAGE_ERROR);
        },
      );

      registerSubscription(_messageStreamSubscription!);

      // Mark messages as read
      await _messagingService.markAsRead(conversationId);

      _logger.i('Messages loaded for conversation: $conversationId');
    } catch (e) {
      errorMessage.value = 'Failed to load messages: $e';
      _logger.e('Load messages error: $e');
      _errorHandler.handleError(e, ErrorHandlerService.MESSAGE_ERROR);
    } finally {
      isLoading.value = false;
    }
  }

  void _processIncomingMessages(List<MessageModel> messageList) {
    try {
      messages.assignAll(messageList);
      _updateUnseenCount();
      _removeSyncedMessages(messageList);
    } catch (e) {
      _logger.e('Process incoming messages error: $e');
    }
  }

  void _updateUnseenCount() {
    final currentUserId = Get.find<AuthController>().currentUser?.uid;
    if (currentUserId == null) return;

    final unseenCount = messages
        .where((msg) => msg.senderId != currentUserId && !msg.isRead)
        .length;

    unseenMessageCount.value = unseenCount;
  }

  void _removeSyncedMessages(List<MessageModel> syncedMessages) {
    for (final syncedMsg in syncedMessages) {
      pendingMessages.removeWhere((pending) => pending.id == syncedMsg.id);
      failedMessages.removeWhere((failed) => failed.id == syncedMsg.id);
    }
  }

  // Enhanced message sending with background sync
  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) return;
    if (currentConversation.value == null) return;

    try {
      isSending.value = true;
      errorMessage.value = '';

      // Create message through service
      final message = await _messagingService.createMessage(
        conversationId: currentConversation.value!.id,
        content: messageController.text.trim(),
      );

      // Add to local messages immediately
      messages.add(message);

      // Add to background sync queue for reliability
      await _syncService.addToSyncQueue(message);
      pendingMessages.add(message);

      // Clear input and scroll
      messageController.clear();
      scrollToBottom();

      syncStatus.value = 'Message queued for sync';
      _logger.i('Message sent and queued for sync: ${message.id}');
    } catch (e) {
      errorMessage.value = 'Failed to send message: $e';
      _logger.e('Send message error: $e');
      _errorHandler.handleError(e, ErrorHandlerService.MESSAGE_ERROR);

      // Add to failed messages for retry
      final failedMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: messageController.text.trim(),
        senderId: Get.find<AuthController>().currentUser?.uid ?? '',
        senderName:
            Get.find<AuthController>().currentUser?.displayName ?? 'Unknown',
        conversationId: currentConversation.value!.id,
        timestamp: DateTime.now(),
        type: MessageType.text,
        isRead: false,
        isEdited: false,
      );
      failedMessages.add(failedMessage);
    } finally {
      isSending.value = false;
    }
  }

  // Enhanced message operations with sync
  Future<void> deleteMessage(String messageId) async {
    try {
      await _messagingService.removeMessage(messageId);
      messages.removeWhere((message) => message.id == messageId);
      pendingMessages.removeWhere((message) => message.id == messageId);
      _logger.i('Message deleted: $messageId');
    } catch (e) {
      errorMessage.value = 'Failed to delete message: $e';
      _logger.e('Delete message error: $e');
      _errorHandler.handleError(e, ErrorHandlerService.MESSAGE_ERROR);
    }
  }

  Future<void> editMessage(String messageId, String newContent) async {
    try {
      final updatedMessage = await _messagingService.editMessage(
        messageId: messageId,
        newContent: newContent,
      );

      final index = messages.indexWhere((message) => message.id == messageId);
      if (index != -1) {
        messages[index] = updatedMessage;
      }

      // Add to sync queue for reliability
      await _syncService.addToSyncQueue(updatedMessage);
      _logger.i('Message edited: $messageId');
    } catch (e) {
      errorMessage.value = 'Failed to edit message: $e';
      _logger.e('Edit message error: $e');
      _errorHandler.handleError(e, ErrorHandlerService.MESSAGE_ERROR);
    }
  }

  // Typing indicators with reliability
  void updateTypingStatus(bool typing) {
    isTyping.value = typing;

    try {
      if (currentConversation.value != null) {
        _messagingService.updateTypingStatus(
          conversationId: currentConversation.value!.id,
          isTyping: typing,
        );
      }

      if (typing) {
        _typingTimer?.cancel();
        _typingTimer = Timer(const Duration(seconds: 3), () {
          updateTypingStatus(false);
        });
      }
    } catch (e) {
      _logger.e('Update typing status error: $e');
    }
  }

  // Retry failed messages
  Future<void> retryFailedMessages() async {
    try {
      for (final failedMessage in failedMessages.toList()) {
        await _syncService.addToSyncQueue(failedMessage);
        failedMessages.remove(failedMessage);
        pendingMessages.add(failedMessage);
      }

      syncStatus.value = 'Retrying ${failedMessages.length} failed messages';
      _logger.i('Retried ${failedMessages.length} failed messages');
    } catch (e) {
      errorMessage.value = 'Failed to retry messages: $e';
      _logger.e('Retry failed messages error: $e');
    }
  }

  // Manual sync trigger
  Future<void> triggerSync() async {
    try {
      for (final message in pendingMessages.toList()) {
        await _syncService.addToSyncQueue(message);
      }
      syncStatus.value = 'Manual sync triggered';
      _logger.i('Manual sync triggered for ${pendingMessages.length} messages');
    } catch (e) {
      errorMessage.value = 'Failed to trigger sync: $e';
      _logger.e('Manual sync error: $e');
    }
  }

  // Periodic sync for reliability
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      if (pendingMessages.isNotEmpty) {
        triggerSync();
      }
    });
  }

  // Enhanced conversation operations
  Future<void> deleteConversation(String conversationId) async {
    try {
      isLoading.value = true;
      await _messagingService.eraseConversation(conversationId);

      messages.clear();
      pendingMessages.clear();
      failedMessages.clear();
      currentConversation.value = null;

      Get.back(); // Return to conversation list
      _logger.i('Conversation deleted: $conversationId');
    } catch (e) {
      errorMessage.value = 'Failed to delete conversation: $e';
      _logger.e('Delete conversation error: $e');
      _errorHandler.handleError(e, ErrorHandlerService.MESSAGE_ERROR);
    } finally {
      isLoading.value = false;
    }
  }

  // UI helper methods
  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Clear all local state
  void clearLocalMessages() {
    messages.clear();
    pendingMessages.clear();
    failedMessages.clear();
    unseenMessageCount.value = 0;
    messageController.clear();
  }

  // Comprehensive status for debugging
  Map<String, dynamic> getChatStatus() {
    return {
      'conversation_id': currentConversation.value?.id,
      'total_messages': messages.length,
      'pending_messages': pendingMessages.length,
      'failed_messages': failedMessages.length,
      'unseen_count': unseenMessageCount.value,
      'is_loading': isLoading.value,
      'is_sending': isSending.value,
      'is_syncing': isSyncing.value,
      'is_typing': isTyping.value,
      'sync_status': syncStatus.value,
      'offline_queue_size': offlineQueueSize.value,
      'battery_optimized': batteryOptimized.value,
      'error_message': errorMessage.value,
    };
  }

  @override
  void onClose() {
    // Clean up UI state
    isTyping.value = false;
    updateTypingStatus(false);

    // Clear data
    currentConversation.value = null;
    clearLocalMessages();

    // Dispose controllers
    messageController.dispose();
    scrollController.dispose();

    // Cancel timers
    _typingTimer?.cancel();
    _syncTimer?.cancel();

    // MemoryManagementMixin will automatically clean up subscriptions
    super.onClose();
  }
}
