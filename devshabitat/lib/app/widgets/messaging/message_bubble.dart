import 'package:flutter/material.dart';
import '../../models/message_model.dart';
import '../../core/theme/dev_habitat_colors.dart';

/// Message Bubble Widget - Mesajları görüntülemek için kullanılan widget
class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isOwnMessage;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showTimestamp;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isOwnMessage,
    this.onTap,
    this.onLongPress,
    this.showTimestamp = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment:
            isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Message content
          GestureDetector(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: isOwnMessage
                    ? DevHabitatColors.primary
                    : DevHabitatColors.lightSurface,
                borderRadius: BorderRadius.circular(18.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildMessageContent(),
            ),
          ),

          // Timestamp
          if (showTimestamp) ...[
            const SizedBox(height: 4.0),
            Padding(
              padding: EdgeInsets.only(
                left: isOwnMessage ? 0 : 16.0,
                right: isOwnMessage ? 16.0 : 0,
              ),
              child: Text(
                _formatTimestamp(message.timestamp),
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: TextStyle(
            color: isOwnMessage ? Colors.white : Colors.black87,
            fontSize: 16.0,
          ),
        );

      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  message.content,
                  style: TextStyle(
                    color: isOwnMessage ? Colors.white : Colors.black87,
                    fontSize: 16.0,
                  ),
                ),
              ),
            if (message.mediaUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  message.mediaUrl!,
                  width: 200,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
          ],
        );

      case MessageType.document:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.description,
              color: isOwnMessage ? Colors.white70 : Colors.grey[600],
            ),
            const SizedBox(width: 8.0),
            Flexible(
              child: Text(
                message.content.isNotEmpty ? message.content : 'Document',
                style: TextStyle(
                  color: isOwnMessage ? Colors.white : Colors.black87,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        );

      case MessageType.link:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  message.content,
                  style: TextStyle(
                    color: isOwnMessage ? Colors.white : Colors.black87,
                    fontSize: 16.0,
                  ),
                ),
              ),
            if (message.links.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: isOwnMessage
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.link,
                      color: isOwnMessage ? Colors.white70 : Colors.blue,
                      size: 16.0,
                    ),
                    const SizedBox(width: 4.0),
                    Flexible(
                      child: Text(
                        message.links.first,
                        style: TextStyle(
                          color: isOwnMessage ? Colors.white70 : Colors.blue,
                          fontSize: 14.0,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );

      default:
        return Text(
          message.content,
          style: TextStyle(
            color: isOwnMessage ? Colors.white : Colors.black87,
            fontSize: 16.0,
          ),
        );
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inHours > 0) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
