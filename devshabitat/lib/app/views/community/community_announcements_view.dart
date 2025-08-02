import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/community/community_announcement_controller.dart';
import '../../models/community/announcement_model.dart';

class CommunityAnnouncementsView
    extends GetView<CommunityAnnouncementController> {
  final String communityId;

  const CommunityAnnouncementsView({super.key, required this.communityId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topluluk Duyuruları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateAnnouncementDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Kategori filtresi
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildCategoryFilter(),
          ),
          // Duyuru listesi
          Expanded(child: _buildAnnouncementsList()),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DropdownButtonFormField<String>(
        value: controller.selectedCategory.value,
        decoration: const InputDecoration(
          labelText: 'Kategori',
          border: OutlineInputBorder(),
        ),
        items: controller.getCategories().map((category) {
          return DropdownMenuItem(
            value: category['value'],
            child: Text(category['display']!),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            controller.changeCategory(value);
            controller.loadAnnouncements(communityId);
          }
        },
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.announcements.isEmpty) {
        return const Center(child: Text('Henüz duyuru bulunmuyor'));
      }

      return ListView.builder(
        itemCount: controller.announcements.length,
        itemBuilder: (context, index) {
          final announcement = controller.announcements[index];
          return _buildAnnouncementCard(announcement);
        },
      );
    });
  }

  Widget _buildAnnouncementCard(AnnouncementModel announcement) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(
          announcement.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(announcement.content),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildCategoryChip(announcement.category),
                const Spacer(),
                Text(
                  _formatDate(announcement.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _showDeleteConfirmation(announcement),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(AnnouncementCategory category) {
    Color chipColor;
    switch (category) {
      case AnnouncementCategory.urgent:
        chipColor = Colors.red;
        break;
      case AnnouncementCategory.event:
        chipColor = Colors.green;
        break;
      case AnnouncementCategory.update:
        chipColor = Colors.blue;
        break;
      case AnnouncementCategory.news:
        chipColor = Colors.orange;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(
        controller.getCategories().firstWhere(
          (c) => c['value'] == category.toString().split('.').last,
        )['display']!,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteConfirmation(AnnouncementModel announcement) {
    Get.dialog(
      AlertDialog(
        title: const Text('Duyuru Silinecek'),
        content: const Text('Bu duyuruyu silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(child: const Text('İptal'), onPressed: () => Get.back()),
          TextButton(
            child: const Text('Sil'),
            onPressed: () {
              Get.back();
              controller.deleteAnnouncement(communityId, announcement.id);
            },
          ),
        ],
      ),
    );
  }

  void _showCreateAnnouncementDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String title = '';
    String content = '';
    AnnouncementCategory category = AnnouncementCategory.general;

    Get.dialog(
      AlertDialog(
        title: const Text('Yeni Duyuru'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Başlık gerekli' : null,
                onSaved: (value) => title = value ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'İçerik',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty == true ? 'İçerik gerekli' : null,
                onSaved: (value) => content = value ?? '',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AnnouncementCategory>(
                value: category,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: AnnouncementCategory.values.map((category) {
                  final display = controller.getCategories().firstWhere(
                    (c) => c['value'] == category.toString().split('.').last,
                  )['display']!;
                  return DropdownMenuItem(
                    value: category,
                    child: Text(display),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    category = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(child: const Text('İptal'), onPressed: () => Get.back()),
          TextButton(
            child: const Text('Oluştur'),
            onPressed: () {
              if (formKey.currentState?.validate() == true) {
                formKey.currentState?.save();
                Get.back();
                controller.createAnnouncement(
                  communityId: communityId,
                  title: title,
                  content: content,
                  category: category,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
