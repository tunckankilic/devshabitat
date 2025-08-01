import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/messaging_controller.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/feature_gate_widget.dart';
import '../../models/message_model.dart';

class ChatScreen extends GetView<MessagingController> {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final conversationId = Get.parameters['conversationId'] ?? '';
    final scrollController = ScrollController();

    // Konuşmayı yükle
    controller.loadMessages(conversationId);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          final conversation = controller.selectedConversation.value;
          return Text(
            conversation?.participantName ?? AppStrings.chat,
            style: Theme.of(context).textTheme.titleLarge,
          );
        }),
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final messages =
                  controller.conversationMessages[conversationId] ?? [];
              if (messages.isEmpty) {
                return const Center(
                  child: Text(AppStrings.noMessages),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await controller.loadMessages(conversationId, loadMore: true);
                },
                child: ListView.builder(
                  controller: scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    // Sayfalama için son elemana yaklaşıldığında yeni mesajları yükle
                    if (index == messages.length - 5) {
                      controller.loadMessages(conversationId, loadMore: true);
                    }

                    final messageModel = messages[index];
                    final isOwnMessage =
                        messageModel.senderId == controller.currentUserId;

                    // MessageModel'i Message'a dönüştür
                    final message = MessageModel(
                      id: messageModel.id,
                      conversationId: messageModel.conversationId,
                      content: messageModel.content,
                      senderId: messageModel.senderId,
                      senderName: messageModel.senderName,
                      timestamp: messageModel.timestamp,
                      isRead: messageModel.isRead,
                      type: MessageType.text, // Default olarak text
                      attachments: [], // Boş liste
                    );

                    return MessageBubble(
                      message: message,
                      isOwnMessage: isOwnMessage,
                    );
                  },
                ),
              );
            }),
          ),
          _buildMessageInput(conversationId, context),
        ],
      ),
    );
  }

  Widget _buildMessageInput(String conversationId, BuildContext context) {
    final textController = TextEditingController();

    return FeatureGate.wrap(
      feature: 'commenting',
      displayMode: FeatureGateDisplayMode.banner,
      child: Container(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 8.0,
          bottom: MediaQuery.of(context).padding.bottom + 8.0,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4.0,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: textController,
                decoration: InputDecoration(
                  hintText: AppStrings.writeYourMessage,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: 8.0),
            FloatingActionButton(
              onPressed: () {
                final message = textController.text.trim();
                if (message.isNotEmpty) {
                  controller.sendMessage(conversationId, message);
                  textController.clear();
                }
              },
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.send,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
