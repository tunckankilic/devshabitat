import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/filter_controller.dart';
import '../../../core/widgets/skill_chip.dart';

class AdvancedFiltersScreen extends GetView<FilterController> {
  const AdvancedFiltersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelişmiş Filtreler'),
        actions: [
          TextButton(
            onPressed: controller.resetFilters,
            child: const Text('Sıfırla'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSkillsSection(),
            const SizedBox(height: 24),
            _buildLocationSection(),
            const SizedBox(height: 24),
            _buildExperienceSection(),
            const SizedBox(height: 24),
            _buildCompanySection(),
            const SizedBox(height: 24),
            _buildOnlineStatusSection(),
            const SizedBox(height: 24),
            _buildSavedFiltersSection(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              controller.applyFilters();
              Get.back();
            },
            child: const Text('Filtreleri Uygula'),
          ),
        ),
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yetenekler',
          style: Get.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.selectedSkills
                  .map((skill) => Chip(
                        label: Text(skill),
                        onDeleted: () => controller.removeSkill(skill),
                      ))
                  .toList(),
            )),
        const SizedBox(height: 8),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            return controller.availableSkills
                .where((skill) => skill
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase()))
                .toList();
          },
          onSelected: controller.addSkill,
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: const InputDecoration(
                hintText: 'Yetenek ara...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Konum',
          style: Get.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.locationController,
          decoration: const InputDecoration(
            hintText: 'Şehir veya ülke girin',
            prefixIcon: Icon(Icons.location_on),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            Text(
              'Mesafe: ${controller.radius.value.toInt()} km',
              style: Get.textTheme.bodyMedium,
            ),
            Obx(() => Slider(
                  value: controller.radius.value,
                  min: 0,
                  max: 500,
                  divisions: 50,
                  label: '${controller.radius.value.toInt()} km',
                  onChanged: controller.updateRadius,
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildExperienceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deneyim',
          style: Get.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Obx(() => RangeSlider(
              values: controller.experienceRange.value,
              min: 0,
              max: 20,
              divisions: 20,
              labels: RangeLabels(
                '${controller.experienceRange.value.start.toInt()} yıl',
                '${controller.experienceRange.value.end.toInt()}+ yıl',
              ),
              onChanged: controller.updateExperienceRange,
            )),
      ],
    );
  }

  Widget _buildCompanySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Şirket',
          style: Get.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.companyController,
          decoration: const InputDecoration(
            hintText: 'Şirket adı girin',
            prefixIcon: Icon(Icons.business),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildOnlineStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Çevrimiçi Durumu',
          style: Get.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Obx(() => SwitchListTile(
              title: const Text('Sadece çevrimiçi kullanıcıları göster'),
              value: controller.onlineOnly.value,
              onChanged: controller.updateOnlineOnly,
            )),
      ],
    );
  }

  Widget _buildSavedFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kayıtlı Filtreler',
              style: Get.textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showSaveFilterDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.savedFilters.length,
              itemBuilder: (context, index) {
                final filter = controller.savedFilters[index];
                return ListTile(
                  title: Text(filter.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => controller.deleteFilter(filter),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () => controller.loadFilter(filter),
                      ),
                    ],
                  ),
                );
              },
            )),
      ],
    );
  }

  Future<void> _showSaveFilterDialog(BuildContext context) async {
    final nameController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtreyi Kaydet'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Filtre adı',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                controller.saveFilter(nameController.text);
                Get.back();
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
