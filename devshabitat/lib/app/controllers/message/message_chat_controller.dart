import 'dart:async';
import 'package:get/get.dart';
import 'package:battery_plus/battery_plus.dart';
import '../../models/message_model.dart';
import '../../services/background_sync_service.dart';
import '../../services/audio_service.dart';
import '../../controllers/auth_controller.dart';
import 'message_base_controller.dart';

/// MessageChatController - Chat ekranı için özelleştirilmiş controller
/// MessageBaseController'dan extend eder ve chat-specific özellikler ekler
class MessageChatController extends MessageBaseController {
  final BackgroundSyncService _syncService = Get.find<BackgroundSyncService>();
  final AudioService _audioService = Get.find<AudioService>();
  final Battery _battery = Battery();

  // Chat-specific reactive variables
  final RxBool isSyncing = false.obs;
  final RxString syncStatus = ''.obs;
  final RxInt unseenMessageCount = 0.obs;
  final RxBool batteryOptimized = true.obs;
  final RxInt offlineQueueSize = 0.obs;

  Timer? _syncTimer;

  MessageChatController({
    required super.messagingService,
    required super.errorHandler,
  });

  @override
  void onInit() {
    super.onInit();
    _initializeSyncIntegration();
    _startPeriodicSync();
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    super.onClose();
  }

  // Initialize enhanced sync service integration
  void _initializeSyncIntegration() {
    try {
      // Monitor sync service status
      isSyncing.value = _syncService.isSyncing;

      // Get sync status updates
      syncStatus.value = _syncService.syncStatus;

      print('Sync integration initialized');
    } catch (e) {
      print('Sync integration error: $e');
    }
  }

  // Enhanced message loading with sync awareness
  @override
  Future<void> loadMessages(String conversationId) async {
    try {
      startLoading();
      clearError();

      // Load conversation
      final conversation =
          await messagingService.fetchConversation(conversationId);
      currentConversation.value = conversation;

      // Setup real-time message listener with sync awareness
      final messageStream = messagingService.listenToMessages(conversationId);
      final messageStreamSubscription = messageStream.listen(
        (messageList) {
          _processIncomingMessages(messageList);
        },
        onError: (error) {
          handleError(error);
        },
      );

      registerSubscription(messageStreamSubscription);

      // Mark messages as read
      await messagingService.markAsRead(conversationId);

      print('Messages loaded for conversation: $conversationId');
    } catch (e) {
      handleError(e);
    } finally {
      stopLoading();
    }
  }

  void _processIncomingMessages(List<MessageModel> messageList) {
    try {
      messages.assignAll(messageList);
      _updateUnseenCount();
      _removeSyncedMessages(messageList);
    } catch (e) {
      print('Process incoming messages error: $e');
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
  Future<void> sendChatMessage() async {
    if (messageController.text.trim().isEmpty) return;
    if (currentConversation.value == null) return;

    try {
      startSending();
      clearError();

      // Create message through service
      final message = await messagingService.createMessage(
        conversationId: currentConversation.value!.id,
        content: messageController.text.trim(),
      );

      // Add to local messages immediately
      messages.add(message);

      // Clear input
      messageController.clear();

      // Scroll to bottom
      scrollToBottom();

      print('Message sent successfully');
    } catch (e) {
      handleError(e);
      print('Message send error: $e');
    } finally {
      stopSending();
    }
  }

  // Background sync integration
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _performBackgroundSync();
    });
  }

  Future<void> _performBackgroundSync() async {
    try {
      isSyncing.value = true;
      syncStatus.value = 'Syncing messages...';

      // Update offline queue size
      offlineQueueSize.value = pendingMessages.length;

      syncStatus.value = 'Sync completed';
      print('Background sync completed');
    } catch (e) {
      syncStatus.value = 'Sync failed';
      handleError(e);
    } finally {
      isSyncing.value = false;
    }
  }

  // Typing indicator management
  void startTyping() {
    setTyping(true);
    _sendTypingIndicator(true);
  }

  void stopTyping() {
    setTyping(false);
    _sendTypingIndicator(false);
  }

  void _sendTypingIndicator(bool isTyping) {
    try {
      final conversationId = currentConversation.value?.id;
      if (conversationId != null) {
        messagingService.updateTypingStatus(
          conversationId: conversationId,
          isTyping: isTyping,
        );
      }
    } catch (e) {
      print('Error sending typing indicator: $e');
    }
  }

  // Message actions
  Future<void> retryFailedMessage(MessageModel message) async {
    try {
      startLoading();

      // Remove from failed messages
      failedMessages.remove(message);

      // Add to pending messages
      pendingMessages.add(message);

      // Retry sending
      await messagingService.sendMessage(message);

      // Remove from pending
      pendingMessages.remove(message);

      print('Failed message retried successfully');
    } catch (e) {
      handleError(e);
      // Move back to failed messages
      failedMessages.add(message);
      pendingMessages.remove(message);
    } finally {
      stopLoading();
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      startLoading();
      final conversationId = currentConversation.value?.id ?? '';
      await messagingService.deleteMessage(conversationId, messageId);
      messages.removeWhere((msg) => msg.id == messageId);
      print('Message deleted: $messageId');
    } catch (e) {
      handleError(e);
    } finally {
      stopLoading();
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      startLoading();
      await messagingService.deleteConversation(conversationId);
      print('Conversation deleted: $conversationId');
    } catch (e) {
      handleError(e);
    } finally {
      stopLoading();
    }
  }

  Future<void> sendFileMessage(AttachmentData attachment) async {
    try {
      startSending();

      final message = await messagingService.createMessage(
        conversationId: currentConversation.value!.id,
        content: attachment.name,
        attachments: [attachment.url],
      );

      // Add to local messages immediately
      messages.add(message);

      // Scroll to bottom
      scrollToBottom();

      print('File message sent: ${attachment.name}');
    } catch (e) {
      handleError(e);
      print('File message send error: $e');
    } finally {
      stopSending();
    }
  }

  // Battery optimization check
  Future<void> checkBatteryOptimization() async {
    try {
      final batteryLevel = await _battery.batteryLevel;
      final batteryState = await _battery.batteryState;

      // Battery is optimized if level is above 20% and not charging
      batteryOptimized.value =
          batteryLevel > 20 && batteryState != BatteryState.charging;

      print('Battery level: $batteryLevel%, State: $batteryState');
    } catch (e) {
      batteryOptimized.value = false;
      print('Battery optimization check failed: $e');
    }
  }

  // Override base methods for chat-specific behavior
  @override
  void onMessageReceived(MessageModel message) {
    super.onMessageReceived(message);

    // Chat-specific message handling
    if (message.senderId != messagingService.currentUserId) {
      // Play notification sound
      _audioService.playMessageSound();

      // Update unseen count
      _updateUnseenCount();
    }
  }

  @override
  void onConnectionStatusChanged(bool isOnline) {
    super.onConnectionStatusChanged(isOnline);

    if (isOnline) {
      // Retry failed messages when back online
      _retryAllFailedMessages();
    }
  }

  void _retryAllFailedMessages() {
    final failedMessagesCopy = List<MessageModel>.from(failedMessages);
    for (final message in failedMessagesCopy) {
      retryFailedMessage(message);
    }
  }
}
