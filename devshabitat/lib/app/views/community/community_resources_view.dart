import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/community/resource_controller.dart';
import '../../controllers/file_upload_controller.dart';
import '../../models/community/resource_model.dart';
import '../../widgets/adaptive_touch_target.dart';
import '../../widgets/responsive/responsive_safe_area.dart';
import '../../widgets/responsive/responsive_text.dart';
import '../../widgets/responsive/responsive_overflow_handler.dart'
    hide ResponsiveSafeArea, ResponsiveText;
import '../../widgets/responsive/animated_responsive_layout.dart';
import '../../controllers/responsive_controller.dart';
import '../../services/file_storage_service.dart';
import 'dart:io';

class CommunityResourcesView extends StatelessWidget {
  const CommunityResourcesView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return GetBuilder<ResourceController>(
      builder: (controller) {
        return ResponsiveSafeArea(
          child: AnimatedResponsiveLayout(
            mobile: _buildMobileLayout(controller, responsive),
            tablet: _buildTabletLayout(controller, responsive),
            animationDuration: const Duration(milliseconds: 300),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(
      ResourceController controller, ResponsiveController responsive) {
    return Column(
      children: [
        _buildSearchAndFilters(controller, responsive),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.error.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(controller.error.value),
                    ElevatedButton(
                      onPressed: () => controller.loadResources(),
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              );
            }

            return _buildResourceList(controller, responsive);
          }),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(
      ResourceController controller, ResponsiveController responsive) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: _buildFiltersPanel(controller, responsive),
        ),
        SizedBox(width: responsive.responsiveValue(mobile: 16, tablet: 24)),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildSearchBar(controller, responsive),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.error.value.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(controller.error.value),
                          ElevatedButton(
                            onPressed: () => controller.loadResources(),
                            child: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    );
                  }

                  return _buildResourceList(controller, responsive);
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(
      ResourceController controller, ResponsiveController responsive) {
    return Container(
      padding: responsive.responsivePadding(all: 16),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSearchBar(controller, responsive),
          SizedBox(height: responsive.responsiveValue(mobile: 12, tablet: 16)),
          _buildFilterChips(controller, responsive),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
      ResourceController controller, ResponsiveController responsive) {
    return TextField(
      onChanged: (value) {
        controller.searchQuery.value = value;
        controller.loadAllResources();
      },
      decoration: InputDecoration(
        hintText: 'Kaynak ara...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.searchQuery.value.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.searchQuery.value = '';
                  controller.loadAllResources();
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(Get.context!).scaffoldBackgroundColor,
      ),
    );
  }

  Widget _buildFilterChips(
      ResourceController controller, ResponsiveController responsive) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            label: 'Tümü',
            isSelected: controller.selectedType.value == null &&
                controller.selectedCategory.value == null &&
                controller.selectedDifficulty.value == null,
            onTap: () => controller.resetFilters(),
          ),
          SizedBox(width: responsive.responsiveValue(mobile: 8, tablet: 12)),
          ...ResourceType.values.map((type) => _buildFilterChip(
                label: controller.getResourceTypeText(type),
                isSelected: controller.selectedType.value == type,
                onTap: () {
                  controller.selectedType.value = type;
                  controller.loadAllResources();
                },
              )),
          SizedBox(width: responsive.responsiveValue(mobile: 8, tablet: 12)),
          ...ResourceCategory.values.map((category) => _buildFilterChip(
                label: controller.getResourceCategoryText(category),
                isSelected: controller.selectedCategory.value == category,
                onTap: () {
                  controller.selectedCategory.value = category;
                  controller.loadAllResources();
                },
              )),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Theme.of(Get.context!).cardColor,
        selectedColor: Theme.of(Get.context!).primaryColor.withOpacity(0.2),
        checkmarkColor: Theme.of(Get.context!).primaryColor,
      ),
    );
  }

  Widget _buildFiltersPanel(
      ResourceController controller, ResponsiveController responsive) {
    return Container(
      padding: responsive.responsivePadding(all: 16),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'Filtreler',
            style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 24)),

          // Tür Filtresi
          ResponsiveText(
            'Tür',
            style: Theme.of(Get.context!).textTheme.titleSmall,
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
          ...ResourceType.values.map((type) => _buildFilterOption(
                label: controller.getResourceTypeText(type),
                isSelected: controller.selectedType.value == type,
                onTap: () {
                  controller.selectedType.value = type;
                  controller.loadAllResources();
                },
              )),

          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 24)),

          // Kategori Filtresi
          ResponsiveText(
            'Kategori',
            style: Theme.of(Get.context!).textTheme.titleSmall,
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
          ...ResourceCategory.values.map((category) => _buildFilterOption(
                label: controller.getResourceCategoryText(category),
                isSelected: controller.selectedCategory.value == category,
                onTap: () {
                  controller.selectedCategory.value = category;
                  controller.loadAllResources();
                },
              )),

          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 24)),

          // Zorluk Filtresi
          ResponsiveText(
            'Zorluk',
            style: Theme.of(Get.context!).textTheme.titleSmall,
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
          ...ResourceDifficulty.values.map((difficulty) => _buildFilterOption(
                label: controller.getResourceDifficultyText(difficulty),
                isSelected: controller.selectedDifficulty.value == difficulty,
                onTap: () {
                  controller.selectedDifficulty.value = difficulty;
                  controller.loadAllResources();
                },
              )),

          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 24)),

          // Filtreleri Sıfırla
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.resetFilters(),
              child: const Text('Filtreleri Sıfırla'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AdaptiveTouchTarget(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(Get.context!).primaryColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                size: 16,
                color: isSelected
                    ? Theme.of(Get.context!).primaryColor
                    : Colors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color:
                        isSelected ? Theme.of(Get.context!).primaryColor : null,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceList(
      ResourceController controller, ResponsiveController responsive) {
    return ResponsiveOverflowHandler(
      child: CustomScrollView(
        slivers: [
          // Öne Çıkan Kaynaklar
          if (controller.featuredResources.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: responsive.responsivePadding(all: 16),
                child: ResponsiveText(
                  'Öne Çıkan Kaynaklar',
                  style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: responsive.responsivePadding(horizontal: 16),
                  itemCount: controller.featuredResources.length,
                  itemBuilder: (context, index) {
                    return _buildFeaturedResourceCard(
                      controller.featuredResources[index],
                      controller,
                      responsive,
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                  height: responsive.responsiveValue(mobile: 16, tablet: 24)),
            ),
          ],

          // Tüm Kaynaklar
          SliverToBoxAdapter(
            child: Padding(
              padding: responsive.responsivePadding(all: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ResponsiveText(
                    'Tüm Kaynaklar (${controller.resources.length})',
                    style:
                        Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                  _buildAddResourceButton(controller),
                ],
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildResourceCard(
                  controller.resources[index],
                  controller,
                  responsive,
                );
              },
              childCount: controller.resources.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedResourceCard(
    ResourceModel resource,
    ResourceController controller,
    ResponsiveController responsive,
  ) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 4,
        child: InkWell(
          onTap: () => _openResource(resource, controller),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: _getResourceTypeColor(resource.type),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(
                  child: Icon(
                    _getResourceTypeIcon(resource.type),
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.title,
                      style: Theme.of(Get.context!)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resource.description,
                      style: Theme.of(Get.context!).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(
                          label: Text(resource.readableType),
                          backgroundColor: _getResourceTypeColor(resource.type)
                              .withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: _getResourceTypeColor(resource.type),
                            fontSize: 10,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        Text(resource.score.toStringAsFixed(1)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceCard(
    ResourceModel resource,
    ResourceController controller,
    ResponsiveController responsive,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: responsive.responsiveValue(mobile: 16, tablet: 24),
        vertical: responsive.responsiveValue(mobile: 4, tablet: 8),
      ),
      child: InkWell(
        onTap: () => _openResource(resource, controller),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getResourceTypeColor(resource.type),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getResourceTypeIcon(resource.type),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.title,
                      style: Theme.of(Get.context!)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resource.description,
                      style: Theme.of(Get.context!).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(
                          label: Text(resource.readableType),
                          backgroundColor: _getResourceTypeColor(resource.type)
                              .withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: _getResourceTypeColor(resource.type),
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(resource.readableCategory),
                          backgroundColor: Colors.grey.withOpacity(0.1),
                          labelStyle: const TextStyle(fontSize: 10),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(resource.readableDifficulty),
                          backgroundColor:
                              _getDifficultyColor(resource.difficulty)
                                  .withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: _getDifficultyColor(resource.difficulty),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.thumb_up_outlined),
                        onPressed: () =>
                            controller.voteResource(resource.id, true),
                      ),
                      Text('${resource.upvotes}'),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.visibility, size: 16),
                      Text('${resource.views}'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddResourceButton(ResourceController controller) {
    return ElevatedButton.icon(
      onPressed: () => _showAddResourceDialog(controller),
      icon: const Icon(Icons.add),
      label: const Text('Kaynak Ekle'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(Get.context!).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _openResource(ResourceModel resource, ResourceController controller) {
    controller.incrementViews(resource.id);
    controller.selectedResource.value = resource;

    // Kaynak detay dialog'unu göster
    Get.dialog(
      _ResourceDetailDialog(resource: resource, controller: controller),
      barrierDismissible: true,
    );
  }

  void _showAddResourceDialog(ResourceController controller) {
    Get.dialog(
      _AddResourceDialog(controller: controller),
      barrierDismissible: false,
    );
  }

  Color _getResourceTypeColor(ResourceType type) {
    switch (type) {
      case ResourceType.article:
        return Colors.blue;
      case ResourceType.video:
        return Colors.red;
      case ResourceType.tutorial:
        return Colors.green;
      case ResourceType.code:
        return Colors.purple;
      case ResourceType.book:
        return Colors.orange;
      case ResourceType.tool:
        return Colors.teal;
      case ResourceType.other:
        return Colors.grey;
    }
  }

  IconData _getResourceTypeIcon(ResourceType type) {
    switch (type) {
      case ResourceType.article:
        return Icons.article;
      case ResourceType.video:
        return Icons.video_library;
      case ResourceType.tutorial:
        return Icons.school;
      case ResourceType.code:
        return Icons.code;
      case ResourceType.book:
        return Icons.book;
      case ResourceType.tool:
        return Icons.build;
      case ResourceType.other:
        return Icons.link;
    }
  }

  Color _getDifficultyColor(ResourceDifficulty difficulty) {
    switch (difficulty) {
      case ResourceDifficulty.beginner:
        return Colors.green;
      case ResourceDifficulty.intermediate:
        return Colors.orange;
      case ResourceDifficulty.advanced:
        return Colors.red;
      case ResourceDifficulty.expert:
        return Colors.purple;
    }
  }
}

class _ResourceDetailDialog extends StatelessWidget {
  final ResourceModel resource;
  final ResourceController controller;

  const _ResourceDetailDialog({
    required this.resource,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    resource.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Kaynak türü ve kategorisi
            Row(
              children: [
                Chip(
                  label: Text(resource.readableType),
                  backgroundColor:
                      _getResourceTypeColor(resource.type).withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: _getResourceTypeColor(resource.type),
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(resource.readableCategory),
                  backgroundColor: Colors.grey.withOpacity(0.1),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(resource.readableDifficulty),
                  backgroundColor:
                      _getDifficultyColor(resource.difficulty).withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: _getDifficultyColor(resource.difficulty),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Açıklama
            Text(
              'Açıklama',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(resource.description),
            const SizedBox(height: 16),

            // Etiketler
            if (resource.tags.isNotEmpty) ...[
              Text(
                'Etiketler',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: resource.tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          labelStyle: const TextStyle(color: Colors.blue),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],

            // İstatistikler
            Row(
              children: [
                Icon(Icons.visibility, size: 16),
                Text(' ${resource.views} görüntülenme'),
                const SizedBox(width: 16),
                Icon(Icons.thumb_up, size: 16, color: Colors.green),
                Text(' ${resource.upvotes} beğeni'),
                const SizedBox(width: 16),
                Icon(Icons.thumb_down, size: 16, color: Colors.red),
                Text(' ${resource.downvotes} beğenmeme'),
              ],
            ),
            const SizedBox(height: 24),

            // Butonlar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _openUrl(resource.url),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Aç'),
                ),
                ElevatedButton.icon(
                  onPressed: () => controller.voteResource(resource.id, true),
                  icon: const Icon(Icons.thumb_up),
                  label: const Text('Beğen'),
                ),
                ElevatedButton.icon(
                  onPressed: () => controller.voteResource(resource.id, false),
                  icon: const Icon(Icons.thumb_down),
                  label: const Text('Beğenme'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getResourceTypeColor(ResourceType type) {
    switch (type) {
      case ResourceType.article:
        return Colors.blue;
      case ResourceType.video:
        return Colors.red;
      case ResourceType.tutorial:
        return Colors.green;
      case ResourceType.code:
        return Colors.purple;
      case ResourceType.book:
        return Colors.orange;
      case ResourceType.tool:
        return Colors.teal;
      case ResourceType.other:
        return Colors.grey;
    }
  }

  Color _getDifficultyColor(ResourceDifficulty difficulty) {
    switch (difficulty) {
      case ResourceDifficulty.beginner:
        return Colors.green;
      case ResourceDifficulty.intermediate:
        return Colors.orange;
      case ResourceDifficulty.advanced:
        return Colors.red;
      case ResourceDifficulty.expert:
        return Colors.purple;
    }
  }

  void _openUrl(String url) {
    // URL'yi tarayıcıda aç
    // Bu kısım uygulamanın ihtiyacına göre özelleştirilebilir
    print('URL açılıyor: $url');
  }
}

class _AddResourceDialog extends StatefulWidget {
  final ResourceController controller;

  const _AddResourceDialog({required this.controller});

  @override
  State<_AddResourceDialog> createState() => _AddResourceDialogState();
}

class _AddResourceDialogState extends State<_AddResourceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();
  final _tagsController = TextEditingController();

  ResourceType _selectedType = ResourceType.article;
  ResourceCategory _selectedCategory = ResourceCategory.other;
  ResourceDifficulty _selectedDifficulty = ResourceDifficulty.beginner;

  final FileUploadController _fileUploadController =
      Get.find<FileUploadController>();
  File? _selectedFile;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Yeni Kaynak Ekle',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Başlık
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Başlık gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Açıklama
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Açıklama gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // URL
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'URL gerekli';
                  }
                  final uri = Uri.tryParse(value);
                  if (uri == null || !uri.hasAbsolutePath) {
                    return 'Geçerli bir URL girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Dosya Yükleme
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _selectFile,
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                          _selectedFile?.path.split('/').last ?? 'Dosya Seç'),
                    ),
                  ),
                  if (_selectedFile != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _selectedFile = null),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              // Tür Seçimi
              DropdownButtonFormField<ResourceType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tür',
                  border: OutlineInputBorder(),
                ),
                items: ResourceType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(widget.controller.getResourceTypeText(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Kategori Seçimi
              DropdownButtonFormField<ResourceCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: ResourceCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(
                        widget.controller.getResourceCategoryText(category)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Zorluk Seçimi
              DropdownButtonFormField<ResourceDifficulty>(
                value: _selectedDifficulty,
                decoration: const InputDecoration(
                  labelText: 'Zorluk',
                  border: OutlineInputBorder(),
                ),
                items: ResourceDifficulty.values.map((difficulty) {
                  return DropdownMenuItem(
                    value: difficulty,
                    child: Text(widget.controller
                        .getResourceDifficultyText(difficulty)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedDifficulty = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Etiketler
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Etiketler (virgülle ayırın)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Butonlar
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('İptal'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _submitResource,
                    child: const Text('Kaydet'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectFile() async {
    final file = await _fileUploadController.selectFile();
    if (file != null) {
      setState(() => _selectedFile = file);
    }
  }

  Future<void> _submitResource() async {
    if (!_formKey.currentState!.validate()) return;

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    // Dosya yükleme işlemi
    String? fileUrl;
    if (_selectedFile != null) {
      try {
        final fileStorageService = Get.find<FileStorageService>();

        // Dosya boyutu kontrolü
        if (!fileStorageService.isValidFileSize(_selectedFile!,
            maxSizeInMB: 10)) {
          Get.snackbar(
            'Hata',
            'Dosya boyutu 10MB\'dan büyük olamaz',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        // Dosya türü kontrolü
        final allowedExtensions = [
          'pdf',
          'doc',
          'docx',
          'txt',
          'zip',
          'rar',
          'jpg',
          'jpeg',
          'png',
          'gif',
          'mp4',
          'avi',
          'mov'
        ];
        if (!fileStorageService.isValidFileType(
            _selectedFile!.path.split('/').last, allowedExtensions)) {
          Get.snackbar(
            'Hata',
            'Desteklenmeyen dosya türü',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        // Dosyayı yükle
        final uploadTask = await fileStorageService.uploadFile(
          file: _selectedFile!,
          userId: widget.controller.userId,
          conversationId: widget.controller.communityId,
          messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        );

        // Yükleme tamamlanana kadar bekle
        final snapshot = await uploadTask;
        fileUrl = await snapshot.ref.getDownloadURL();
      } catch (e) {
        Get.snackbar(
          'Hata',
          'Dosya yüklenirken bir hata oluştu: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    final resource = ResourceModel(
      id: '', // Firestore tarafından oluşturulacak
      communityId: widget.controller.communityId,
      title: _titleController.text,
      description: _descriptionController.text,
      url: fileUrl ?? _urlController.text,
      authorId: widget.controller.userId,
      type: _selectedType,
      category: _selectedCategory,
      difficulty: _selectedDifficulty,
      tags: tags,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await widget.controller.createResource(resource);
  }
}
