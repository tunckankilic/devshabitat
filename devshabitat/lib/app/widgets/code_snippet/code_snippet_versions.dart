import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../controllers/code_snippet_controller.dart';
import 'code_editor.dart';

class CodeSnippetVersions extends StatelessWidget {
  final String snippetId;

  const CodeSnippetVersions({super.key, required this.snippetId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CodeSnippetController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.versions.isEmpty) {
        return const Center(child: Text('Henüz versiyon bulunmuyor'));
      }

      return ListView.builder(
        itemCount: controller.versions.length,
        itemBuilder: (context, index) {
          final version = controller.versions[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ExpansionTile(
              title: Text('Versiyon ${controller.versions.length - index}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeago.format(version.createdAt, locale: 'tr'),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  if (version.description.isNotEmpty)
                    Text(
                      version.description,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 200,
                    child: CodeEditor(
                      initialCode: version.code,
                      language: 'dart', // Dil bilgisi versiyonda saklanmalı
                      onChanged: (_) {},
                      readOnly: true,
                      showLineNumbers: true,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
