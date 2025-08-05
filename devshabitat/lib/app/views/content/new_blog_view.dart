import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/blog_controller.dart';
import '../../widgets/blog/rich_text_editor.dart';
import '../../widgets/blog/code_snippet_card.dart';
import '../../models/code_snippet_model.dart';

class NewBlogView extends GetView<BlogController> {
  const NewBlogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Blog Yazısı'),
        actions: [
          // Save as Draft
          TextButton(
            onPressed: controller.blogTitle.value.trim().isNotEmpty
                ? controller.saveBlogAsDraft
                : null,
            child: const Text('Taslak'),
          ),
          const SizedBox(width: 8),
          // Publish
          Obx(
            () => TextButton(
              onPressed:
                  controller.isBlogFormValid() &&
                      !controller.isCreatingBlog.value
                  ? controller.createBlogPost
                  : null,
              child: controller.isCreatingBlog.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Yayınla'),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Editor Section
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Blog Title
                  Obx(
                    () => TextFormField(
                      controller: controller.titleController,
                      decoration: InputDecoration(
                        labelText: 'Blog Başlığı *',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.title),
                        errorText:
                            controller.blogTitle.value.trim().isEmpty &&
                                controller.blogCreationError.value.isNotEmpty
                            ? 'Blog başlığı gereklidir'
                            : null,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Blog Description
                  Obx(
                    () => TextFormField(
                      controller: controller.descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Açıklama *',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.description),
                        errorText:
                            controller.blogDescription.value.trim().isEmpty &&
                                controller.blogCreationError.value.isNotEmpty
                            ? 'Blog açıklaması gereklidir'
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category and Tags
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller.categoryController,
                          decoration: const InputDecoration(
                            labelText: 'Kategori',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: controller.tagsController,
                          decoration: const InputDecoration(
                            labelText: 'Etiketler (virgülle ayırın)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.tag),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Rich Text Editor
                  const Text(
                    'Blog İçeriği *',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 400,
                    child: RichTextEditor(
                      initialText: controller.blogContent.value,
                      onChanged: (value) =>
                          controller.blogContent.value = value,
                    ),
                  ),

                  // Word Count and Reading Time
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Obx(
                          () => Text(
                            '${controller.wordCount} kelime',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Obx(
                          () => Text(
                            controller.estimatedReadingTime,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Code Snippets Section
          Container(
            width: 300,
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.code, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Kod Parçaları',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _showAddCodeSnippetDialog,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: DragTarget<CodeSnippetModel>(
                    onAccept: (data) {
                      // Handle reordering
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Obx(
                        () => ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: controller.codeSnippets.length,
                          itemBuilder: (context, index) {
                            return CodeSnippetCard(
                              snippet: controller.codeSnippets[index],
                              isDraggable: true,
                              onDelete: () => controller.removeCodeSnippet(
                                controller.codeSnippets[index].id,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCodeSnippetDialog() {
    final titleController = TextEditingController();
    final codeController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedLanguage = 'dart';

    Get.dialog(
      AlertDialog(
        title: const Text('Kod Parçası Ekle'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Başlık *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedLanguage,
                decoration: const InputDecoration(
                  labelText: 'Programlama Dili',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'dart', child: Text('Dart')),
                  DropdownMenuItem(
                    value: 'javascript',
                    child: Text('JavaScript'),
                  ),
                  DropdownMenuItem(value: 'python', child: Text('Python')),
                  DropdownMenuItem(value: 'java', child: Text('Java')),
                ],
                onChanged: (value) => selectedLanguage = value!,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                maxLines: 10,
                decoration: const InputDecoration(
                  labelText: 'Kod *',
                  border: OutlineInputBorder(),
                  hintText: 'Kodunuzu buraya yapıştırın',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty &&
                  codeController.text.trim().isNotEmpty) {
                controller.addCodeSnippet(
                  title: titleController.text.trim(),
                  code: codeController.text.trim(),
                  language: selectedLanguage,
                  description: descriptionController.text.trim(),
                );
                Get.back();
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }
}
