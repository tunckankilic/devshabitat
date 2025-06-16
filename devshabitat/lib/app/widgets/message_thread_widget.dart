import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/thread_controller.dart';
import '../models/thread_model.dart';
import 'message_attachment_widget.dart';
import 'user_avatar_widget.dart';

class MessageThreadWidget extends StatelessWidget {
  final String threadId;
  final ThreadController controller = Get.find<ThreadController>();
  final TextEditingController _replyController = TextEditingController();

  MessageThreadWidget({
    Key? key,
    required this.threadId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final thread = controller.activeThreads[threadId];
      if (thread == null) return const SizedBox();

      return Column(
        children: [
          _buildThreadHeader(context, thread),
          _buildRepliesList(context, thread),
          _buildReplyInput(context),
        ],
      );
    });
  }

  Widget _buildThreadHeader(BuildContext context, ThreadModel thread) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatarWidget(userId: thread.authorId),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thread.authorName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      thread.createdAt.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showThreadOptions(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            thread.content,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (thread.attachments.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...thread.attachments.map((attachment) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: MessageAttachmentWidget(
                  attachment: attachment,
                  onTap: () => _handleAttachmentTap(attachment),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildRepliesList(BuildContext context, ThreadModel thread) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: thread.replies.length,
        itemBuilder: (context, index) {
          final reply = thread.replies[index];
          return _buildReplyItem(context, reply);
        },
      ),
    );
  }

  Widget _buildReplyItem(BuildContext context, ThreadReply reply) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatarWidget(userId: reply.authorId),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reply.authorName,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      reply.createdAt.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reply.content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (reply.attachments.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...reply.attachments.map((attachment) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: MessageAttachmentWidget(
                  attachment: attachment,
                  onTap: () => _handleAttachmentTap(attachment),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildReplyInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _replyController,
              decoration: const InputDecoration(
                hintText: 'Yanıtınızı yazın...',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _sendReply(context),
          ),
        ],
      ),
    );
  }

  void _showThreadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Thread\'i Sil'),
            onTap: () {
              Navigator.pop(context);
              _deleteThread();
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Bildirimleri Yönet'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement notifications management
            },
          ),
        ],
      ),
    );
  }

  void _handleAttachmentTap(MessageAttachment attachment) {
    // TODO: Implement attachment handling
  }

  void _sendReply(BuildContext context) {
    final content = _replyController.text.trim();
    if (content.isEmpty) return;

    controller.replyToThread(threadId, content);
    _replyController.clear();
  }

  void _deleteThread() {
    Get.dialog(
      AlertDialog(
        title: const Text('Thread\'i Sil'),
        content: const Text('Bu thread\'i silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteThread(threadId);
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
