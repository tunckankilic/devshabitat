import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/comments_controller.dart';
import '../../controllers/responsive_controller.dart';
import '../../models/comment_model.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/responsive/responsive_wrapper.dart';

class CommentsView extends GetView<CommentsController> {
  final String postId;
  final String postTitle;

  const CommentsView({
    super.key,
    required this.postId,
    required this.postTitle,
  });

  @override
  Widget build(BuildContext context) {
    // PostId'yi controller'a aktar
    controller.setPostId(postId);
    
    return ResponsiveWrapper(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yorumlar'),
        backgroundColor: Get.theme.colorScheme.surface,
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildCommentInput(),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yorumlar'),
        backgroundColor: Get.theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: _buildBody(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: _buildCommentInput(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yorumlar'),
        backgroundColor: Get.theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _buildBody(),
        ),
      ),
      bottomNavigationBar: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _buildCommentInput(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildPostHeader(),
        Expanded(child: _buildCommentsList()),
      ],
    );
  }

  Widget _buildPostHeader() {
    final responsive = Get.find<ResponsiveController>();
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Get.theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            postTitle,
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
            '${controller.comments.length} yorum',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: LoadingWidget());
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return _buildErrorState();
      }

      if (controller.comments.isEmpty) {
        return _buildEmptyState();
      }

      return _buildCommentsListView();
    });
  }

  Widget _buildCommentsListView() {
    final responsive = Get.find<ResponsiveController>();
    
    return ListView.builder(
      controller: controller.scrollController,
      padding: EdgeInsets.all(responsive.isMobile ? 16 : 24),
      itemCount: controller.comments.length,
      itemBuilder: (context, index) {
        final comment = controller.comments[index];
        return _buildCommentTile(comment);
      },
    );
  }

  Widget _buildCommentTile(CommentModel comment) {
    final responsive = Get.find<ResponsiveController>();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(responsive.isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Get.theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCommentHeader(comment),
          const SizedBox(height: 8),
          _buildCommentContent(comment),
          const SizedBox(height: 12),
          _buildCommentActions(comment),
        ],
      ),
    );
  }

  Widget _buildCommentHeader(CommentModel comment) {
    final responsive = Get.find<ResponsiveController>();
    
    return Row(
      children: [
        CircleAvatar(
          radius: responsive.isMobile ? 16 : 20,
          backgroundImage: comment.authorPhotoUrl != null
              ? NetworkImage(comment.authorPhotoUrl!)
              : null,
          child: comment.authorPhotoUrl == null
              ? Icon(
                  Icons.person,
                  size: responsive.isMobile ? 16 : 20,
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.authorName,
                style: Get.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatDate(comment.createdAt),
                style: Get.textTheme.bodySmall?.copyWith(
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        if (comment.isEdited)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Düzenlendi',
              style: Get.textTheme.bodySmall?.copyWith(
                color: Get.theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCommentContent(CommentModel comment) {
    return Text(
      comment.content,
      style: Get.textTheme.bodyMedium,
    );
  }

  Widget _buildCommentActions(CommentModel comment) {
    return Row(
      children: [
        Obx(() => TextButton.icon(
          onPressed: () => controller.toggleLike(comment.id),
          icon: Icon(
            controller.isCommentLiked(comment.id) 
                ? Icons.favorite 
                : Icons.favorite_border,
            size: 18,
            color: controller.isCommentLiked(comment.id)
                ? Colors.red
                : Get.theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          label: Text('${comment.likes}'),
          style: TextButton.styleFrom(
            foregroundColor: Get.theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        )),
        TextButton.icon(
          onPressed: () => _replyToComment(comment),
          icon: const Icon(Icons.reply, size: 18),
          label: const Text('Yanıtla'),
          style: TextButton.styleFrom(
            foregroundColor: Get.theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const Spacer(),
        if (controller.canEditComment(comment))
          PopupMenuButton<String>(
            onSelected: (value) => _handleCommentAction(value, comment),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Düzenle'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Sil', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
            child: Icon(
              Icons.more_vert,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
      ],
    );
  }

  Widget _buildCommentInput() {
    final responsive = Get.find<ResponsiveController>();
    
    return Container(
      padding: EdgeInsets.all(responsive.isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Get.theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.commentController,
                decoration: InputDecoration(
                  hintText: 'Yorumunuzu yazın...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => controller.addComment(),
              ),
            ),
            const SizedBox(width: 8),
            Obx(() => IconButton(
              onPressed: controller.isAddingComment.value 
                  ? null 
                  : controller.addComment,
              icon: controller.isAddingComment.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              style: IconButton.styleFrom(
                backgroundColor: Get.theme.colorScheme.primary,
                foregroundColor: Get.theme.colorScheme.onPrimary,
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final responsive = Get.find<ResponsiveController>();
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.comment_outlined,
            size: responsive.isMobile ? 64 : 80,
            color: Get.theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz Yorum Yok',
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk yorumu sen yap!',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Get.theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Hata Oluştu',
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
            controller.errorMessage.value,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          )),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: controller.loadComments,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _replyToComment(CommentModel comment) {
    controller.setReplyTo(comment);
    // Focus to input
  }

  void _handleCommentAction(String action, CommentModel comment) {
    switch (action) {
      case 'edit':
        _editComment(comment);
        break;
      case 'delete':
        _deleteComment(comment);
        break;
    }
  }

  void _editComment(CommentModel comment) {
    final textController = TextEditingController(text: comment.content);
    
    Get.dialog(
      AlertDialog(
        title: const Text('Yorumu Düzenle'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Yorumunuzu düzenleyin...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              controller.editComment(comment.id, textController.text);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _deleteComment(CommentModel comment) {
    Get.dialog(
      AlertDialog(
        title: const Text('Yorumu Sil'),
        content: const Text('Bu yorumu silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              controller.deleteComment(comment.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.error,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}