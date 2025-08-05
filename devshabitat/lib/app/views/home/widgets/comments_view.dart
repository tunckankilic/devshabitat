import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:devshabitat/app/repositories/auth_repository.dart';
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
            onPressed: () => controller.loadComments(),
            tooltip: AppStrings.refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // Yorumlar listesi
          Expanded(child: _buildCommentsList()),

          // Yorum ekleme alanı
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.loadComments(),
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
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.makeFirstComment,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
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
                  backgroundImage: comment.authorPhotoUrl != null
                      ? NetworkImage(comment.authorPhotoUrl!)
                      : null,
                  child: comment.authorPhotoUrl == null
                      ? Text(
                          comment.authorName.isNotEmpty
                              ? comment.authorName[0].toUpperCase()
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
                        comment.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${comment.createdAt.day}/${comment.createdAt.month}/${comment.createdAt.year}',
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
                    if (comment.authorId == Get.find<AuthRepository>().currentUser?.uid)
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
            Text(comment.content, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    comment.likes > 0 ? Icons.favorite : Icons.favorite_border,
                    size: 18,
                    color: comment.likes > 0
                        ? Colors.red
                        : Colors.grey.shade600,
                  ),
                  onPressed: () => controller.toggleLike(comment.id),
                ),
                Text(
                  '${comment.likes}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
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
                  controller.commentController.text = value;
                  controller.addComment();
                  textController.clear();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Obx(
            () => IconButton(
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
                        controller.commentController.text = textController.text;
                        controller.addComment();
                        textController.clear();
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}
