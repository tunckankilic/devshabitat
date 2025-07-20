import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/registration_controller.dart';
import '../../../../controllers/responsive_controller.dart';

class SkillsInfoStep extends GetView<RegistrationController> {
  const SkillsInfoStep({Key? key}) : super(key: key);

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
            'Yetenekler',
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 18, tablet: 22),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
          Wrap(
            spacing: responsive.responsiveValue(mobile: 8, tablet: 12),
            runSpacing: responsive.responsiveValue(mobile: 8, tablet: 12),
            children: [
              ...controller.selectedSkills.map(
                (skill) => Chip(
                  label: Text(
                    skill,
                    style: TextStyle(
                        fontSize:
                            responsive.responsiveValue(mobile: 14, tablet: 16)),
                  ),
                  onDeleted: () => controller.selectedSkills.remove(skill),
                ),
              ),
              ActionChip(
                label: Icon(Icons.add,
                    size: responsive.responsiveValue(mobile: 20, tablet: 24)),
                onPressed: () => _showAddDialog(
                    context, 'Yetenek', controller.selectedSkills),
              ),
            ],
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),

          // Programlama Dilleri
          Text(
            'Programlama Dilleri',
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 18, tablet: 22),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
          Wrap(
            spacing: responsive.responsiveValue(mobile: 8, tablet: 12),
            runSpacing: responsive.responsiveValue(mobile: 8, tablet: 12),
            children: [
              ...controller.selectedLanguages.map(
                (language) => Chip(
                  label: Text(
                    language,
                    style: TextStyle(
                        fontSize:
                            responsive.responsiveValue(mobile: 14, tablet: 16)),
                  ),
                  onDeleted: () =>
                      controller.selectedLanguages.remove(language),
                ),
              ),
              ActionChip(
                label: Icon(Icons.add,
                    size: responsive.responsiveValue(mobile: 20, tablet: 24)),
                onPressed: () => _showAddDialog(
                    context, 'Programlama Dili', controller.selectedLanguages),
              ),
            ],
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),

          // İlgi Alanları
          Text(
            'İlgi Alanları',
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 18, tablet: 22),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
          Wrap(
            spacing: responsive.responsiveValue(mobile: 8, tablet: 12),
            runSpacing: responsive.responsiveValue(mobile: 8, tablet: 12),
            children: [
              ...controller.selectedInterests.map(
                (interest) => Chip(
                  label: Text(
                    interest,
                    style: TextStyle(
                        fontSize:
                            responsive.responsiveValue(mobile: 14, tablet: 16)),
                  ),
                  onDeleted: () =>
                      controller.selectedInterests.remove(interest),
                ),
              ),
              ActionChip(
                label: Icon(Icons.add,
                    size: responsive.responsiveValue(mobile: 20, tablet: 24)),
                onPressed: () => _showAddDialog(
                    context, 'İlgi Alanı', controller.selectedInterests),
              ),
            ],
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),

          // Sosyal Medya Bağlantıları
          Text(
            'Sosyal Medya Bağlantıları',
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
            'Portfolyo URL\'leri',
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 18, tablet: 22),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
          Wrap(
            spacing: responsive.responsiveValue(mobile: 8, tablet: 12),
            runSpacing: responsive.responsiveValue(mobile: 8, tablet: 12),
            children: [
              ...controller.portfolioUrls.map(
                (url) => Chip(
                  label: Text(
                    url,
                    style: TextStyle(
                        fontSize:
                            responsive.responsiveValue(mobile: 14, tablet: 16)),
                  ),
                  onDeleted: () => controller.portfolioUrls.remove(url),
                ),
              ),
              ActionChip(
                label: Icon(Icons.add,
                    size: responsive.responsiveValue(mobile: 20, tablet: 24)),
                onPressed: () => _showAddDialog(
                    context, 'Portfolyo URL', controller.portfolioUrls),
              ),
            ],
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),

          // Bilgilendirme Metni
          Text(
            'Bu bilgileri daha sonra profilinizden güncelleyebilirsiniz.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: responsive.responsiveValue(mobile: 12, tablet: 14),
            ),
          ),
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
        hintText: '$label profilinizin URL\'si',
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
          '$type Ekle',
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
              'İptal',
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
              'Ekle',
              style: TextStyle(
                  fontSize: responsive.responsiveValue(mobile: 16, tablet: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
