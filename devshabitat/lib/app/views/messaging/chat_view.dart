import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/message/message_chat_controller.dart';
import '../../controllers/message/message_interaction_controller.dart';
import '../../models/message_model.dart';
import '../base/base_view.dart';
import '../../utils/performance_optimizer.dart';
import '../../repositories/auth_repository.dart';

class ChatView extends BaseView<MessageChatController>
    with PerformanceOptimizer {
  final MessageInteractionController interactionController = Get.find();
  final String conversationId = Get.parameters['id']!;

  ChatView({super.key});

  @override
  Widget buildView(BuildContext context) {
    controller.loadMessages(conversationId);
    return optimizeWidgetTree(
      Scaffold(
        appBar: AppBar(
          title: Obx(() {
            final conversation = controller.currentConversation.value;
            if (conversation == null) {
              return Text('Yükleniyor...', style: TextStyle(fontSize: 18.sp));
            }
            return Text(
              conversation.participantName,
              style: TextStyle(fontSize: 18.sp),
            );
          }),
          actions: [
            IconButton(
              icon: Icon(Icons.more_vert, size: 24.sp),
              onPressed: () {
                _showChatOptions();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Mesaj listesi
            Expanded(
              child: Obx(() {
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.messages.isEmpty) {
                  return Center(
                    child: Text(
                      'Henüz mesaj yok',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  );
                }

                return ListView.builder(
                  controller: controller.scrollController,
                  reverse: true,
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    return _buildMessageTile(message);
                  },
                );
              }),
            ),

            // Mesaj yazma alanı
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4.r,
                    offset: Offset(0, -2.h),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.attach_file, size: 24.sp),
                      onPressed: () {
                        // Dosya ekleme
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller.messageController,
                        style: TextStyle(fontSize: 16.sp),
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Mesaj yazın...',
                          hintStyle: TextStyle(fontSize: 16.sp),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.r),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                        ),
                        onChanged: (value) {
                          controller.updateTypingStatus(value.isNotEmpty);
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, size: 24.sp),
                      onPressed: () {
                        controller.sendMessage();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageTile(MessageModel message) {
    final authService = Get.find<AuthRepository>();
    final isMe = message.senderId == authService.currentUser?.uid;

    return wrapWithRepaintBoundary(
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 8.w,
          vertical: 4.h,
        ),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isMe)
              CircleAvatar(
                radius: 16.r,
                child: Text(
                  message.senderId[0].toUpperCase(),
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
            SizedBox(width: 8.w),
            Flexible(
              child: GestureDetector(
                onLongPress: () {
                  _showMessageOptions(message);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? Theme.of(Get.context!).primaryColor
                        : Colors.grey[300],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                      bottomLeft: Radius.circular(isMe ? 16.r : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 16.r),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.replyToId != null)
                        Container(
                          padding: EdgeInsets.all(8.r),
                          margin: EdgeInsets.only(bottom: 8.h),
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'Yanıtlanan mesaj',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      Text(
                        message.content,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: isMe ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(message.timestamp),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isMe ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          if (message.isEdited)
                            Text(
                              ' • düzenlendi',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: isMe ? Colors.white70 : Colors.black54,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          if (isMe)
                            Icon(
                              message.isRead ? Icons.done_all : Icons.done,
                              size: 16.sp,
                              color: Colors.white70,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            if (isMe)
              CircleAvatar(
                radius: 16.r,
                child: Text(
                  message.senderId[0].toUpperCase(),
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showMessageOptions(MessageModel message) {
    final authService = Get.find<AuthRepository>();
    final isMe = message.senderId == authService.currentUser?.uid;

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
            if (isMe) ...[
              ListTile(
                leading: Icon(Icons.edit, size: 24.sp),
                title: Text(
                  'Düzenle',
                  style: TextStyle(fontSize: 16.sp),
                ),
                onTap: () {
                  Get.back();
                  interactionController.startEdit(message.id);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, size: 24.sp),
                title: Text(
                  'Sil',
                  style: TextStyle(fontSize: 16.sp),
                ),
                onTap: () {
                  Get.back();
                  _confirmDeleteMessage(message);
                },
              ),
            ],
            ListTile(
              leading: Icon(Icons.reply, size: 24.sp),
              title: Text(
                'Yanıtla',
                style: TextStyle(fontSize: 16.sp),
              ),
              onTap: () {
                Get.back();
                interactionController.startReply(message.id);
              },
            ),
            ListTile(
              leading: Icon(Icons.forward, size: 24.sp),
              title: Text(
                'İlet',
                style: TextStyle(fontSize: 16.sp),
              ),
              onTap: () {
                Get.back();
                interactionController.startForward(message.id);
              },
            ),
            ListTile(
              leading: Icon(Icons.content_copy, size: 24.sp),
              title: Text(
                'Kopyala',
                style: TextStyle(fontSize: 16.sp),
              ),
              onTap: () {
                Get.back();
                // Kopyalama işlemi
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChatOptions() {
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
              leading: Icon(Icons.search, size: 24.sp),
              title: Text(
                'Mesajlarda Ara',
                style: TextStyle(fontSize: 16.sp),
              ),
              onTap: () {
                Get.back();
                Get.toNamed('/message-search/$conversationId');
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications_off, size: 24.sp),
              title: Text(
                'Bildirimleri Sustur',
                style: TextStyle(fontSize: 16.sp),
              ),
              onTap: () {
                Get.back();
                // Bildirim ayarları
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
            ListTile(
              leading: Icon(Icons.delete, size: 24.sp),
              title: Text(
                'Konuşmayı Sil',
                style: TextStyle(fontSize: 16.sp),
              ),
              onTap: () {
                Get.back();
                _confirmDeleteConversation();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteMessage(MessageModel message) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Mesajı Sil',
          style: TextStyle(fontSize: 18.sp),
        ),
        content: Text(
          'Bu mesajı silmek istediğinize emin misiniz?',
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
              controller.deleteMessage(message.id);
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

  void _confirmDeleteConversation() {
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
              Get.back(); // Konuşma listesine dön
              controller.deleteConversation(conversationId);
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
