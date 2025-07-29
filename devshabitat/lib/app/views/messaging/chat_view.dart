// ignore_for_file: must_be_immutable

import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/message/message_chat_controller.dart';
import '../../controllers/message/message_interaction_controller.dart';
import '../../controllers/thread_controller.dart';
import '../../models/message_model.dart';
import '../base/base_view.dart';
import '../../utils/performance_optimizer.dart';
import '../../repositories/auth_repository.dart';
import '../../widgets/advanced_file_upload.dart';

class ChatView extends BaseView<MessageChatController>
    with PerformanceOptimizer {
  final MessageInteractionController interactionController = Get.find();
  final ThreadController threadController = Get.find<ThreadController>();
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
              return Text(AppStrings.loading,
                  style: TextStyle(
                      fontSize:
                          responsive.responsiveValue(mobile: 18, tablet: 20)));
            }
            return Text(
              conversation.participantName,
              style: TextStyle(
                  fontSize: responsive.responsiveValue(mobile: 18, tablet: 20)),
            );
          }),
          actions: [
            IconButton(
              icon: Icon(Icons.more_vert,
                  size: responsive.responsiveValue(mobile: 24, tablet: 28)),
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
                      AppStrings.noMessages,
                      style: TextStyle(
                          fontSize: responsive.responsiveValue(
                              mobile: 16, tablet: 18)),
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
              padding: EdgeInsets.all(
                  responsive.responsiveValue(mobile: 8, tablet: 12)),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius:
                        responsive.responsiveValue(mobile: 4, tablet: 6),
                    offset: Offset(
                        0, responsive.responsiveValue(mobile: -2, tablet: -3)),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.attach_file,
                          size: responsive.responsiveValue(
                              mobile: 24, tablet: 28)),
                      onPressed: () {
                        _showFileUploadDialog();
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller.messageController,
                        style: TextStyle(
                            fontSize: responsive.responsiveValue(
                                mobile: 16, tablet: 18)),
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: AppStrings.writeYourMessage,
                          hintStyle: TextStyle(
                              fontSize: responsive.responsiveValue(
                                  mobile: 16, tablet: 18)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(responsive
                                .responsiveValue(mobile: 24, tablet: 28)),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: responsive.responsiveValue(
                                mobile: 16, tablet: 20),
                            vertical: responsive.responsiveValue(
                                mobile: 8, tablet: 12),
                          ),
                        ),
                        onChanged: (value) {
                          controller.setTyping(value.isNotEmpty);
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send,
                          size: responsive.responsiveValue(
                              mobile: 24, tablet: 28)),
                      onPressed: () {
                        controller.sendChatMessage();
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
          horizontal: responsive.responsiveValue(mobile: 8, tablet: 12),
          vertical: responsive.responsiveValue(mobile: 4, tablet: 6),
        ),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isMe)
              CircleAvatar(
                radius: responsive.responsiveValue(mobile: 16, tablet: 20),
                child: Text(
                  message.senderId[0].toUpperCase(),
                  style: TextStyle(
                      fontSize:
                          responsive.responsiveValue(mobile: 12, tablet: 14)),
                ),
              ),
            SizedBox(width: responsive.responsiveValue(mobile: 8, tablet: 12)),
            Flexible(
              child: GestureDetector(
                onLongPress: () {
                  _showMessageOptions(message);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        responsive.responsiveValue(mobile: 12, tablet: 16),
                    vertical: responsive.responsiveValue(mobile: 8, tablet: 12),
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? Theme.of(Get.context!).primaryColor
                        : Colors.grey[300],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                          responsive.responsiveValue(mobile: 16, tablet: 20)),
                      topRight: Radius.circular(
                          responsive.responsiveValue(mobile: 16, tablet: 20)),
                      bottomLeft: Radius.circular(isMe
                          ? responsive.responsiveValue(mobile: 16, tablet: 20)
                          : 0),
                      bottomRight: Radius.circular(isMe
                          ? 0
                          : responsive.responsiveValue(mobile: 16, tablet: 20)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.replyToId != null)
                        Container(
                          padding: EdgeInsets.all(responsive.responsiveValue(
                              mobile: 8, tablet: 12)),
                          margin: EdgeInsets.only(
                              bottom: responsive.responsiveValue(
                                  mobile: 8, tablet: 12)),
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(responsive
                                .responsiveValue(mobile: 8, tablet: 12)),
                          ),
                          child: Text(
                            AppStrings.repliedMessage,
                            style: TextStyle(
                              fontSize: responsive.responsiveValue(
                                  mobile: 12, tablet: 14),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      Text(
                        message.content,
                        style: TextStyle(
                          fontSize: responsive.responsiveValue(
                              mobile: 16, tablet: 18),
                          color: isMe ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(
                          height:
                              responsive.responsiveValue(mobile: 4, tablet: 6)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(message.timestamp),
                            style: TextStyle(
                              fontSize: responsive.responsiveValue(
                                  mobile: 12, tablet: 14),
                              color: isMe ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          if (message.isEdited)
                            Text(
                              ' • ${AppStrings.edited}',
                              style: TextStyle(
                                fontSize: responsive.responsiveValue(
                                    mobile: 12, tablet: 14),
                                color: isMe ? Colors.white70 : Colors.black54,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          if (isMe)
                            Icon(
                              message.isRead ? Icons.done_all : Icons.done,
                              size: responsive.responsiveValue(
                                  mobile: 16, tablet: 18),
                              color: Colors.white70,
                            ),
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.forum_outlined,
                              size: responsive.responsiveValue(
                                  mobile: 16, tablet: 18),
                              color: isMe ? Colors.white70 : Colors.black54,
                            ),
                            onPressed: () => _createThreadFromMessage(message),
                            tooltip: 'Thread oluştur',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: responsive.responsiveValue(mobile: 8, tablet: 12)),
            if (isMe)
              CircleAvatar(
                radius: responsive.responsiveValue(mobile: 16, tablet: 20),
                child: Text(
                  message.senderId[0].toUpperCase(),
                  style: TextStyle(
                      fontSize:
                          responsive.responsiveValue(mobile: 12, tablet: 14)),
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
        padding:
            EdgeInsets.all(responsive.responsiveValue(mobile: 16, tablet: 20)),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
                responsive.responsiveValue(mobile: 16, tablet: 20)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMe) ...[
              ListTile(
                leading: Icon(Icons.edit,
                    size: responsive.responsiveValue(mobile: 24, tablet: 28)),
                title: Text(
                  AppStrings.edit,
                  style: TextStyle(
                      fontSize:
                          responsive.responsiveValue(mobile: 16, tablet: 18)),
                ),
                onTap: () {
                  Get.back();
                  interactionController.startEdit(message.id);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete,
                    size: responsive.responsiveValue(mobile: 24, tablet: 28)),
                title: Text(
                  AppStrings.delete,
                  style: TextStyle(
                      fontSize:
                          responsive.responsiveValue(mobile: 16, tablet: 18)),
                ),
                onTap: () {
                  Get.back();
                  _confirmDeleteMessage(message);
                },
              ),
            ],
            ListTile(
              leading: Icon(Icons.reply,
                  size: responsive.responsiveValue(mobile: 24, tablet: 28)),
              title: Text(
                AppStrings.reply,
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 16, tablet: 18)),
              ),
              onTap: () {
                Get.back();
                interactionController.startReply(message.id);
              },
            ),
            ListTile(
              leading: Icon(Icons.forward,
                  size: responsive.responsiveValue(mobile: 24, tablet: 28)),
              title: Text(
                AppStrings.forward,
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 16, tablet: 18)),
              ),
              onTap: () {
                Get.back();
                interactionController.startForward(message.id);
              },
            ),
            ListTile(
              leading: Icon(Icons.content_copy,
                  size: responsive.responsiveValue(mobile: 24, tablet: 28)),
              title: Text(
                AppStrings.copy,
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 16, tablet: 18)),
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
        padding:
            EdgeInsets.all(responsive.responsiveValue(mobile: 16, tablet: 20)),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
                responsive.responsiveValue(mobile: 16, tablet: 20)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.search,
                  size: responsive.responsiveValue(mobile: 24, tablet: 28)),
              title: Text(
                AppStrings.searchMessages,
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 16, tablet: 18)),
              ),
              onTap: () {
                Get.back();
                Get.toNamed('/message-search/$conversationId');
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications_off,
                  size: responsive.responsiveValue(mobile: 24, tablet: 28)),
              title: Text(
                AppStrings.muteNotifications,
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 16, tablet: 18)),
              ),
              onTap: () {
                Get.back();
                // Bildirim ayarları
              },
            ),
            ListTile(
              leading: Icon(Icons.block,
                  size: responsive.responsiveValue(mobile: 24, tablet: 28)),
              title: Text(
                AppStrings.block,
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 16, tablet: 18)),
              ),
              onTap: () {
                Get.back();
                // Engelleme işlemi
              },
            ),
            ListTile(
              leading: Icon(Icons.delete,
                  size: responsive.responsiveValue(mobile: 24, tablet: 28)),
              title: Text(
                AppStrings.deleteConversation,
                style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 16, tablet: 18)),
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
          AppStrings.deleteMessage,
          style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 18, tablet: 20)),
        ),
        content: Text(
          AppStrings.confirmDeleteMessage,
          style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 16, tablet: 18)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(
                  fontSize: responsive.responsiveValue(mobile: 14, tablet: 16)),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteMessage(message.id);
            },
            child: Text(
              AppStrings.delete,
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 14, tablet: 16),
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
          AppStrings.deleteConversation,
          style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 18, tablet: 20)),
        ),
        content: Text(
          AppStrings.confirmDeleteConversation,
          style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 16, tablet: 18)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(
                  fontSize: responsive.responsiveValue(mobile: 14, tablet: 16)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                await controller.deleteConversation(conversationId);
                Get.back(); // Konuşma listesine dön
                Get.snackbar(
                  'Başarılı',
                  'Konuşma silindi',
                  snackPosition: SnackPosition.BOTTOM,
                );
              } catch (e) {
                Get.snackbar(
                  'Hata',
                  'Konuşma silinirken hata oluştu',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: Text(
              AppStrings.delete,
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 14, tablet: 16),
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
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} mins ago';
    } else {
      return AppStrings.now;
    }
  }

  void _showFileUploadDialog() {
    final authService = Get.find<AuthRepository>();
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      Get.snackbar(
        'Hata',
        'Oturum açmanız gerekmektedir',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Dosya Gönder',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 20),
            AdvancedFileUpload(
              userId: currentUser.uid,
              conversationId: conversationId,
              onFilesSelected: (files) {
                // Handle selected files
                print('Selected files for chat: ${files.length}');
              },
              onFileUploaded: (attachment) async {
                // Send file as message
                try {
                  await controller.sendFileMessage(attachment);
                  Get.back();
                } catch (e) {
                  Get.snackbar(
                    'Hata',
                    'Dosya gönderilirken hata oluştu',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              onUploadCancelled: (messageId) {
                // Handle cancelled upload
                print('Cancelled file upload: $messageId');
              },
              customTitle: 'Dosya Seç',
              customSubtitle: 'Resim, video, ses veya belge gönderin',
              allowMultiple: false,
              showPreview: false,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _createThreadFromMessage(MessageModel message) {
    final contentController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Thread Oluştur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bu mesajdan thread oluşturmak istiyor musunuz?'),
            SizedBox(height: 16),
            TextField(
              controller: contentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Thread içeriğini yazın...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              if (contentController.text.isNotEmpty) {
                try {
                  await threadController.createThread(
                      message.id, contentController.text);
                  Get.back();
                  Get.snackbar(
                    'Başarılı',
                    'Thread oluşturuldu',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } catch (e) {
                  Get.snackbar(
                    'Hata',
                    'Thread oluşturulurken hata oluştu',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              }
            },
            child: Text('Oluştur'),
          ),
        ],
      ),
    );
  }
}
