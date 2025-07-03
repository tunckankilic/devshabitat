import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/messaging_controller.dart';
import '../../widgets/conversation_tile.dart';
import '../../routes/app_pages.dart';

class ChatListScreen extends GetView<MessagingController> {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => controller.searchQuery.isEmpty
            ? Text('Mesajlar', style: theme.textTheme.titleLarge)
            : TextField(
                controller:
                    TextEditingController(text: controller.searchQuery.value),
                onChanged: (value) => controller.searchQuery.value = value,
                decoration: InputDecoration(
                  hintText: 'Ara...',
                  border: InputBorder.none,
                  hintStyle:
                      TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
                style: theme.textTheme.titleLarge,
              )),
        actions: [
          IconButton(
            icon: Obx(() => Icon(
                  controller.searchQuery.isEmpty ? Icons.search : Icons.close,
                )),
            onPressed: () {
              if (controller.searchQuery.isEmpty) {
                controller.searchQuery.value = ' '; // Trigger search mode
              } else {
                controller.searchQuery.value = ''; // Clear search
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.loadConversations();
        },
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.errorMessage.value,
                    style: TextStyle(color: theme.colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: controller.loadConversations,
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          if (controller.conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz sohbet bulunmuyor',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Yeni bir sohbet başlatmak için + butonuna tıklayın',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: controller.conversations.length,
            itemBuilder: (context, index) {
              final conversation = controller.conversations[index];
              return ConversationTile(
                conversation: conversation,
                onTap: () {
                  controller.selectConversation(conversation);
                  Get.toNamed(AppRoutes.CHAT, arguments: conversation);
                },
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.NEW_CHAT),
        child: const Icon(Icons.add),
      ),
    );
  }
}
