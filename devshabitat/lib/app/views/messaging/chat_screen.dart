import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/messaging_controller.dart';
import '../../widgets/message_bubble.dart';
import '../../models/message_model.dart';

class ChatScreen extends GetView<MessagingController> {
  const ChatScreen({Key? key}) : super(key: key);

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
            conversation?.participantName ?? 'Sohbet',
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
                  child: Text('Henüz mesaj yok'),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  // TODO: Implement pagination
                  await controller.loadMessages(conversationId);
                },
                child: ListView.builder(
                  controller: scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isOwnMessage =
                        message.senderId == controller.currentUserId;

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

    return Container(
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
                hintText: 'Mesajınızı yazın...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
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
    );
  }
}
