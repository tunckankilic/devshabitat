import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/blog_controller.dart';

class NewBlogView extends GetView<BlogController> {
  const NewBlogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.writeBlog),
        actions: [
          // Save as Draft
          TextButton(
            onPressed: controller.blogTitle.value.trim().isNotEmpty
                ? controller.saveBlogAsDraft
                : null,
            child: Text('Taslak'),
          ),
          const SizedBox(width: 8),
          // Publish
          Obx(() => TextButton(
                onPressed: controller.isBlogFormValid() &&
                        !controller.isCreatingBlog.value
                    ? controller.createBlogPost
                    : null,
                child: controller.isCreatingBlog.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('Yayınla'),
              )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.article_outlined, size: 28, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yeni Blog Yazısı',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        'Deneyimlerinizi ve fikirlerinizi paylaşın',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Blog Title
            Obx(() => TextFormField(
                  onChanged: (value) => controller.blogTitle.value = value,
                  decoration: InputDecoration(
                    labelText: 'Blog Başlığı *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                    errorText: controller.blogTitle.value.trim().isEmpty &&
                            controller.blogCreationError.value.isNotEmpty
                        ? 'Blog başlığı gereklidir'
                        : null,
                  ),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                )),
            const SizedBox(height: 16),

            // Blog Description
            Obx(() => TextFormField(
                  onChanged: (value) =>
                      controller.blogDescription.value = value,
                  decoration: InputDecoration(
                    labelText: 'Kısa Açıklama *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                    hintText: 'Yazınızı kısaca özetleyin...',
                    errorText:
                        controller.blogDescription.value.trim().isEmpty &&
                                controller.blogCreationError.value.isNotEmpty
                            ? 'Blog açıklaması gereklidir'
                            : null,
                  ),
                  maxLines: 2,
                )),
            const SizedBox(height: 16),

            // Category and Tags Row
            Row(
              children: [
                Expanded(
                  child: Obx(() => TextFormField(
                        onChanged: (value) =>
                            controller.blogCategory.value = value,
                        decoration: InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                          hintText: 'Flutter, React, Backend',
                        ),
                      )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => TextFormField(
                        onChanged: (value) => controller.blogTags.value = value,
                        decoration: InputDecoration(
                          labelText: 'Etiketler',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.local_offer),
                          hintText: 'tutorial, tips, guide',
                        ),
                      )),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Content Editor
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'İçerik *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                    Obx(() => Text(
                          '${controller.contentWordCount} kelime • ${controller.estimatedReadingTime}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 8),
                Obx(() => Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        onChanged: (value) =>
                            controller.blogContent.value = value,
                        decoration: InputDecoration(
                          hintText:
                              'Blog içeriğinizi buraya yazın...\n\nMarkdown formatını destekliyoruz:\n# Başlık\n**Kalın metin**\n*İtalik metin*\n[Link](url)',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                          errorText: controller.blogContent.value
                                      .trim()
                                      .isEmpty &&
                                  controller.blogCreationError.value.isNotEmpty
                              ? 'Blog içeriği gereklidir'
                              : null,
                        ),
                        maxLines: 15,
                        minLines: 10,
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 24),

            // Code Snippets Section
            _buildCodeSnippetsSection(context),
            const SizedBox(height: 24),

            // Form Validation Status
            Obx(() {
              final error = controller.getBlogFormError();
              if (error != null) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          error,
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return SizedBox.shrink();
            }),

            // Success/Error Messages
            Obx(() {
              if (controller.blogCreationError.value.isNotEmpty) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.blogCreationError.value,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return SizedBox.shrink();
            }),

            const SizedBox(height: 24),

            // Tips Card
            Card(
              color: Colors.blue.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'İpuçları',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Başlığınızı dikkat çekici ve açıklayıcı yapın\n'
                      '• Kısa açıklamada yazınızın özünü verin\n'
                      '• Kod örnekleri eklemek için ``` kullanın\n'
                      '• Resim eklemek için ![alt](url) formatını kullanın',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
              'Kod Parçaları',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            TextButton.icon(
              onPressed: () => _showAddCodeSnippetDialog(context),
              icon: Icon(Icons.add, size: 18),
              label: Text('Kod Ekle'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.codeSnippets.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.grey.shade300, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              child: Column(
                children: [
                  Icon(Icons.code_off, color: Colors.grey, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Henüz kod parçası eklenmedi',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Yukarıdaki "Kod Ekle" butonunu kullanarak kod parçaları ekleyebilirsiniz',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.codeSnippets.length,
            itemBuilder: (context, index) {
              final snippet = controller.codeSnippets[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              snippet.title,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Chip(
                            label: Text(snippet.language),
                            backgroundColor: Colors.purple.withOpacity(0.1),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon:
                                Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () =>
                                controller.removeCodeSnippet(index),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                      if (snippet.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          snippet.description!,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          snippet.code.length > 100
                              ? '${snippet.code.substring(0, 100)}...'
                              : snippet.code,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  void _showAddCodeSnippetDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final codeController = TextEditingController();
    String selectedLanguage = 'dart';

    final languages = [
      'dart',
      'javascript',
      'python',
      'java',
      'kotlin',
      'swift',
      'typescript',
      'php',
      'go',
      'rust',
      'cpp',
      'c',
      'html',
      'css'
    ];

    Get.dialog(
      Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.code, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text(
                        'Kod Parçası Ekle',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Başlık *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Açıklama (İsteğe bağlı)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return DropdownButtonFormField<String>(
                        value: selectedLanguage,
                        decoration: InputDecoration(
                          labelText: 'Programlama Dili',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.language),
                        ),
                        items: languages
                            .map((lang) => DropdownMenuItem(
                                  value: lang,
                                  child: Text(lang.toUpperCase()),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedLanguage = value!;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      labelText: 'Kod *',
                      border: OutlineInputBorder(),
                      hintText: 'Kod parçanızı buraya yazın...',
                    ),
                    maxLines: 10,
                    style: TextStyle(fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text('İptal'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (titleController.text.trim().isNotEmpty &&
                              codeController.text.trim().isNotEmpty) {
                            controller.addCodeSnippet(
                              title: titleController.text.trim(),
                              description:
                                  descriptionController.text.trim().isNotEmpty
                                      ? descriptionController.text.trim()
                                      : null,
                              code: codeController.text.trim(),
                              language: selectedLanguage,
                            );
                            Get.back();
                          }
                        },
                        child: Text('Ekle'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
