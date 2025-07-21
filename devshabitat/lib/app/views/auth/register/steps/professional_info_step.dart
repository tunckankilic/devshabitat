import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../controllers/registration_controller.dart';
import '../../../../controllers/responsive_controller.dart';

class ProfessionalInfoStep extends GetView<RegistrationController> {
  const ProfessionalInfoStep({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return SingleChildScrollView(
      padding: responsive.responsivePadding(all: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İş Ünvanı
          TextFormField(
            controller: controller.titleController,
            decoration: InputDecoration(
              labelText: AppStrings.job,
              hintText: AppStrings.jobHint,
              prefixIcon: Icon(Icons.work,
                  size: responsive.responsiveValue(mobile: 24, tablet: 28)),
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
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 20)),

          // Şirket
          TextFormField(
            controller: controller.companyController,
            decoration: InputDecoration(
              labelText: AppStrings.company,
              hintText: AppStrings.companyHint,
              prefixIcon: Icon(Icons.business,
                  size: responsive.responsiveValue(mobile: 24, tablet: 28)),
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
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 20)),

          // Deneyim Yılı
          TextFormField(
            controller: controller.yearsOfExperienceController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            decoration: InputDecoration(
              labelText: AppStrings.yearsOfExperience,
              hintText: AppStrings.yearsOfExperienceHint,
              prefixIcon: Icon(Icons.timeline,
                  size: responsive.responsiveValue(mobile: 24, tablet: 28)),
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
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),

          // Çalışma Tercihleri
          Text(
            AppStrings.workPreferences,
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 18, tablet: 22),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 20)),

          // İş Aramaya Açık
          Obx(() => SwitchListTile(
                title: Text(
                  AppStrings.isAvailableForWork,
                  style: TextStyle(
                      fontSize:
                          responsive.responsiveValue(mobile: 16, tablet: 18)),
                ),
                value: controller.isAvailableForWork.value,
                onChanged: (value) =>
                    controller.isAvailableForWork.value = value,
              )),

          // Uzaktan Çalışma
          Obx(() => SwitchListTile(
                title: Text(
                  AppStrings.isRemote,
                  style: TextStyle(
                      fontSize:
                          responsive.responsiveValue(mobile: 16, tablet: 18)),
                ),
                value: controller.isRemote.value,
                onChanged: (value) => controller.isRemote.value = value,
              )),

          // Tam Zamanlı
          Obx(() => SwitchListTile(
                title: Text(
                  AppStrings.isFullTime,
                  style: TextStyle(
                      fontSize:
                          responsive.responsiveValue(mobile: 16, tablet: 18)),
                ),
                value: controller.isFullTime.value,
                onChanged: (value) => controller.isFullTime.value = value,
              )),

          // Yarı Zamanlı
          Obx(() => SwitchListTile(
                title: Text(
                  AppStrings.isPartTime,
                  style: TextStyle(
                      fontSize:
                          responsive.responsiveValue(mobile: 16, tablet: 18)),
                ),
                value: controller.isPartTime.value,
                onChanged: (value) => controller.isPartTime.value = value,
              )),

          // Serbest Çalışma
          Obx(() => SwitchListTile(
                title: Text(
                  AppStrings.isFreelance,
                  style: TextStyle(
                      fontSize:
                          responsive.responsiveValue(mobile: 16, tablet: 18)),
                ),
                value: controller.isFreelance.value,
                onChanged: (value) => controller.isFreelance.value = value,
              )),

          // Staj
          Obx(() => SwitchListTile(
                title: Text(
                  AppStrings.isInternship,
                  style: TextStyle(
                      fontSize:
                          responsive.responsiveValue(mobile: 16, tablet: 18)),
                ),
                value: controller.isInternship.value,
                onChanged: (value) => controller.isInternship.value = value,
              )),

          SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),

          // Bilgilendirme Metni
          Text(
            AppStrings.professionalInfoDescription,
            style: TextStyle(
              color: Colors.grey,
              fontSize: responsive.responsiveValue(mobile: 12, tablet: 14),
            ),
          ),
        ],
      ),
    );
  }
}
