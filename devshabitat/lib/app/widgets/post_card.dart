// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/post.dart';
import '../controllers/feed_controller.dart';
import 'github_code_viewer.dart';
import 'comment_modal.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;
  final feedController = Get.find<FeedController>();

  PostCard({
    super.key,
    required this.post,
    this.onTap,
  });

  void _showPostMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Gönderiyi Şikayet Et'),
            onTap: () {
              Get.back();
              feedController.reportPost(post.id);
            },
          ),
          if (post.userId == feedController.currentUserId)
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Gönderiyi Sil'),
              onTap: () {
                Get.back();
                feedController.deletePost(post.id);
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kullanıcı bilgileri
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(post.userId)
                  .get(),
              builder: (context, snapshot) {
                final userData = snapshot.data?.data() as Map<String, dynamic>?;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      userData?['photoURL'] ??
                          'https://via.placeholder.com/150',
                    ),
                  ),
                  title: Text(userData?['displayName'] ?? 'Kullanıcı'),
                  subtitle: Text(
                    timeago.format(post.createdAt, locale: 'tr'),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showPostMenu(context),
                  ),
                );
              },
            ),

            // İçerik
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(post.content),
            ),

            // Resimler
            if (post.images.isNotEmpty) ...[
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 16 : 8,
                        right: index == post.images.length - 1 ? 16 : 0,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: post.images[index],
                          fit: BoxFit.cover,
                          width: 200,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.error),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            // GitHub repo
            if (post.githubRepoUrl != null) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.code, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'GitHub Repository',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: GitHubCodeViewer(
                        githubUrl: post.githubRepoUrl!,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Etiketler
            if (post.metadata?['tags'] != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  children: (post.metadata!['tags'] as List)
                      .map((tag) => Chip(
                            label: Text(tag),
                            backgroundColor:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],

            // Alt butonlar
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  // Beğeni butonu
                  Obx(() => IconButton(
                        icon: Icon(
                          post.likes.contains(feedController.currentUserId)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color:
                              post.likes.contains(feedController.currentUserId)
                                  ? Colors.red
                                  : null,
                        ),
                        onPressed: () => feedController.toggleLike(post.id),
                      )),
                  Text(
                    post.likes.length.toString(),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),

                  // Yorum butonu
                  IconButton(
                    icon: const Icon(Icons.comment_outlined),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => CommentModal(postId: post.id),
                      );
                    },
                  ),
                  Text(
                    post.comments.length.toString(),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const Spacer(),

                  // Paylaş butonu
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () {
                      Share.share(
                        'DevShabitat\'ta bir gönderi: ${post.content}\n\nGönderiyi görüntüle: https://devshabitat.com/posts/${post.id}',
                        subject: 'DevShabitat Gönderi Paylaşımı',
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
