import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import '../../models/code_snippet_model.dart';

class CodeSnippetCard extends StatelessWidget {
  final CodeSnippetModel snippet;
  final VoidCallback? onDelete;
  final bool isDraggable;

  const CodeSnippetCard({
    super.key,
    required this.snippet,
    this.onDelete,
    this.isDraggable = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              snippet.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle:
                snippet.description != "" && snippet.description.isNotEmpty
                ? Text(snippet.description)
                : null,
            trailing: onDelete != null
                ? IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: HighlightView(
              snippet.code,
              language: snippet.language,
              theme: githubTheme,
              padding: const EdgeInsets.all(12),
              textStyle: const TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 14,
              ),
            ),
          ),
          if (isDraggable)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.drag_handle, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    'Sürükle ve Bırak',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    if (isDraggable) {
      return Draggable<CodeSnippetModel>(
        data: snippet,
        feedback: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: card,
        ),
        childWhenDragging: Opacity(opacity: 0.5, child: card),
        child: card,
      );
    }

    return card;
  }
}
