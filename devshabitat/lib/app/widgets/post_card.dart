import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post.dart';
import 'github_code_viewer.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;

  const PostCard({
    Key? key,
    required this.post,
    this.onTap,
  }) : super(key: key);

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
            ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(post.userId),
              ),
              title: Text(post.userId), // TODO: Kullanıcı adını göster
              subtitle: Text(
                post.createdAt.toString(), // TODO: Zaman formatını düzenle
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // TODO: Post menüsünü göster
                },
              ),
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
                  IconButton(
                    icon: Icon(
                      post.likes.contains(post.userId)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          post.likes.contains(post.userId) ? Colors.red : null,
                    ),
                    onPressed: () {
                      // TODO: Beğeni işlemini yap
                    },
                  ),
                  Text(
                    post.likes.length.toString(),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),

                  // Yorum butonu
                  IconButton(
                    icon: const Icon(Icons.comment_outlined),
                    onPressed: () {
                      // TODO: Yorum modalını göster
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
                      // TODO: Paylaşım menüsünü göster
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
