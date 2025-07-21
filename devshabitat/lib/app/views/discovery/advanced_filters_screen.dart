import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/filter_controller.dart';
import '../../controllers/responsive_controller.dart';
import '../../services/responsive_performance_service.dart';
import '../../widgets/responsive/responsive_text.dart';

class AdvancedFiltersScreen extends GetView<FilterController> {
  const AdvancedFiltersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText(
          AppStrings.advancedFilters,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 18,
              tablet: 22,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: controller.resetFilters,
            child: ResponsiveText(
              AppStrings.reset,
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 16,
                  tablet: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: performanceService.getOptimizedPadding(
          cacheKey: 'advanced_filters_body_padding',
          all: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSkillsSection(),
            SizedBox(
              height: responsive.responsiveValue(
                mobile: 24,
                tablet: 32,
              ),
            ),
            _buildLocationSection(),
            SizedBox(
              height: responsive.responsiveValue(
                mobile: 24,
                tablet: 32,
              ),
            ),
            _buildExperienceSection(),
            SizedBox(
              height: responsive.responsiveValue(
                mobile: 24,
                tablet: 32,
              ),
            ),
            _buildCompanySection(),
            SizedBox(
              height: responsive.responsiveValue(
                mobile: 24,
                tablet: 32,
              ),
            ),
            _buildOnlineStatusSection(),
            SizedBox(
              height: responsive.responsiveValue(
                mobile: 24,
                tablet: 32,
              ),
            ),
            _buildSavedFiltersSection(context),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: performanceService.getOptimizedPadding(
            cacheKey: 'bottom_button_padding',
            all: 16,
          ),
          child: ElevatedButton(
            onPressed: () {
              controller.applyFilters();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              padding: performanceService.getOptimizedPadding(
                cacheKey: 'apply_button_padding',
                horizontal: 24,
                vertical: 16,
              ),
            ),
            child: ResponsiveText(
              AppStrings.applyFilters,
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 16,
                  tablet: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkillsSection() {
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          AppStrings.skills,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 18,
              tablet: 20,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: responsive.responsiveValue(
            mobile: 8,
            tablet: 12,
          ),
        ),
        Obx(() => Wrap(
              spacing: responsive.responsiveValue(
                mobile: 8,
                tablet: 12,
              ),
              runSpacing: responsive.responsiveValue(
                mobile: 8,
                tablet: 12,
              ),
              children: controller.selectedSkills
                  .map((skill) => Chip(
                        label: ResponsiveText(
                          skill,
                          style: TextStyle(
                            fontSize: responsive.responsiveValue(
                              mobile: 12,
                              tablet: 14,
                            ),
                          ),
                        ),
                        onDeleted: () => controller.removeSkill(skill),
                        padding: performanceService.getOptimizedPadding(
                          cacheKey: 'skill_chip_padding',
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ))
                  .toList(),
            )),
        SizedBox(
          height: responsive.responsiveValue(
            mobile: 8,
            tablet: 12,
          ),
        ),
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
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 16,
                  tablet: 18,
                ),
              ),
              decoration: InputDecoration(
                hintText: AppStrings.searchSkills,
                hintStyle: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 16,
                    tablet: 18,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: responsive.responsiveValue(
                    mobile: 24,
                    tablet: 28,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    responsive.responsiveValue(
                      mobile: 8,
                      tablet: 12,
                    ),
                  ),
                ),
                contentPadding: performanceService.getOptimizedPadding(
                  cacheKey: 'skill_search_padding',
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          AppStrings.location,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 18,
              tablet: 20,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: responsive.responsiveValue(
            mobile: 8,
            tablet: 12,
          ),
        ),
        TextField(
          controller: controller.locationController,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 16,
              tablet: 18,
            ),
          ),
          decoration: InputDecoration(
            hintText: AppStrings.enterCityOrCountry,
            hintStyle: TextStyle(
              fontSize: responsive.responsiveValue(
                mobile: 16,
                tablet: 18,
              ),
            ),
            prefixIcon: Icon(
              Icons.location_on,
              size: responsive.responsiveValue(
                mobile: 24,
                tablet: 28,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                responsive.responsiveValue(
                  mobile: 8,
                  tablet: 12,
                ),
              ),
            ),
            contentPadding: performanceService.getOptimizedPadding(
              cacheKey: 'location_field_padding',
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        SizedBox(
          height: responsive.responsiveValue(
            mobile: 16,
            tablet: 24,
          ),
        ),
        Column(
          children: [
            ResponsiveText(
              'Mesafe: ${controller.radius.value.toInt()} km',
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 14,
                  tablet: 16,
                ),
              ),
            ),
            Obx(() => Slider(
                  value: controller.radius.value,
                  min: 0,
                  max: 500,
                  divisions: 50,
                  label: '${controller.radius.value.toInt()} km',
                  onChanged: controller.updateRadius,
                  activeColor: Theme.of(Get.context!).primaryColor,
                  inactiveColor:
                      Theme.of(Get.context!).primaryColor.withOpacity(0.3),
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildExperienceSection() {
    final responsive = Get.find<ResponsiveController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          AppStrings.experience,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 18,
              tablet: 20,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: responsive.responsiveValue(
            mobile: 16,
            tablet: 24,
          ),
        ),
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
              activeColor: Theme.of(Get.context!).primaryColor,
              inactiveColor:
                  Theme.of(Get.context!).primaryColor.withOpacity(0.3),
            )),
      ],
    );
  }

  Widget _buildCompanySection() {
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          AppStrings.company,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 18,
              tablet: 20,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: responsive.responsiveValue(
            mobile: 8,
            tablet: 12,
          ),
        ),
        TextField(
          controller: controller.companyController,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 16,
              tablet: 18,
            ),
          ),
          decoration: InputDecoration(
            hintText: AppStrings.enterCompanyName,
            hintStyle: TextStyle(
              fontSize: responsive.responsiveValue(
                mobile: 16,
                tablet: 18,
              ),
            ),
            prefixIcon: Icon(
              Icons.business,
              size: responsive.responsiveValue(
                mobile: 24,
                tablet: 28,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                responsive.responsiveValue(
                  mobile: 8,
                  tablet: 12,
                ),
              ),
            ),
            contentPadding: performanceService.getOptimizedPadding(
              cacheKey: 'company_field_padding',
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOnlineStatusSection() {
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          AppStrings.onlineStatus,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 18,
              tablet: 20,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: responsive.responsiveValue(
            mobile: 8,
            tablet: 12,
          ),
        ),
        Obx(() => SwitchListTile(
              title: ResponsiveText(
                AppStrings.showOnlyOnlineUsers,
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 14,
                    tablet: 16,
                  ),
                ),
              ),
              value: controller.onlineOnly.value,
              onChanged: controller.updateOnlineOnly,
              contentPadding: performanceService.getOptimizedPadding(
                cacheKey: 'online_status_padding',
                horizontal: 0,
                vertical: 8,
              ),
            )),
      ],
    );
  }

  Widget _buildSavedFiltersSection(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ResponsiveText(
              AppStrings.savedFilters,
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 18,
                  tablet: 20,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.add,
                size: responsive.responsiveValue(
                  mobile: 24,
                  tablet: 28,
                ),
              ),
              onPressed: () => _showSaveFilterDialog(context),
            ),
          ],
        ),
        SizedBox(
          height: responsive.responsiveValue(
            mobile: 8,
            tablet: 12,
          ),
        ),
        Obx(() => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.savedFilters.length,
              itemBuilder: (context, index) {
                final filter = controller.savedFilters[index];
                return ListTile(
                  title: ResponsiveText(
                    filter.name,
                    style: TextStyle(
                      fontSize: responsive.responsiveValue(
                        mobile: 14,
                        tablet: 16,
                      ),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: responsive.responsiveValue(
                            mobile: 20,
                            tablet: 24,
                          ),
                        ),
                        onPressed: () => controller.deleteFilter(filter),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.check,
                          size: responsive.responsiveValue(
                            mobile: 20,
                            tablet: 24,
                          ),
                        ),
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
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();
    final nameController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ResponsiveText(
          AppStrings.saveFilter,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 18,
              tablet: 22,
            ),
          ),
        ),
        content: TextField(
          controller: nameController,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 16,
              tablet: 18,
            ),
          ),
          decoration: InputDecoration(
            hintText: AppStrings.filterName,
            hintStyle: TextStyle(
              fontSize: responsive.responsiveValue(
                mobile: 16,
                tablet: 18,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                responsive.responsiveValue(
                  mobile: 8,
                  tablet: 12,
                ),
              ),
            ),
            contentPadding: performanceService.getOptimizedPadding(
              cacheKey: 'save_filter_field_padding',
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: ResponsiveText(
              AppStrings.cancel,
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 16,
                  tablet: 18,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                controller.saveFilter(nameController.text);
                Get.back();
              }
            },
            child: ResponsiveText(
              AppStrings.save,
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 16,
                  tablet: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
