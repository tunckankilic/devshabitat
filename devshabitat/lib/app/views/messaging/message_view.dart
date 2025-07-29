import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:devshabitat/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/message/message_chat_controller.dart';
import '../../controllers/message/message_list_controller.dart';
import '../../controllers/message/message_search_controller.dart';
import '../../controllers/message/message_interaction_controller.dart';
import '../../controllers/chat_management_controller.dart';
import '../../models/conversation_model.dart';
import '../base/base_view.dart';
import '../../widgets/adaptive_touch_target.dart';
import '../../widgets/responsive/responsive_safe_area.dart';
import '../../widgets/responsive/responsive_text.dart';
import '../../widgets/responsive/animated_responsive_layout.dart';

class MessageView extends BaseView<MessageChatController> {
  final MessageListController listController = Get.find();
  final MessageSearchController searchController = Get.find();
  final MessageInteractionController interactionController = Get.find();
  final ChatManagementController managementController = Get.find();

  MessageView({super.key});

  @override
  Widget buildView(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: ResponsiveText(
            AppStrings.messages,
            style: TextStyle(
              fontSize: responsive.responsiveValue(
                mobile: 18,
                tablet: 22,
              ),
            ),
          ),
          actions: [
            AdaptiveTouchTarget(
              onTap: () => Get.toNamed(AppRoutes.search),
              child: Icon(
                Icons.search,
                size: responsive.responsiveValue(mobile: 24, tablet: 32),
              ),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                text: AppStrings.messages,
                icon: Icon(
                  Icons.message,
                  size: responsive.responsiveValue(mobile: 24, tablet: 32),
                ),
              ),
              Tab(
                text: AppStrings.chatManagement,
                icon: Icon(
                  Icons.settings,
                  size: responsive.responsiveValue(mobile: 24, tablet: 32),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMessagesTab(),
            _buildManagementTab(),
          ],
        ),
        floatingActionButton: AdaptiveTouchTarget(
          onTap: () => Get.toNamed(AppRoutes.NEW_CHAT),
          child: Icon(
            Icons.message,
            size: responsive.responsiveValue(mobile: 24, tablet: 32),
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesTab() {
    return ResponsiveSafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Obx(() {
              if (listController.isLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: responsive.responsiveValue(
                      mobile: 2,
                      tablet: 3,
                    ),
                  ),
                );
              }

              if (listController.conversations.isEmpty) {
                return Center(
                  child: ResponsiveText(
                    AppStrings.noChats,
                    style: TextStyle(
                      fontSize: responsive.responsiveValue(
                        mobile: 16,
                        tablet: 18,
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
    );
  }

  Widget _buildManagementTab() {
    return ResponsiveSafeArea(
      child: Column(
        children: [
          _buildMemoryUsageCard(),
          Expanded(
            child: _buildManagementOptions(),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryUsageCard() {
    return Obx(() {
      return Card(
        margin: responsive.responsivePadding(all: 16),
        child: Padding(
          padding: responsive.responsivePadding(all: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveText(
                AppStrings.memoryUsage,
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 16,
                    tablet: 18,
                  ),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: managementController.memoryUsage / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  managementController.memoryUsage > 80
                      ? Colors.red
                      : Colors.blue,
                ),
              ),
              const SizedBox(height: 4),
              ResponsiveText(
                '${managementController.memoryUsage.toStringAsFixed(2)} MB',
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 14,
                    tablet: 16,
                  ),
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildManagementOptions() {
    return ListView(
      padding: responsive.responsivePadding(all: 16),
      children: [
        _buildManagementTile(
          icon: Icons.archive,
          title: AppStrings.archiveChats,
          subtitle: AppStrings.archiveChatsDesc,
          onTap: () => _showArchiveDialog(),
        ),
        _buildManagementTile(
          icon: Icons.import_export,
          title: AppStrings.exportChats,
          subtitle: AppStrings.exportChatsDesc,
          onTap: () => _showExportDialog(),
        ),
        _buildManagementTile(
          icon: Icons.delete_forever,
          title: AppStrings.deleteChats,
          subtitle: AppStrings.deleteChatsDesc,
          onTap: () => _showDeleteDialog(),
        ),
      ],
    );
  }

  Widget _buildManagementTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: responsive.responsivePadding(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          size: responsive.responsiveValue(mobile: 24, tablet: 32),
          color: Theme.of(Get.context!).primaryColor,
        ),
        title: ResponsiveText(
          title,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 16,
              tablet: 18,
            ),
          ),
        ),
        subtitle: ResponsiveText(
          subtitle,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 14,
              tablet: 16,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showArchiveDialog() {
    Get.dialog(
      AlertDialog(
        title: ResponsiveText(AppStrings.confirmArchive),
        content: ResponsiveText(AppStrings.archiveChatsDesc),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: ResponsiveText(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                await managementController.archiveChat(
                  listController.selectedConversation.value?.id ?? '',
                );
                Get.snackbar(
                  AppStrings.success,
                  AppStrings.chatArchived,
                  snackPosition: SnackPosition.BOTTOM,
                );
              } catch (e) {
                Get.snackbar(
                  AppStrings.error,
                  AppStrings.operationFailed,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: ResponsiveText(AppStrings.archive),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    Get.dialog(
      AlertDialog(
        title: ResponsiveText(AppStrings.confirmExport),
        content: ResponsiveText(AppStrings.exportChatsDesc),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: ResponsiveText(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                await managementController.exportChat(
                  listController.selectedConversation.value?.id ?? '',
                );
                Get.snackbar(
                  AppStrings.success,
                  AppStrings.chatExported,
                  snackPosition: SnackPosition.BOTTOM,
                );
              } catch (e) {
                Get.snackbar(
                  AppStrings.error,
                  AppStrings.operationFailed,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: ResponsiveText(AppStrings.export),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    Get.dialog(
      AlertDialog(
        title: ResponsiveText(AppStrings.confirmDelete),
        content: ResponsiveText(AppStrings.deleteChatsDesc),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: ResponsiveText(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                await managementController.deleteChat(
                  listController.selectedConversation.value?.id ?? '',
                );
                Get.snackbar(
                  AppStrings.success,
                  AppStrings.chatDeleted,
                  snackPosition: SnackPosition.BOTTOM,
                );
              } catch (e) {
                Get.snackbar(
                  AppStrings.error,
                  AppStrings.operationFailed,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: ResponsiveText(AppStrings.delete),
          ),
        ],
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
        childAspectRatio: responsive.responsiveValue(mobile: 4, tablet: 4),
        crossAxisSpacing: responsive.responsiveValue(mobile: 24, tablet: 32),
        mainAxisSpacing: responsive.responsiveValue(mobile: 24, tablet: 32),
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
        selected:
            listController.selectedConversation.value?.id == conversation.id,
        onTap: () {
          listController.selectConversation(conversation);
          Get.toNamed('/chat/${conversation.id}');
        },
        onLongPress: () {
          listController.selectConversation(conversation);
          _showConversationOptions(conversation);
        },
        leading: CircleAvatar(
          radius: responsive.responsiveValue(
            mobile: 24,
            tablet: 32,
          ),
          child: ResponsiveText(
            (conversation.participantName)[0].toUpperCase(),
            style: TextStyle(
              fontSize: responsive.responsiveValue(
                mobile: 16,
                tablet: 20,
              ),
            ),
          ),
        ),
        title: ResponsiveText(
          conversation.participantName,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 16,
              tablet: 18,
            ),
          ),
        ),
        subtitle: ResponsiveText(
          conversation.lastMessage ?? AppStrings.noMessages,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 14,
              tablet: 16,
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
                  mobile: 12,
                  tablet: 14,
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
                  borderRadius: BorderRadius.circular(
                    responsive.responsiveValue(mobile: 12, tablet: 16),
                  ),
                ),
                child: ResponsiveText(
                  AppStrings.newMessages,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.responsiveValue(
                      mobile: 12,
                      tablet: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
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
            top: Radius.circular(
              responsive.responsiveValue(mobile: 16, tablet: 20),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.delete,
                size: responsive.responsiveValue(mobile: 24, tablet: 32),
              ),
              title: ResponsiveText(
                AppStrings.deleteConversation,
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 16,
                    tablet: 18,
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
                size: responsive.responsiveValue(mobile: 24, tablet: 32),
              ),
              title: ResponsiveText(
                AppStrings.archive,
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 16,
                    tablet: 18,
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
                size: responsive.responsiveValue(mobile: 24, tablet: 32),
              ),
              title: ResponsiveText(
                AppStrings.block,
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 16,
                    tablet: 18,
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
          AppStrings.deleteConversation,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 18,
              tablet: 20,
            ),
          ),
        ),
        content: ResponsiveText(
          AppStrings.confirmDeleteConversation,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 16,
              tablet: 18,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: ResponsiveText(
              AppStrings.cancel,
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 14,
                  tablet: 16,
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
              AppStrings.delete,
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 14,
                  tablet: 16,
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
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} mins ago';
    } else {
      return AppStrings.now;
    }
  }
}
