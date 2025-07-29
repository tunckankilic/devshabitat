import 'package:flutter/material.dart';
import '../../models/conversation_model.dart';
import '../../core/theme/dev_habitat_colors.dart';

/// Conversation List Item Widget - Konuşma listesinde her bir öğe için widget
class ConversationListItem extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const ConversationListItem({
    super.key,
    required this.conversation,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isSelected
            ? DevHabitatColors.primary.withOpacity(0.1)
            : DevHabitatColors.lightSurface,
        borderRadius: BorderRadius.circular(12.0),
        border: isSelected
            ? Border.all(color: DevHabitatColors.primary, width: 2.0)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Avatar
                _buildAvatar(),

                const SizedBox(width: 12.0),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and time
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              (conversation.participantName).isNotEmpty
                                  ? conversation.participantName
                                  : 'Unknown User',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: DevHabitatColors.textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            _formatTime(conversation.lastMessageTime),
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4.0),

                      // Last message
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              (conversation.lastMessage ?? '').isNotEmpty
                                  ? conversation.lastMessage ??
                                      'No messages yet'
                                  : 'No messages yet',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: conversation.isRead
                                    ? Colors.grey[600]
                                    : DevHabitatColors.textDark,
                                fontWeight: conversation.isRead
                                    ? FontWeight.normal
                                    : FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Unread count
                          if (conversation.unreadCount > 0) ...[
                            const SizedBox(width: 8.0),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 2.0,
                              ),
                              decoration: BoxDecoration(
                                color: DevHabitatColors.primary,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Text(
                                conversation.unreadCount.toString(),
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 50.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: DevHabitatColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: DevHabitatColors.primary.withOpacity(0.3),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _getInitials(conversation.participantName),
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';

    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else {
      return name[0].toUpperCase();
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${time.day}/${time.month}';
    } else if (difference.inHours > 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
