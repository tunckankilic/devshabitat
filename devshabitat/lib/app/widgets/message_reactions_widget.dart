import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/message_interaction_controller.dart';
import 'emoji_picker_widget.dart';

class MessageReactionsWidget extends StatelessWidget {
  final String messageId;
  final String conversationId;
  final String currentUserId;
  final bool isMyMessage;

  const MessageReactionsWidget({
    Key? key,
    required this.messageId,
    required this.conversationId,
    required this.currentUserId,
    required this.isMyMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageInteractionController>();

    return Obx(() {
      final reactions = controller.getReactionsForMessage(messageId);
      if (reactions.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: EdgeInsets.only(
          left: isMyMessage ? 0 : 8,
          right: isMyMessage ? 8 : 0,
          top: 4,
        ),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: reactions.entries.map((entry) {
            final emoji = entry.key;
            final users = entry.value;
            final hasReacted = users.contains(currentUserId);

            return InkWell(
              onTap: () {
                if (hasReacted) {
                  controller.removeReaction(
                    messageId,
                    emoji,
                    currentUserId,
                    conversationId: conversationId,
                  );
                } else {
                  controller.addReaction(
                    messageId,
                    emoji,
                    currentUserId,
                    conversationId: conversationId,
                  );
                }
              },
              onLongPress: () {
                _showReactionUsers(context, users, emoji);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hasReacted
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      emoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      users.length.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: hasReacted
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  void _showReactionUsers(
      BuildContext context, List<String> users, String emoji) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Reacted with $emoji',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...users.map(
              (userId) => ListTile(
                title: Text(userId), // TODO: Replace with actual user name
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
