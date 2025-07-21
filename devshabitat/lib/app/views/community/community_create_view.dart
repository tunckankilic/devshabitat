import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/community/community_create_controller.dart';
import '../../widgets/image_upload_widget.dart';

class CommunityCreateView extends GetView<CommunityCreateController> {
  const CommunityCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topluluk Oluştur'),
      ),
      body: SingleChildScrollView(
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
                  hintText: 'Topluluğunuzun adını girin',
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
                  hintText: 'Topluluğunuzu kısaca tanıtın',
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
              const SizedBox(height: 32),

              // Oluştur Butonu
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.createCommunity,
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Topluluk Oluştur'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
