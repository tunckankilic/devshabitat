import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/thread_controller.dart';
import '../../models/thread_model.dart';
import '../base/base_view.dart';

class ThreadOrganizationView extends BaseView<ThreadController> {
  final RxString searchQuery = ''.obs;

  ThreadOrganizationView({super.key});
  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thread Organizasyonu',
          style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 18, tablet: 20),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: _buildResponsiveLayout(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateThreadDialog(),
        tooltip: 'Yeni Thread Oluştur',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildResponsiveLayout() {
    if (responsive.isMobile) {
      return _buildMobileLayout();
    } else if (responsive.isTablet) {
      return _buildTabletLayout();
    } else {
      return _buildDesktopLayout();
    }
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildTopicFilter(),
        Expanded(
          child: _buildThreadList(),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Sol panel - Topic listesi
        SizedBox(
          width: 250,
          child: _buildTopicPanel(),
        ),
        // Sağ panel - Thread listesi
        Expanded(
          child: _buildThreadList(),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Sol panel - Topic listesi
        SizedBox(
          width: 300,
          child: _buildTopicPanel(),
        ),
        // Orta panel - Thread listesi
        Expanded(
          flex: 2,
          child: _buildThreadList(),
        ),
        // Sağ panel - Thread detayları
        SizedBox(
          width: 400,
          child: _buildThreadDetails(),
        ),
      ],
    );
  }

  Widget _buildTopicFilter() {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.topics.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildTopicChip(
                  'Tümü', controller.selectedTopic.value.isEmpty);
            }
            final topic = controller.topics[index - 1];
            return _buildTopicChip(
                topic, controller.selectedTopic.value == topic);
          },
        );
      }),
    );
  }

  Widget _buildTopicChip(String topic, bool isSelected) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(topic),
        selected: isSelected,
        onSelected: (selected) {
          controller.selectedTopic.value = selected ? topic : '';
        },
        selectedColor: Get.theme.primaryColor.withOpacity(0.2),
      ),
    );
  }

  Widget _buildTopicPanel() {
    return Card(
      margin: EdgeInsets.all(8),
      child: Column(
        children: [
          ListTile(
            title: Text('Konular'),
            trailing: IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _showAddTopicDialog(),
            ),
          ),
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: controller.topics.length,
                itemBuilder: (context, index) {
                  final topic = controller.topics[index];
                  return ListTile(
                    title: Text(topic),
                    selected: controller.selectedTopic.value == topic,
                    onTap: () => controller.selectedTopic.value = topic,
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _showEditTopicDialog(topic),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildThreadList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      final threads = _getFilteredThreads();

      if (threads.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.forum_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Henüz thread bulunmuyor',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: threads.length,
        itemBuilder: (context, index) {
          final thread = threads[index];
          return _buildThreadTile(thread);
        },
      );
    });
  }

  Widget _buildThreadTile(ThreadModel thread) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(thread.authorName[0].toUpperCase()),
        ),
        title: Text(
          thread.content.length > 50
              ? '${thread.content.substring(0, 50)}...'
              : thread.content,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${thread.authorName} • ${_formatDate(thread.createdAt)}'),
            if (thread.replies.isNotEmpty)
              Text('${thread.replies.length} yanıt'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!thread.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () => _showThreadOptions(thread),
            ),
          ],
        ),
        onTap: () => _openThread(thread),
      ),
    );
  }

  Widget _buildThreadDetails() {
    return Obx(() {
      final currentThreadId = controller.currentThreadId.value;
      if (currentThreadId.isEmpty) {
        return Center(
          child: Text('Thread seçin'),
        );
      }

      final thread = controller.activeThreads[currentThreadId];
      if (thread == null) {
        return Center(child: CircularProgressIndicator());
      }

      return Card(
        margin: EdgeInsets.all(8),
        child: Column(
          children: [
            ListTile(
              title: Text('Thread Detayları'),
              trailing: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => controller.currentThreadId.value = '',
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thread.content,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Yanıtlar (${thread.replies.length})',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    ...thread.replies.map((reply) => _buildReplyTile(reply)),
                  ],
                ),
              ),
            ),
            _buildReplyInput(thread.id),
          ],
        ),
      );
    });
  }

  Widget _buildReplyTile(ThreadReply reply) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  child: Text(reply.authorName[0].toUpperCase()),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reply.authorName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatDate(reply.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(reply.content),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInput(String threadId) {
    final textController = TextEditingController();

    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'Yanıt yazın...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              if (textController.text.isNotEmpty) {
                controller.replyToThread(threadId, textController.text);
                textController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  List<ThreadModel> _getFilteredThreads() {
    var threads = controller.activeThreads.values.toList();

    // Topic filtresi
    if (controller.selectedTopic.value.isNotEmpty) {
      // Burada topic filtreleme mantığı eklenebilir
    }

    // Arama filtresi
    if (searchQuery.value.isNotEmpty) {
      threads = threads
          .where((thread) =>
              thread.content
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ||
              thread.authorName
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    return threads;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  void _showSearchDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Thread Ara'),
        content: TextField(
          onChanged: (value) => searchQuery.value = value,
          decoration: InputDecoration(
            hintText: 'Thread içeriğinde ara...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // Arama işlemi
            },
            child: Text('Ara'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Filtrele'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: Text('Okunmamış'),
              value: false,
              onChanged: (value) {
                // Filtre mantığı
              },
            ),
            CheckboxListTile(
              title: Text('Yanıtı olan'),
              value: false,
              onChanged: (value) {
                // Filtre mantığı
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // Filtre uygula
            },
            child: Text('Uygula'),
          ),
        ],
      ),
    );
  }

  void _showCreateThreadDialog() {
    final contentController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Yeni Thread Oluştur'),
        content: TextField(
          controller: contentController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Thread içeriğini yazın...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (contentController.text.isNotEmpty) {
                controller.createThread('', contentController.text);
                Get.back();
              }
            },
            child: Text('Oluştur'),
          ),
        ],
      ),
    );
  }

  void _showAddTopicDialog() {
    final topicController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Yeni Konu Ekle'),
        content: TextField(
          controller: topicController,
          decoration: InputDecoration(
            hintText: 'Konu adı...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              if (topicController.text.isNotEmpty) {
                await controller.addTopic(topicController.text);
                Get.back();
              }
            },
            child: Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _showEditTopicDialog(String topic) {
    final topicController = TextEditingController(text: topic);

    Get.dialog(
      AlertDialog(
        title: Text('Konu Düzenle'),
        content: TextField(
          controller: topicController,
          decoration: InputDecoration(
            hintText: 'Konu adı...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              if (topicController.text.isNotEmpty) {
                await controller.updateTopic(topic, topicController.text);
                Get.back();
              }
            },
            child: Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showThreadOptions(ThreadModel thread) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Düzenle'),
              onTap: () {
                Get.back();
                // Düzenleme işlemi
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Sil'),
              onTap: () {
                Get.back();
                _confirmDeleteThread(thread);
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text(
                  'Bildirimleri ${controller.threadNotifications[thread.id] == false ? 'Aç' : 'Kapat'}'),
              onTap: () {
                Get.back();
                controller.toggleThreadNotifications(thread.id);
              },
            ),
          ],
        ),
      ),
      backgroundColor: Get.theme.scaffoldBackgroundColor,
    );
  }

  void _confirmDeleteThread(ThreadModel thread) {
    Get.dialog(
      AlertDialog(
        title: Text('Thread Sil'),
        content: Text('Bu thread\'i silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteThread(thread.id);
              Get.back();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _openThread(ThreadModel thread) {
    controller.loadThread(thread.id);
    controller.markThreadAsRead(thread.id);
  }
}
