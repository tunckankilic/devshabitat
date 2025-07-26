import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../base/base_view.dart';
import '../../widgets/responsive/responsive_text.dart';
import '../../widgets/responsive/animated_responsive_layout.dart';

class NotificationsView extends BaseView<HomeController> {
  const NotificationsView({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      body: AnimatedResponsiveLayout(
        mobile: _buildMobileNotifications(context),
        tablet: _buildTabletNotifications(context),
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildMobileNotifications(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.loadNotifications();
      },
      color: Theme.of(context).primaryColor,
      child: CustomScrollView(
        slivers: [
          _buildModernAppBar(context),
          SliverToBoxAdapter(
            child: Obx(() {
              if (controller.notifications.isEmpty) {
                return _buildEmptyState(context);
              }
              return SizedBox.shrink();
            }),
          ),
          Obx(() => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final notification = controller.notifications[index];
                    return Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child:
                          _buildModernNotificationCard(notification, context),
                    );
                  },
                  childCount: controller.notifications.length,
                ),
              )),
          SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletNotifications(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.loadNotifications();
      },
      color: Theme.of(context).primaryColor,
      child: CustomScrollView(
        slivers: [
          _buildModernAppBar(context),
          SliverToBoxAdapter(
            child: Obx(() {
              if (controller.notifications.isEmpty) {
                return _buildEmptyState(context);
              }
              return SizedBox.shrink();
            }),
          ),
          Obx(() => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final notification = controller.notifications[index];
                    return Center(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 800),
                        padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
                        child:
                            _buildModernNotificationCard(notification, context),
                      ),
                    );
                  },
                  childCount: controller.notifications.length,
                ),
              )),
          SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          title: ResponsiveText(
            AppStrings.notifications,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Obx(
            () => controller.notifications.isNotEmpty
                ? IconButton(
                    onPressed: () => _showMarkAllDialog(context),
                    icon: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(64),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 24),
          ResponsiveText(
            'Bildirim Yok',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          ResponsiveText(
            'Henüz hiç bildiriminiz bulunmuyor.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernNotificationCard(
      dynamic notification, BuildContext context) {
    final isUnread = notification.isRead != true;

    return Card(
      elevation: isUnread ? 8 : 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: isUnread
              ? Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  width: 1)
              : null,
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(20),
          leading: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isUnread
                    ? [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ]
                    : [
                        Colors.grey[300]!,
                        Colors.grey[400]!,
                      ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getNotificationIcon(notification.type),
              color: isUnread ? Colors.white : Colors.grey[600],
              size: 24,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: ResponsiveText(
                  notification.title ?? 'Bildirim',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              if (isUnread)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ResponsiveText(
                    'Yeni',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              ResponsiveText(
                notification.body ?? 'Bildirim içeriği',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ResponsiveText(
                      _formatTime(notification.createdAt ?? DateTime.now()),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isUnread)
                    IconButton(
                      onPressed: () {
                        controller.markNotificationAsRead(notification.id);
                      },
                      icon: Icon(
                        Icons.check_circle_outline,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
          ),
          onTap: () {
            if (isUnread) {
              controller.markNotificationAsRead(notification.id);
            }
            // Bildirim detayına git
            _handleNotificationTap(notification);
          },
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'message':
        return Icons.message_outlined;
      case 'event':
        return Icons.event_outlined;
      case 'community':
        return Icons.group_outlined;
      case 'system':
        return Icons.settings_outlined;
      case 'update':
        return Icons.system_update_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 7) {
      return '${time.day}/${time.month}/${time.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Şimdi';
    }
  }

  void _handleNotificationTap(dynamic notification) {
    // Bildirim tipine göre navigasyon
    switch (notification.type) {
      case 'message':
        Get.toNamed('/chat/${notification.relatedId}');
        break;
      case 'event':
        Get.toNamed('/event-detail/${notification.relatedId}');
        break;
      case 'community':
        Get.toNamed('/community-detail/${notification.relatedId}');
        break;
      default:
        // Genel bildirim detayı
        break;
    }
  }

  void _showMarkAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.check_circle_outline,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            ResponsiveText(
              'Tümünü Okundu İşaretle',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: ResponsiveText(
          'Tüm bildirimleri okundu olarak işaretlemek istediğinizden emin misiniz?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: ResponsiveText(
              'İptal',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.markAllNotificationsAsRead();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: ResponsiveText(
              'Okundu İşaretle',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        contentPadding: EdgeInsets.all(20),
        actionsPadding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      ),
    );
  }
}
