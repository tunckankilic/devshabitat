import 'package:get/get.dart';
import '../../models/message_model.dart';
import 'message_base_controller.dart';

class MessageInteractionController extends MessageBaseController {
  final RxString selectedMessageId = ''.obs;
  final RxBool isReplying = false.obs;
  final RxBool isEditing = false.obs;
  final RxBool isForwarding = false.obs;

  MessageInteractionController({
    required super.messagingService,
    required super.errorHandler,
  });

  void startReply(String messageId) {
    selectedMessageId.value = messageId;
    isReplying.value = true;
    isEditing.value = false;
    isForwarding.value = false;
  }

  void startEdit(String messageId) {
    selectedMessageId.value = messageId;
    isEditing.value = true;
    isReplying.value = false;
    isForwarding.value = false;
  }

  void startForward(String messageId) {
    selectedMessageId.value = messageId;
    isForwarding.value = true;
    isReplying.value = false;
    isEditing.value = false;
  }

  void cancelInteraction() {
    selectedMessageId.value = '';
    isReplying.value = false;
    isEditing.value = false;
    isForwarding.value = false;
  }

  Future<MessageModel> replyToMessage({
    required String conversationId,
    required String content,
    List<String> attachments = const [],
  }) async {
    try {
      startLoading();
      final message = await messagingService.createMessage(
        conversationId: conversationId,
        content: content,
        replyToId: selectedMessageId.value,
        attachments: attachments,
      );
      cancelInteraction();
      return message;
    } catch (e) {
      handleError(e);
      rethrow;
    } finally {
      stopLoading();
    }
  }

  Future<MessageModel> editMessage({
    required String messageId,
    required String newContent,
  }) async {
    try {
      startLoading();
      final message = await messagingService.editMessage(
        messageId: messageId,
        newContent: newContent,
      );
      cancelInteraction();
      return message;
    } catch (e) {
      handleError(e);
      rethrow;
    } finally {
      stopLoading();
    }
  }

  Future<MessageModel> forwardMessage({
    required String targetConversationId,
    required String messageId,
    String? additionalContent,
  }) async {
    try {
      startLoading();
      final originalMessage = await messagingService.getMessage(messageId);

      final content = additionalContent != null
          ? '$additionalContent\n\n${originalMessage.content}'
          : originalMessage.content;

      final message = await messagingService.createMessage(
        conversationId: targetConversationId,
        content: content,
        attachments: originalMessage.attachments.map((a) => a.url).toList(),
      );
      cancelInteraction();
      return message;
    } catch (e) {
      handleError(e);
      rethrow;
    } finally {
      stopLoading();
    }
  }
}
