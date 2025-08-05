import 'package:flutter/material.dart';

import '../../models/blog_model.dart';
import '../../widgets/blog/rich_text_editor.dart';
import '../../widgets/blog/code_snippet_card.dart';
import '../../widgets/blog/reading_progress_indicator.dart';

class BlogDetailView extends StatefulWidget {
  final BlogModel blog;

  const BlogDetailView({super.key, required this.blog});

  @override
  State<BlogDetailView> createState() => _BlogDetailViewState();
}

class _BlogDetailViewState extends State<BlogDetailView> {
  final ScrollController _scrollController = ScrollController();
  double _readingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateReadingProgress);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateReadingProgress);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateReadingProgress() {
    if (!_scrollController.hasClients) return;

    final progress =
        _scrollController.offset /
        (_scrollController.position.maxScrollExtent -
            _scrollController.position.viewportDimension);
    setState(() {
      _readingProgress = progress.clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ReadingProgressIndicator(progress: _readingProgress),
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(widget.blog.title),
                    background: widget.blog.thumbnailUrl != null
                        ? Image.network(
                            widget.blog.thumbnailUrl!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.article, size: 64),
                          ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        // Share functionality
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.bookmark_border),
                      onPressed: () {
                        // Bookmark functionality
                      },
                    ),
                  ],
                ),

                // Blog Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Author Info
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                widget.blog.authorPhotoUrl ?? '',
                              ),
                              radius: 24,
                              child: widget.blog.authorPhotoUrl == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.blog.authorName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    widget.blog.createdAt.toString().substring(
                                      0,
                                      10,
                                    ),
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            Chip(
                              label: Text(widget.blog.estimatedReadingTime),
                              backgroundColor: Colors.blue[50],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Description
                        Text(
                          widget.blog.description,
                          style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Tags
                        if (widget.blog.tags.isNotEmpty) ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: widget.blog.tags
                                .map(
                                  (tag) => Chip(
                                    label: Text(tag),
                                    backgroundColor: Colors.blue[50],
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Content
                        SizedBox(
                          height: 500, // Adjust based on content
                          child: RichTextEditor(
                            initialText: widget.blog.content,
                            onChanged: (_) {},
                            readOnly: true,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Code Snippets
                        if (widget.blog.codeSnippets.isNotEmpty) ...[
                          const Text(
                            'Kod Parçaları',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...widget.blog.codeSnippets.map(
                            (snippet) => CodeSnippetCard(snippet: snippet),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
