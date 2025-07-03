import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/community/community_manage_controller.dart';
import '../../widgets/community/member_list_widget.dart';
import '../../widgets/community/membership_request_widget.dart';
import '../../widgets/image_upload_widget.dart';

class CommunityManageView extends GetView<CommunityManageController> {
  const CommunityManageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topluluk Yönetimi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
            tooltip: 'Topluluğu Sil',
          ),
        ],
      ),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hata: ${controller.error.value}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.loadCommunity,
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kapak Fotoğrafı
                  ImageUploadWidget(
                    onImageSelected: controller.onCoverImageSelected,
                    imageUrl: controller.coverImageUrl.value,
                    aspectRatio: 16 / 9,
                    maxWidth: 1920,
                    maxHeight: 1080,
                    label: 'Kapak Fotoğrafı',
                  ),
                  const SizedBox(height: 24),

                  // Topluluk Adı
                  TextFormField(
                    controller: controller.nameController,
                    decoration: const InputDecoration(
                      labelText: 'Topluluk Adı',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Topluluk adı gereklidir';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Topluluk Açıklaması
                  TextFormField(
                    controller: controller.descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Topluluk Açıklaması',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Topluluk açıklaması gereklidir';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Kategori Seçimi
                  Text(
                    'Kategoriler',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.availableCategories.map((category) {
                        final isSelected =
                            controller.selectedCategories.contains(category);
                        return FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              controller.selectedCategories.add(category);
                            } else {
                              controller.selectedCategories.remove(category);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Topluluk Ayarları
                  Text(
                    'Topluluk Ayarları',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => SwitchListTile(
                      title: const Text('Üyelik Onayı Gerekli'),
                      subtitle: const Text(
                        'Etkinleştirilirse, yeni üyelerin katılım talepleri moderatörler tarafından onaylanmalıdır',
                      ),
                      value: controller.requiresApproval.value,
                      onChanged: (value) =>
                          controller.requiresApproval.value = value,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => SwitchListTile(
                      title: const Text('Sadece Üyeler Görebilir'),
                      subtitle: const Text(
                        'Etkinleştirilirse, topluluk içeriği sadece üyeler tarafından görüntülenebilir',
                      ),
                      value: controller.isPrivate.value,
                      onChanged: (value) => controller.isPrivate.value = value,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Kaydet Butonu
                  SizedBox(
                    width: double.infinity,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.updateCommunity,
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Değişiklikleri Kaydet'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Üyelik Talepleri
                  if (controller.pendingMembers.isNotEmpty) ...[
                    Text(
                      'Üyelik Talepleri',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    MembershipRequestWidget(
                      pendingMembers: controller.pendingMembers,
                      onAccept: controller.acceptMember,
                      onReject: controller.rejectMember,
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Üye Listesi
                  Text(
                    'Üyeler',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  MemberListWidget(
                    members: controller.members,
                    isAdmin: true,
                    onMemberTap: controller.showMemberProfile,
                    onRemoveMember: controller.removeMember,
                    onPromoteToModerator: controller.promoteToModerator,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Topluluğu Sil'),
        content: const Text(
          'Bu işlem geri alınamaz. Topluluğu silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteCommunity();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
