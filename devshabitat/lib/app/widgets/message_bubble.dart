import 'package:flutter/material.dart';
import '../models/message_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isOwnMessage;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isOwnMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Card(
          color: isOwnMessage
              ? colorScheme.primaryContainer
              : colorScheme.surfaceVariant,
          elevation: 0,
          margin: EdgeInsets.only(
            left: isOwnMessage ? 64.0 : 16.0,
            right: isOwnMessage ? 16.0 : 64.0,
            top: 4.0,
            bottom: 4.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: TextStyle(
                    color: isOwnMessage
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeago.format(message.timestamp, locale: 'tr'),
                      style: TextStyle(
                        color: isOwnMessage
                            ? colorScheme.onPrimaryContainer.withOpacity(0.7)
                            : colorScheme.onSurfaceVariant.withOpacity(0.7),
                        fontSize: 12.0,
                      ),
                    ),
                    if (isOwnMessage) ...[
                      const SizedBox(width: 4.0),
                      Icon(
                        message.status == MessageStatus.sent
                            ? Icons.check
                            : Icons.check_circle,
                        size: 14.0,
                        color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
