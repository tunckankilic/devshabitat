import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/search_filter_model.dart';

class FilterController extends GetxController {
  final storage = GetStorage();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController companyController = TextEditingController();

  final selectedSkills = <String>[].obs;
  final availableSkills = <String>[
    'Flutter',
    'Dart',
    'Firebase',
    'GetX',
    'React',
    'Node.js',
    'Python',
    'Java',
    'Kotlin',
    'Swift',
    'iOS',
    'Android',
    'Web',
    'UI/UX',
    'DevOps',
  ].obs;

  final radius = 50.0.obs;
  final experienceRange = const RangeValues(0, 5).obs;
  final onlineOnly = false.obs;
  final savedFilters = <SearchFilter>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSavedFilters();
  }

  void loadSavedFilters() {
    final filters = storage.read<List>('saved_filters') ?? [];
    savedFilters.value = filters
        .map(
            (filter) => SearchFilter.fromMap(Map<String, dynamic>.from(filter)))
        .toList();
  }

  void saveFilter(String name) {
    final filter = SearchFilter(
      name: name,
      skills: selectedSkills,
      location: locationController.text,
      radius: radius.value,
      experienceRange: experienceRange.value,
      company: companyController.text,
      onlineOnly: onlineOnly.value,
    );

    savedFilters.add(filter);
    storage.write(
        'saved_filters', savedFilters.map((filter) => filter.toMap()).toList());
  }

  void deleteFilter(SearchFilter filter) {
    savedFilters.remove(filter);
    storage.write(
        'saved_filters', savedFilters.map((filter) => filter.toMap()).toList());
  }

  void loadFilter(SearchFilter filter) {
    selectedSkills.value = filter.skills;
    locationController.text = filter.location ?? '';
    radius.value = filter.radius ?? 50.0;
    experienceRange.value = filter.experienceRange ?? const RangeValues(0, 5);
    companyController.text = filter.company ?? '';
    onlineOnly.value = filter.onlineOnly;
  }

  void addSkill(String skill) {
    if (!selectedSkills.contains(skill)) {
      selectedSkills.add(skill);
    }
  }

  void removeSkill(String skill) {
    selectedSkills.remove(skill);
  }

  void updateRadius(double value) {
    radius.value = value;
  }

  void updateExperienceRange(RangeValues value) {
    experienceRange.value = value;
  }

  void updateOnlineOnly(bool value) {
    onlineOnly.value = value;
  }

  void resetFilters() {
    selectedSkills.clear();
    locationController.clear();
    radius.value = 50.0;
    experienceRange.value = const RangeValues(0, 5);
    companyController.clear();
    onlineOnly.value = false;
  }

  void applyFilters() {
    final filter = SearchFilter(
      name: 'Current',
      skills: selectedSkills,
      location: locationController.text,
      radius: radius.value,
      experienceRange: experienceRange.value,
      company: companyController.text,
      onlineOnly: onlineOnly.value,
    );

    Get.back(result: filter);
  }

  @override
  void onClose() {
    locationController.dispose();
    companyController.dispose();
    super.onClose();
  }
}
