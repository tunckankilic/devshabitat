import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/community/community_manage_controller.dart';
import '../../widgets/community/member_list_widget.dart';
import '../../widgets/community/membership_request_widget.dart';
import '../../widgets/community/rule_violation_tracker_widget.dart';
import '../../widgets/image_upload_widget.dart';

class CommunityManageView extends GetView<CommunityManageController> {
  const CommunityManageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.communityManagement),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
            tooltip: AppStrings.deleteCommunity,
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
                    'Error: ${controller.error.value}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.loadCommunity,
                    child: Text(AppStrings.retry),
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
                    label: AppStrings.coverPhoto,
                  ),
                  const SizedBox(height: 24),

                  // Topluluk Adı
                  TextFormField(
                    controller: controller.nameController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.communityName,
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
                            : Text(AppStrings.saveChanges),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Üyelik Talepleri
                  if (controller.pendingMembers.isNotEmpty) ...[
                    Text(
                      AppStrings.membershipRequests,
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
                    AppStrings.members,
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
                  const SizedBox(height: 32),

                  // Kurallar Yönetimi
                  Text(
                    'Topluluk Kuralları',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => RuleViolationTrackerWidget(
                      communityId: controller.communityId,
                      userId: Get.arguments['userId'] ?? '',
                      violations: controller.violations,
                      rules: controller.rules,
                      onViolationAction: (violation) {
                        // Violation action handled - refresh violations list
                        controller.loadViolations();
                        Get.snackbar(
                          'İşlem Tamamlandı',
                          'Kural ihlali işlemi gerçekleştirildi',
                          backgroundColor: Colors.green.withOpacity(0.8),
                          colorText: Colors.white,
                        );
                      },
                      isModerator:
                          true, // Community manage view'da sadece admin/moderator erişebilir
                    ),
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
        title: Text(AppStrings.deleteCommunity),
        content: Text(
          AppStrings.deleteCommunityConfirmation,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteCommunity();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}
