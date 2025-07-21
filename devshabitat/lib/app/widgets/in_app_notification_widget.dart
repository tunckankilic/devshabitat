import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class InAppNotificationWidget extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const InAppNotificationWidget({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => onDismiss?.call(),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: _buildNotificationIcon(),
            title: Text(
              notification.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _getTimeAgo(notification.createdAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: !notification.isRead
                ? Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    IconData iconData;
    Color iconColor;

    // Bildirim tipine göre icon ve renk belirle
    switch (notification.data?['type']) {
      case AppStrings.message:
        iconData = Icons.message;
        iconColor = Colors.blue;
        break;
      case AppStrings.event:
        iconData = Icons.event;
        iconColor = Colors.green;
        break;
      case AppStrings.community:
        iconData = Icons.group;
        iconColor = Colors.purple;
        break;
      case AppStrings.connection:
        iconData = Icons.person_add;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.1),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return AppStrings.dateTimeFormat(dateTime);
    } else if (difference.inDays > 0) {
      return AppStrings.daysAgo(difference.inDays);
    } else if (difference.inHours > 0) {
      return AppStrings.hoursAgo(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return AppStrings.minutesAgo(difference.inMinutes);
    } else {
      return AppStrings.justNow;
    }
  }
}
