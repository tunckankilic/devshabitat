import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import '../controllers/code_discussion_controller.dart';
import '../models/code_snippet_model.dart';

class CodeDiscussionWidget extends StatelessWidget {
  final CodeSnippetModel snippet;

  const CodeDiscussionWidget({
    super.key,
    required this.snippet,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CodeDiscussionController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kod Başlığı ve Detayları
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                snippet.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (snippet.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  snippet.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    label: Text(snippet.language),
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Paylaşım: ${_formatDate(snippet.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Kod Görüntüleyici
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: HighlightView(
            snippet.code,
            language: snippet.language.toLowerCase(),
            theme: githubTheme,
            padding: const EdgeInsets.all(16),
          ),
        ),

        // Yorumlar
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Yorumlar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snippet.comments.length,
          itemBuilder: (context, index) {
            final comment = snippet.comments[index];
            return CommentCard(comment: comment);
          },
        ),

        // Çözüm Önerileri
        if (snippet.solutions.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Çözüm Önerileri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snippet.solutions.length,
            itemBuilder: (context, index) {
              final solution = snippet.solutions[index];
              return SolutionCard(solution: solution);
            },
          ),
        ],

        // Yorum Ekleme
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: AddCommentForm(
            onSubmit: (comment) {
              controller.addCodeComment(
                snippetId: snippet.id,
                comment: comment,
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class CommentCard extends StatelessWidget {
  final CodeComment comment;

  const CommentCard({
    super.key,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (comment.lineNumber != null)
              Text(
                'Satır ${comment.lineNumber}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 8),
            Text(comment.comment),
            const SizedBox(height: 8),
            Text(
              _formatDate(comment.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class SolutionCard extends StatelessWidget {
  final CodeSolution solution;

  const SolutionCard({
    super.key,
    required this.solution,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CodeDiscussionController>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Çözüm Önerisi',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  '${solution.votes} oy',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                IconButton(
                  icon: const Icon(Icons.thumb_up),
                  onPressed: () {
                    // Oylama işlemi
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(solution.explanation),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: HighlightView(
                solution.code,
                language: 'dart', // Dil tespiti eklenebilir
                theme: githubTheme,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(solution.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class AddCommentForm extends StatefulWidget {
  final Function(String) onSubmit;

  const AddCommentForm({
    super.key,
    required this.onSubmit,
  });

  @override
  State<AddCommentForm> createState() => _AddCommentFormState();
}

class _AddCommentFormState extends State<AddCommentForm> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Yorum ekle...',
              border: OutlineInputBorder(),
            ),
            maxLines: null,
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              widget.onSubmit(_controller.text);
              _controller.clear();
            }
          },
          child: const Text('Gönder'),
        ),
      ],
    );
  }
}
