import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/code_snippet_model.dart';
import '../../controllers/code_snippet_controller.dart';
import 'code_editor.dart';
import 'code_snippet_comments.dart';
import 'code_snippet_versions.dart';

class CodeSnippetDetail extends StatelessWidget {
  final CodeSnippetModel snippet;

  const CodeSnippetDetail({super.key, required this.snippet});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CodeSnippetController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(snippet.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => controller.shareSnippet(snippet),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Düzenle')),
              const PopupMenuItem(value: 'delete', child: Text('Sil')),
            ],
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  // Edit işlemi
                  break;
                case 'delete':
                  controller.deleteSnippet(snippet.id);
                  Get.back();
                  break;
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Kod editörü
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CodeEditor(
                initialCode: snippet.code,
                language: snippet.language,
                onChanged: (_) {},
                readOnly: true,
                showLineNumbers: true,
                fontSize: 14,
                onTextSelected: (text) {
                  // Seçili metin referansı
                },
              ),
            ),
          ),

          // Versiyonlar ve yorumlar
          Expanded(
            flex: 1,
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Versiyonlar'),
                      Tab(text: 'Yorumlar'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Versiyonlar
                        CodeSnippetVersions(snippetId: snippet.id),

                        // Yorumlar
                        CodeSnippetComments(snippetId: snippet.id),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
