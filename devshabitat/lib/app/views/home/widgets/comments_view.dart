import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/comments_controller.dart';
import '../../../models/comment_model.dart';

class CommentsView extends GetView<CommentsController> {
  const CommentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.comments),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshComments(),
            tooltip: AppStrings.refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // Feed öğesi özeti
          _buildFeedItemSummary(),

          // Yorumlar listesi
          Expanded(
            child: _buildCommentsList(),
          ),

          // Yorum ekleme alanı
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildFeedItemSummary() {
    return Obx(() {
      final feedItem = controller.currentFeedItem.value;
      if (feedItem == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.originalPost,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              feedItem.content,
              style: const TextStyle(fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.favorite, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${feedItem.likesCount}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                Icon(Icons.comment, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${feedItem.commentsCount}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCommentsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.error.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                controller.error.value,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.refreshComments(),
                child: Text(AppStrings.tryAgain),
              ),
            ],
          ),
        );
      }

      if (controller.comments.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.comment_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.noComments,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.makeFirstComment,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.comments.length,
        itemBuilder: (context, index) {
          final comment = controller.comments[index];
          return _buildCommentCard(comment);
        },
      );
    });
  }

  Widget _buildCommentCard(CommentModel comment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: comment.userPhotoUrl != null
                      ? NetworkImage(comment.userPhotoUrl!)
                      : null,
                  child: comment.userPhotoUrl == null
                      ? Text(
                          comment.userName.isNotEmpty
                              ? comment.userName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(fontSize: 12),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        controller.formatDate(comment.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (value) {
                    if (value == 'delete') {
                      controller.deleteComment(comment.id);
                    }
                  },
                  itemBuilder: (context) => [
                    if (comment.userId == controller.currentUserId)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16),
                            SizedBox(width: 8),
                            Text(AppStrings.delete),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              comment.comment,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    comment.isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 18,
                    color: comment.isLiked ? Colors.red : Colors.grey.shade600,
                  ),
                  onPressed: () => controller.likeComment(comment.id),
                ),
                Text(
                  '${comment.likesCount}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    final textController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: AppStrings.writeYourComment,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  controller.addComment(value);
                  textController.clear();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => IconButton(
                icon: controller.isAddingComment.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                onPressed: controller.isAddingComment.value
                    ? null
                    : () {
                        if (textController.text.trim().isNotEmpty) {
                          controller.addComment(textController.text);
                          textController.clear();
                        }
                      },
              )),
        ],
      ),
    );
  }
}
