import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/message/message_chat_controller.dart';
import '../../controllers/message/message_list_controller.dart';
import '../../controllers/message/message_search_controller.dart';
import '../../controllers/message/message_interaction_controller.dart';
import '../../models/conversation_model.dart';
import '../base/base_view.dart';
import '../../widgets/adaptive_touch_target.dart';
import '../../widgets/responsive/responsive_safe_area.dart';
import '../../widgets/responsive/responsive_text.dart';
import '../../widgets/responsive/responsive_overflow_handler.dart'
    hide ResponsiveText, ResponsiveSafeArea;
import '../../widgets/responsive/animated_responsive_layout.dart';

class MessageView extends BaseView<MessageChatController> {
  final MessageListController listController = Get.find();
  final MessageSearchController searchController = Get.find();
  final MessageInteractionController interactionController = Get.find();

  MessageView({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText(
          'Mesajlar',
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 18.sp,
              tablet: 22.sp,
            ),
          ),
        ),
        actions: [
          AdaptiveTouchTarget(
            onTap: () => Get.toNamed('/message-search'),
            child: Icon(
              Icons.search,
              size: responsive.minTouchTarget.sp,
            ),
          ),
        ],
      ),
      body: ResponsiveSafeArea(
        child: ResponsiveOverflowHandler(
          child: Column(
            children: [
              Expanded(
                child: Obx(() {
                  if (listController.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: responsive.responsiveValue(
                          mobile: 2.w,
                          tablet: 3.w,
                        ),
                      ),
                    );
                  }

                  if (listController.conversations.isEmpty) {
                    return Center(
                      child: ResponsiveText(
                        'Henüz bir konuşma yok',
                        style: TextStyle(
                          fontSize: responsive.responsiveValue(
                            mobile: 16.sp,
                            tablet: 18.sp,
                          ),
                        ),
                      ),
                    );
                  }

                  return AnimatedResponsiveLayout(
                    mobile: _buildMobileConversationList(),
                    tablet: _buildTabletConversationList(),
                    animationDuration: const Duration(milliseconds: 300),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: AdaptiveTouchTarget(
        onTap: () => Get.toNamed('/new-conversation'),
        child: Icon(
          Icons.message,
          size: responsive.minTouchTarget.sp,
        ),
      ),
    );
  }

  Widget _buildMobileConversationList() {
    return ListView.builder(
      padding: responsive.responsivePadding(all: 16),
      itemCount: listController.conversations.length,
      itemBuilder: (context, index) {
        final conversation = listController.conversations[index];
        return _buildConversationTile(conversation);
      },
    );
  }

  Widget _buildTabletConversationList() {
    return GridView.builder(
      padding: responsive.responsivePadding(all: 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 4.w,
        crossAxisSpacing: 24.w,
        mainAxisSpacing: 24.h,
      ),
      itemCount: listController.conversations.length,
      itemBuilder: (context, index) {
        final conversation = listController.conversations[index];
        return _buildConversationTile(conversation);
      },
    );
  }

  Widget _buildConversationTile(ConversationModel conversation) {
    return Card(
      margin: responsive.responsivePadding(
        bottom: responsive.responsiveValue(
          mobile: 8,
          tablet: 12,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: responsive.responsiveValue(
            mobile: 24.r,
            tablet: 32.r,
          ),
          child: ResponsiveText(
            (conversation.participantName)[0].toUpperCase(),
            style: TextStyle(
              fontSize: responsive.responsiveValue(
                mobile: 16.sp,
                tablet: 20.sp,
              ),
            ),
          ),
        ),
        title: ResponsiveText(
          conversation.participantName,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 16.sp,
              tablet: 18.sp,
            ),
          ),
        ),
        subtitle: ResponsiveText(
          conversation.lastMessage ?? 'Mesaj yok',
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 14.sp,
              tablet: 16.sp,
            ),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ResponsiveText(
              _formatTime(conversation.lastMessageTime),
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 12.sp,
                  tablet: 14.sp,
                ),
              ),
            ),
            if (conversation.unreadCount > 0)
              Container(
                padding: responsive.responsivePadding(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(Get.context!).primaryColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: ResponsiveText(
                  'Yeni',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.responsiveValue(
                      mobile: 12.sp,
                      tablet: 14.sp,
                    ),
                  ),
                ),
              ),
          ],
        ),
        onTap: () => Get.toNamed('/chat/${conversation.id}'),
        onLongPress: () => _showConversationOptions(conversation),
      ),
    );
  }

  void _showConversationOptions(ConversationModel conversation) {
    Get.bottomSheet(
      Container(
        padding: responsive.responsivePadding(all: 16),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.delete,
                size: responsive.minTouchTarget.sp,
              ),
              title: ResponsiveText(
                'Konuşmayı Sil',
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 16.sp,
                    tablet: 18.sp,
                  ),
                ),
              ),
              onTap: () {
                Get.back();
                _confirmDeleteConversation(conversation);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.archive,
                size: responsive.minTouchTarget.sp,
              ),
              title: ResponsiveText(
                'Arşivle',
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 16.sp,
                    tablet: 18.sp,
                  ),
                ),
              ),
              onTap: () {
                Get.back();
                // Arşivleme işlemi
              },
            ),
            ListTile(
              leading: Icon(
                Icons.block,
                size: responsive.minTouchTarget.sp,
              ),
              title: ResponsiveText(
                'Engelle',
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 16.sp,
                    tablet: 18.sp,
                  ),
                ),
              ),
              onTap: () {
                Get.back();
                // Engelleme işlemi
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteConversation(ConversationModel conversation) {
    Get.dialog(
      AlertDialog(
        title: ResponsiveText(
          'Konuşmayı Sil',
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 18.sp,
              tablet: 20.sp,
            ),
          ),
        ),
        content: ResponsiveText(
          'Bu konuşmayı silmek istediğinize emin misiniz?',
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 16.sp,
              tablet: 18.sp,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: ResponsiveText(
              'İptal',
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 14.sp,
                  tablet: 16.sp,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              listController.deleteConversation(conversation.id);
            },
            child: ResponsiveText(
              'Sil',
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 14.sp,
                  tablet: 16.sp,
                ),
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
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
      return '${difference.inMinutes} dk önce';
    } else {
      return 'Şimdi';
    }
  }
}
