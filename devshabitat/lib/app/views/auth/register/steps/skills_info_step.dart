import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../controllers/registration_controller.dart';

class SkillsInfoStep extends GetView<RegistrationController> {
  const SkillsInfoStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Yetenekler
          Text(
            'Yetenekler',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              ...controller.selectedSkills.map(
                (skill) => Chip(
                  label: Text(
                    skill,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  onDeleted: () => controller.selectedSkills.remove(skill),
                ),
              ),
              ActionChip(
                label: Icon(Icons.add, size: 20.sp),
                onPressed: () => _showAddDialog(
                    context, 'Yetenek', controller.selectedSkills),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Programlama Dilleri
          Text(
            'Programlama Dilleri',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              ...controller.selectedLanguages.map(
                (language) => Chip(
                  label: Text(
                    language,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  onDeleted: () =>
                      controller.selectedLanguages.remove(language),
                ),
              ),
              ActionChip(
                label: Icon(Icons.add, size: 20.sp),
                onPressed: () => _showAddDialog(
                    context, 'Programlama Dili', controller.selectedLanguages),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // İlgi Alanları
          Text(
            'İlgi Alanları',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              ...controller.selectedInterests.map(
                (interest) => Chip(
                  label: Text(
                    interest,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  onDeleted: () =>
                      controller.selectedInterests.remove(interest),
                ),
              ),
              ActionChip(
                label: Icon(Icons.add, size: 20.sp),
                onPressed: () => _showAddDialog(
                    context, 'İlgi Alanı', controller.selectedInterests),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Sosyal Medya Bağlantıları
          Text(
            'Sosyal Medya Bağlantıları',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          _buildSocialLinkField('LinkedIn', 'linkedin'),
          SizedBox(height: 8.h),
          _buildSocialLinkField('GitHub', 'github'),
          SizedBox(height: 8.h),
          _buildSocialLinkField('Twitter', 'twitter'),
          SizedBox(height: 24.h),

          // Portfolyo URL'leri
          Text(
            'Portfolyo URL\'leri',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              ...controller.portfolioUrls.map(
                (url) => Chip(
                  label: Text(
                    url,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  onDeleted: () => controller.portfolioUrls.remove(url),
                ),
              ),
              ActionChip(
                label: Icon(Icons.add, size: 20.sp),
                onPressed: () => _showAddDialog(
                    context, 'Portfolyo URL', controller.portfolioUrls),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Bilgilendirme Metni
          Text(
            'Bu bilgileri daha sonra profilinizden güncelleyebilirsiniz.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinkField(String label, String key) {
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
          size: 24.sp,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
      ),
      style: TextStyle(fontSize: 16.sp),
    );
  }

  void _showAddDialog(BuildContext context, String type, RxList<String> list) {
    final textController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('$type Ekle'),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            labelText: type,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                list.add(textController.text);
                Get.back();
              }
            },
            child: Text('Ekle'),
          ),
        ],
      ),
    );
  }
}
