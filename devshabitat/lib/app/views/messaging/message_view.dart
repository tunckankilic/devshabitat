import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/message/message_chat_controller.dart';
import '../../controllers/message/message_list_controller.dart';
import '../../controllers/message/message_search_controller.dart';
import '../../controllers/message/message_interaction_controller.dart';
import '../../models/conversation_model.dart';
import '../base/base_view.dart';

class MessageView extends BaseView<MessageChatController> {
  final MessageListController listController = Get.find();
  final MessageSearchController searchController = Get.find();
  final MessageInteractionController interactionController = Get.find();

  MessageView({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mesajlar', style: TextStyle(fontSize: 18.sp)),
        actions: [
          IconButton(
            icon: Icon(Icons.search, size: 24.sp),
            onPressed: () {
              // Arama sayfasına git
              Get.toNamed('/message-search');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Konuşma listesi
          Expanded(
            child: Obx(() {
              if (listController.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (listController.conversations.isEmpty) {
                return Center(
                  child: Text(
                    'Henüz bir konuşma yok',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                );
              }

              return ListView.builder(
                itemCount: listController.conversations.length,
                itemBuilder: (context, index) {
                  final conversation = listController.conversations[index];
                  return _buildConversationTile(conversation);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Yeni konuşma başlat
          Get.toNamed('/new-conversation');
        },
        child: Icon(Icons.message, size: 24.sp),
      ),
    );
  }

  Widget _buildConversationTile(ConversationModel conversation) {
    return ListTile(
      leading: CircleAvatar(
        radius: 24.r,
        child: Text(
          (conversation.participantName ?? 'A')[0].toUpperCase(),
          style: TextStyle(fontSize: 16.sp),
        ),
      ),
      title: Text(
        conversation.participantName ?? 'Anonim',
        style: TextStyle(fontSize: 16.sp),
      ),
      subtitle: Text(
        conversation.lastMessage ?? 'Mesaj yok',
        style: TextStyle(fontSize: 14.sp),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(conversation.lastMessageTime),
            style: TextStyle(fontSize: 12.sp),
          ),
          if (conversation.unreadCount > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Theme.of(Get.context!).primaryColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'Yeni',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        // Konuşma detayına git
        Get.toNamed('/chat/${conversation.id}');
      },
      onLongPress: () {
        // Konuşma seçeneklerini göster
        _showConversationOptions(conversation);
      },
    );
  }

  void _showConversationOptions(ConversationModel conversation) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.r),
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
              leading: Icon(Icons.delete, size: 24.sp),
              title: Text(
                'Konuşmayı Sil',
                style: TextStyle(fontSize: 16.sp),
              ),
              onTap: () {
                Get.back();
                _confirmDeleteConversation(conversation);
              },
            ),
            ListTile(
              leading: Icon(Icons.archive, size: 24.sp),
              title: Text(
                'Arşivle',
                style: TextStyle(fontSize: 16.sp),
              ),
              onTap: () {
                Get.back();
                // Arşivleme işlemi
              },
            ),
            ListTile(
              leading: Icon(Icons.block, size: 24.sp),
              title: Text(
                'Engelle',
                style: TextStyle(fontSize: 16.sp),
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
        title: Text(
          'Konuşmayı Sil',
          style: TextStyle(fontSize: 18.sp),
        ),
        content: Text(
          'Bu konuşmayı silmek istediğinize emin misiniz?',
          style: TextStyle(fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'İptal',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              listController.deleteConversation(conversation.id);
            },
            child: Text(
              'Sil',
              style: TextStyle(
                fontSize: 14.sp,
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
