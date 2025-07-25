import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/registration_controller.dart';
import '../../../../controllers/responsive_controller.dart';

class SkillsInfoStep extends GetView<RegistrationController> {
  const SkillsInfoStep({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return SingleChildScrollView(
      padding: responsive.responsivePadding(all: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Yetenekler
          Text(
            AppStrings.skills,
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 18, tablet: 22),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
          Obx(() => Wrap(
                spacing: responsive.responsiveValue(mobile: 8, tablet: 12),
                runSpacing: responsive.responsiveValue(mobile: 8, tablet: 12),
                children: [
                  ...controller.selectedSkills.map(
                    (skill) => Chip(
                      label: Text(
                        skill,
                        style: TextStyle(
                            fontSize: responsive.responsiveValue(
                                mobile: 14, tablet: 16)),
                      ),
                      onDeleted: () => controller.selectedSkills.remove(skill),
                    ),
                  ),
                  ActionChip(
                    label: Icon(Icons.add,
                        size:
                            responsive.responsiveValue(mobile: 20, tablet: 24)),
                    onPressed: () => _showAddDialog(
                        context, AppStrings.skill, controller.selectedSkills),
                  ),
                ],
              )),
          SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),

          // Programlama Dilleri
          Text(
            AppStrings.programmingLanguages,
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 18, tablet: 22),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
          Obx(() => Wrap(
                spacing: responsive.responsiveValue(mobile: 8, tablet: 12),
                runSpacing: responsive.responsiveValue(mobile: 8, tablet: 12),
                children: [
                  ...controller.selectedLanguages.map(
                    (language) => Chip(
                      label: Text(
                        language,
                        style: TextStyle(
                            fontSize: responsive.responsiveValue(
                                mobile: 14, tablet: 16)),
                      ),
                      onDeleted: () =>
                          controller.selectedLanguages.remove(language),
                    ),
                  ),
                  ActionChip(
                    label: Icon(Icons.add,
                        size:
                            responsive.responsiveValue(mobile: 20, tablet: 24)),
                    onPressed: () => _showAddDialog(
                        context,
                        AppStrings.programmingLanguage,
                        controller.selectedLanguages),
                  ),
                ],
              )),
          SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),

          // İlgi Alanları
          Text(
            AppStrings.interests,
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 18, tablet: 22),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
          Obx(() => Wrap(
                spacing: responsive.responsiveValue(mobile: 8, tablet: 12),
                runSpacing: responsive.responsiveValue(mobile: 8, tablet: 12),
                children: [
                  ...controller.selectedInterests.map(
                    (interest) => Chip(
                      label: Text(
                        interest,
                        style: TextStyle(
                            fontSize: responsive.responsiveValue(
                                mobile: 14, tablet: 16)),
                      ),
                      onDeleted: () =>
                          controller.selectedInterests.remove(interest),
                    ),
                  ),
                  ActionChip(
                    label: Icon(Icons.add,
                        size:
                            responsive.responsiveValue(mobile: 20, tablet: 24)),
                    onPressed: () => _showAddDialog(context,
                        AppStrings.interest, controller.selectedInterests),
                  ),
                ],
              )),
          SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),

          // Sosyal Medya Bağlantıları
          Text(
            AppStrings.socialMediaLinks,
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 18, tablet: 22),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 20)),
          _buildSocialLinkField('LinkedIn', 'linkedin'),
          SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
          _buildSocialLinkField('GitHub', 'github'),
          SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
          _buildSocialLinkField('Twitter', 'twitter'),
          SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),

          // Portfolyo URL'leri
          Text(
            AppStrings.portfolioUrls,
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 18, tablet: 22),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
          Obx(() => Wrap(
                spacing: responsive.responsiveValue(mobile: 8, tablet: 12),
                runSpacing: responsive.responsiveValue(mobile: 8, tablet: 12),
                children: [
                  ...controller.portfolioUrls.map(
                    (url) => Chip(
                      label: Text(
                        url,
                        style: TextStyle(
                            fontSize: responsive.responsiveValue(
                                mobile: 14, tablet: 16)),
                      ),
                      onDeleted: () => controller.portfolioUrls.remove(url),
                    ),
                  ),
                  ActionChip(
                    label: Icon(Icons.add,
                        size:
                            responsive.responsiveValue(mobile: 20, tablet: 24)),
                    onPressed: () => _showAddDialog(context,
                        AppStrings.portfolioUrl, controller.portfolioUrls),
                  ),
                ],
              )),
          SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),

          // Bilgilendirme Metni
          Text(
            AppStrings.skillsInfoDescription,
            style: TextStyle(
              color: Colors.grey,
              fontSize: responsive.responsiveValue(mobile: 12, tablet: 14),
            ),
          ),

          // Profile Preview
          _buildProfilePreview(),
        ],
      ),
    );
  }

  Widget _buildSocialLinkField(String label, String key) {
    final responsive = Get.find<ResponsiveController>();

    return TextFormField(
      initialValue: controller.socialLinks[key],
      onChanged: (value) => controller.socialLinks[key] = value,
      decoration: InputDecoration(
        labelText: label,
        hintText: '$label profile URL',
        prefixIcon: Icon(
          key == 'linkedin'
              ? Icons.link
              : key == 'github'
                  ? Icons.code
                  : Icons.alternate_email,
          size: responsive.responsiveValue(mobile: 24, tablet: 28),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              responsive.responsiveValue(mobile: 8, tablet: 12)),
        ),
        contentPadding: responsive.responsivePadding(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      style: TextStyle(
          fontSize: responsive.responsiveValue(mobile: 16, tablet: 18)),
    );
  }

  void _showAddDialog(BuildContext context, String type, RxList<String> list) {
    final textController = TextEditingController();
    final responsive = Get.find<ResponsiveController>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '$type Add',
          style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 18, tablet: 22)),
        ),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            labelText: type,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  responsive.responsiveValue(mobile: 8, tablet: 12)),
            ),
          ),
          style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 16, tablet: 18)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(
                  fontSize: responsive.responsiveValue(mobile: 16, tablet: 18)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                list.add(textController.text);
                Navigator.pop(context);
              }
            },
            child: Text(
              AppStrings.add,
              style: TextStyle(
                  fontSize: responsive.responsiveValue(mobile: 16, tablet: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePreview() {
    final responsive = Get.find<ResponsiveController>();

    return Container(
      margin: responsive.responsivePadding(vertical: 24),
      padding: responsive.responsivePadding(all: 16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview, color: Colors.blue[700]),
              SizedBox(width: 8),
              Text(
                'Profil Önizlemesi',
                style: TextStyle(
                  fontSize: responsive.responsiveValue(mobile: 18, tablet: 20),
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Basic Info Preview
          _buildPreviewSection(
            'Temel Bilgiler',
            [
              'Email: ${controller.emailController.text}',
              'Ad: ${controller.displayNameController.text}',
              'GitHub: ${controller.githubUsername ?? "Bağlanmış"}',
            ],
          ),

          // Personal Info Preview
          if (controller.bioController.text.isNotEmpty ||
              controller.locationNameController.text.isNotEmpty)
            _buildPreviewSection(
              'Kişisel Bilgiler',
              [
                if (controller.bioController.text.isNotEmpty)
                  'Bio: ${controller.bioController.text}',
                if (controller.locationNameController.text.isNotEmpty)
                  'Konum: ${controller.locationNameController.text}',
              ],
            ),

          // Professional Info Preview
          if (controller.titleController.text.isNotEmpty ||
              controller.companyController.text.isNotEmpty)
            _buildPreviewSection(
              'Mesleki Bilgiler',
              [
                if (controller.titleController.text.isNotEmpty)
                  'Pozisyon: ${controller.titleController.text}',
                if (controller.companyController.text.isNotEmpty)
                  'Şirket: ${controller.companyController.text}',
              ],
            ),

          // Skills Preview
          if (controller.selectedSkills.isNotEmpty)
            _buildPreviewSection(
              'Yetenekler',
              [
                'Skills: ${controller.selectedSkills.take(3).join(", ")}${controller.selectedSkills.length > 3 ? "..." : ""}'
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(String title, List<String> items) {
    final responsive = Get.find<ResponsiveController>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 14, tablet: 16),
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 4),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 2),
                child: Text(
                  '• $item',
                  style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 13, tablet: 15),
                    color: Colors.grey[600],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
