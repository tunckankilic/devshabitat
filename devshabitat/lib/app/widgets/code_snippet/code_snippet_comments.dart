import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../controllers/code_snippet_controller.dart';
import '../../models/code_snippet_comment.dart';

class CodeSnippetComments extends StatelessWidget {
  final String snippetId;

  const CodeSnippetComments({super.key, required this.snippetId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CodeSnippetController>();

    return Column(
      children: [
        // Yorum ekleme formu
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.commentController,
                  decoration: const InputDecoration(
                    hintText: 'Yorum ekle...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => controller.addComment(snippetId),
              ),
            ],
          ),
        ),

        // Yorumlar listesi
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.comments.isEmpty) {
              return const Center(child: Text('Henüz yorum yapılmamış'));
            }

            return ListView.builder(
              itemCount: controller.comments.length,
              itemBuilder: (context, index) {
                final comment = controller.comments[index];
                return _CommentCard(
                  comment: comment,
                  onLike: () => controller.toggleLike(snippetId, comment.id),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

class _CommentCard extends StatelessWidget {
  final CodeSnippetComment comment;
  final VoidCallback onLike;

  const _CommentCard({required this.comment, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Yazar bilgisi
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: comment.authorPhotoUrl != null
                      ? NetworkImage(comment.authorPhotoUrl!)
                      : null,
                  child: comment.authorPhotoUrl == null
                      ? Text(comment.authorName[0])
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.authorName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        timeago.format(comment.createdAt, locale: 'tr'),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Yorum içeriği
            Text(comment.content),
            const SizedBox(height: 8),

            // Kod referansı
            if (comment.codeReference != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  comment.codeReference!,
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 12,
                  ),
                ),
              ),

            // Beğeni ve yanıt
            Row(
              children: [
                TextButton.icon(
                  icon: Icon(
                    comment.likes.isEmpty
                        ? Icons.favorite_border
                        : Icons.favorite,
                    color: comment.likes.isEmpty ? null : Colors.red,
                  ),
                  label: Text(
                    comment.likes.length.toString(),
                    style: const TextStyle(color: Colors.black54),
                  ),
                  onPressed: onLike,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.reply),
                  label: const Text('Yanıtla'),
                  onPressed: () {
                    // Yanıtlama işlemi
                  },
                ),
              ],
            ),

            // Yanıtlar
            if (comment.replies.isNotEmpty) ...[
              const Divider(),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comment.replies.length,
                itemBuilder: (context, index) {
                  final reply = comment.replies[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: _CommentCard(comment: reply, onLike: () {}),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
