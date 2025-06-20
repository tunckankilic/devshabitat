import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/registration_controller.dart';

class SkillsInfoStep extends GetView<RegistrationController> {
  const SkillsInfoStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Skills Section
        const Text(
          'Yetenekler',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...controller.selectedSkills.map(
                  (skill) => Chip(
                    label: Text(skill),
                    onDeleted: () {
                      controller.selectedSkills.remove(skill);
                    },
                  ),
                ),
                ActionChip(
                  label: const Text('+ Yetenek Ekle'),
                  onPressed: () => _showAddDialog(
                    context,
                    'Yetenek',
                    controller.selectedSkills,
                    [
                      'Flutter',
                      'Dart',
                      'Firebase',
                      'React',
                      'Node.js',
                      'Python',
                      'Java',
                      'Kotlin',
                      'Swift',
                      'SQL',
                    ],
                  ),
                ),
              ],
            )),
        const SizedBox(height: 24),

        // Programming Languages Section
        const Text(
          'Programlama Dilleri',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...controller.selectedLanguages.map(
                  (language) => Chip(
                    label: Text(language),
                    onDeleted: () {
                      controller.selectedLanguages.remove(language);
                    },
                  ),
                ),
                ActionChip(
                  label: const Text('+ Dil Ekle'),
                  onPressed: () => _showAddDialog(
                    context,
                    'Programlama Dili',
                    controller.selectedLanguages,
                    [
                      'JavaScript',
                      'Python',
                      'Java',
                      'C++',
                      'C#',
                      'Ruby',
                      'PHP',
                      'Swift',
                      'Kotlin',
                      'Go',
                    ],
                  ),
                ),
              ],
            )),
        const SizedBox(height: 24),

        // Frameworks Section
        const Text(
          'Frameworks',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...controller.selectedFrameworks.map(
                  (framework) => Chip(
                    label: Text(framework),
                    onDeleted: () {
                      controller.selectedFrameworks.remove(framework);
                    },
                  ),
                ),
                ActionChip(
                  label: const Text('+ Framework Ekle'),
                  onPressed: () => _showAddDialog(
                    context,
                    'Framework',
                    controller.selectedFrameworks,
                    [
                      'Flutter',
                      'React',
                      'Angular',
                      'Vue.js',
                      'Django',
                      'Spring',
                      'Laravel',
                      'Express',
                      'ASP.NET',
                      'Ruby on Rails',
                    ],
                  ),
                ),
              ],
            )),
        const SizedBox(height: 24),

        // Info Text
        const Text(
          'Bu bilgileri daha sonra profilinizden güncelleyebilirsiniz.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showAddDialog(
    BuildContext context,
    String title,
    RxList<String> selectedItems,
    List<String> suggestions,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$title Ekle'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final item = suggestions[index];
              final isSelected = selectedItems.contains(item);
              return CheckboxListTile(
                title: Text(item),
                value: isSelected,
                onChanged: (bool? value) {
                  if (value == true) {
                    selectedItems.add(item);
                  } else {
                    selectedItems.remove(item);
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
