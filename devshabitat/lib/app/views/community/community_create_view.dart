import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/community/community_create_controller.dart';
import '../../widgets/image_upload_widget.dart';
import '../../widgets/advanced_file_upload.dart';
import '../../repositories/auth_repository.dart';

class CommunityCreateView extends GetView<CommunityCreateController> {
  const CommunityCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.createCommunity),
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
                label: AppStrings.coverImage,
              ),
              const SizedBox(height: 24),

              // Topluluk Adı
              TextFormField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  labelText: AppStrings.communityName,
                  hintText: AppStrings.communityNameHint,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.communityNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Topluluk Açıklaması
              TextFormField(
                controller: controller.descriptionController,
                decoration: const InputDecoration(
                  labelText: AppStrings.communityDescription,
                  hintText: AppStrings.communityDescriptionHint,
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.communityDescriptionRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Kategori Seçimi
              Text(
                AppStrings.categories,
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
                AppStrings.communitySettings,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Obx(
                () => SwitchListTile(
                  title: Text(AppStrings.membershipApprovalRequired),
                  subtitle: Text(
                    AppStrings.membershipApprovalRequiredDescription,
                  ),
                  value: controller.requiresApproval.value,
                  onChanged: (value) =>
                      controller.requiresApproval.value = value,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => SwitchListTile(
                  title: Text(AppStrings.onlyMembersCanView),
                  subtitle: Text(
                    AppStrings.onlyMembersCanViewDescription,
                  ),
                  value: controller.isPrivate.value,
                  onChanged: (value) => controller.isPrivate.value = value,
                ),
              ),
              const SizedBox(height: 24),

              // Community Files Section
              Text(
                'Topluluk Dosyaları',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              AdvancedFileUpload(
                userId: Get.find<AuthRepository>().currentUser?.uid ?? '',
                conversationId:
                    'community_create_${DateTime.now().millisecondsSinceEpoch}',
                onFilesSelected: (files) {
                  // Handle selected files
                  print('Selected community files: ${files.length}');
                },
                onFileUploaded: (attachment) {
                  // Handle uploaded file
                  print('Uploaded community file: ${attachment.name}');
                },
                onUploadCancelled: (messageId) {
                  // Handle cancelled upload
                  print('Cancelled community upload: $messageId');
                },
                customTitle: 'Topluluk Dosyası Ekle',
                customSubtitle:
                    'Topluluk kuralları, dokümantasyon veya diğer dosyaları yükleyin',
                allowedExtensions: [
                  'pdf',
                  'doc',
                  'docx',
                  'txt',
                  'jpg',
                  'jpeg',
                  'png'
                ],
                maxFileSizeMB: 10,
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
                        : Text(AppStrings.createCommunity),
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
