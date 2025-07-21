import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/message_model.dart';
import '../../models/conversation_model.dart';
import '../../core/services/memory_manager_service.dart';
import 'message_base_controller.dart';

class MessageChatController extends MessageBaseController
    with MemoryManagementMixin {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final Rx<ConversationModel?> currentConversation =
      Rx<ConversationModel?>(null);
  final RxBool isTyping = false.obs;
  StreamSubscription? _messageStreamSubscription;

  MessageChatController({
    required super.messagingService,
    required super.errorHandler,
  });

  Future<void> loadMessages(String conversationId) async {
    try {
      startLoading();
      final conversation =
          await messagingService.fetchConversation(conversationId);
      currentConversation.value = conversation;

      final messageStream = messagingService.listenToMessages(conversationId);
      _messageStreamSubscription = messageStream.listen((messageList) {
        messages.assignAll(messageList);
      });
      registerSubscription(_messageStreamSubscription!); // Otomatik yönetim

      // Okunmamış mesajları okundu olarak işaretle
      await messagingService.markAsRead(conversationId);
    } catch (e) {
      handleError(e);
    } finally {
      stopLoading();
    }
  }

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) return;
    if (currentConversation.value == null) return;

    try {
      final message = await messagingService.createMessage(
        conversationId: currentConversation.value!.id,
        content: messageController.text,
      );

      messages.add(message);
      messageController.clear();
      scrollToBottom();
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await messagingService.removeMessage(messageId);
      messages.removeWhere((message) => message.id == messageId);
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> editMessage(String messageId, String newContent) async {
    try {
      final updatedMessage = await messagingService.editMessage(
        messageId: messageId,
        newContent: newContent,
      );

      final index = messages.indexWhere((message) => message.id == messageId);
      if (index != -1) {
        messages[index] = updatedMessage;
      }
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      startLoading();
      await messagingService.eraseConversation(conversationId);
      messages.clear();
      currentConversation.value = null;
      Get.back(); // Konuşma listesine dön
    } catch (e) {
      handleError(e);
    } finally {
      stopLoading();
    }
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

  void updateTypingStatus(bool typing) {
    isTyping.value = typing;
    if (currentConversation.value != null) {
      messagingService.updateTypingStatus(
        conversationId: currentConversation.value!.id,
        isTyping: typing,
      );
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    // MemoryManagementMixin otomatik olarak subscription'ı temizleyecek
    super.onClose();
  }
}
