import 'package:flutter/material.dart';
import '../../models/blog_model.dart';
import '../../widgets/code_discussion_widget.dart';
import '../../constants/app_strings.dart';

class BlogDetailView extends StatelessWidget {
  final BlogModel blog;

  const BlogDetailView({
    super.key,
    required this.blog,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blog Yazısı'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // Share blog functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.bookmark_border),
            onPressed: () {
              // Bookmark blog functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blog Header
            _buildBlogHeader(context),
            const SizedBox(height: 24),

            // Blog Content
            _buildBlogContent(context),
            const SizedBox(height: 32),

            // Code Snippets Section
            if (blog.codeSnippets.isNotEmpty) ...[
              _buildCodeSnippetsSection(context),
              const SizedBox(height: 32),
            ],

            // Author Info & Actions
            _buildAuthorSection(context),
            const SizedBox(height: 24),

            // Comments Section (placeholder for now)
            _buildCommentsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBlogHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Chip
        Chip(
          label: Text(blog.category),
          backgroundColor: Colors.blue.withOpacity(0.1),
          labelStyle: TextStyle(color: Colors.blue),
        ),
        const SizedBox(height: 8),

        // Title
        Text(
          blog.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),

        // Description
        Text(
          blog.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 16),

        // Meta Information
        Row(
          children: [
            Icon(Icons.person, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              blog.authorName,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(width: 16),
            Icon(Icons.access_time, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              _formatDate(blog.publishedAt ?? blog.createdAt),
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(width: 16),
            Icon(Icons.schedule, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              blog.estimatedReadingTime,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Tags
        if (blog.tags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: blog.tags
                .map((tag) => Chip(
                      label: Text(tag),
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      labelStyle: TextStyle(fontSize: 12),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildBlogContent(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'İçerik',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            blog.content,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeSnippetsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.code, color: Colors.purple),
            const SizedBox(width: 8),
            Text(
              'Kod Parçaları ve Tartışmalar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: blog.codeSnippets.length,
          separatorBuilder: (context, index) => const SizedBox(height: 24),
          itemBuilder: (context, index) {
            final snippet = blog.codeSnippets[index];
            return Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CodeDiscussionWidget(snippet: snippet),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAuthorSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue.withOpacity(0.2),
            child: Text(
              blog.authorName.isNotEmpty
                  ? blog.authorName[0].toUpperCase()
                  : 'A',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  blog.authorName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Yazar',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  Icon(Icons.favorite_border, color: Colors.red, size: 20),
                  const SizedBox(width: 4),
                  Text('${blog.likeCount}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.visibility, color: Colors.grey, size: 20),
                  const SizedBox(width: 4),
                  Text('${blog.viewCount}'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.comments,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 40),
              const SizedBox(height: 8),
              Text(
                'Yorumlar yakında eklenecek',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'Şimdilik kod parçaları üzerinde tartışabilirsiniz',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
