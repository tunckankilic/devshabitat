import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../controllers/registration_controller.dart';
import '../../../../controllers/responsive_controller.dart';

class ProfessionalInfoStep extends GetView<RegistrationController> {
  const ProfessionalInfoStep({Key? key}) : super(key: key);

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
              labelText: 'İş Ünvanı',
              hintText: 'Örn: Senior Software Developer',
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
              labelText: 'Şirket',
              hintText: 'Çalıştığınız şirket',
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
              labelText: 'Deneyim Yılı',
              hintText: 'Örn: 5',
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
            'Çalışma Tercihleri',
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 18, tablet: 22),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 20)),

          // İş Aramaya Açık
          Obx(() => SwitchListTile(
                title: Text(
                  'İş Aramaya Açık',
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
                  'Uzaktan Çalışmaya Açık',
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
                  'Tam Zamanlı',
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
                  'Yarı Zamanlı',
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
                  'Serbest Çalışma',
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
                  'Staj',
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
}
