import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../controllers/registration_controller.dart';

class ProfessionalInfoStep extends GetView<RegistrationController> {
  const ProfessionalInfoStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İş Ünvanı
          TextFormField(
            controller: controller.titleController,
            decoration: InputDecoration(
              labelText: 'İş Ünvanı',
              hintText: 'Örn: Senior Software Developer',
              prefixIcon: Icon(Icons.work, size: 24.sp),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
            style: TextStyle(fontSize: 16.sp),
          ),
          SizedBox(height: 16.h),

          // Şirket
          TextFormField(
            controller: controller.companyController,
            decoration: InputDecoration(
              labelText: 'Şirket',
              hintText: 'Çalıştığınız şirket',
              prefixIcon: Icon(Icons.business, size: 24.sp),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
            style: TextStyle(fontSize: 16.sp),
          ),
          SizedBox(height: 16.h),

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
              prefixIcon: Icon(Icons.timeline, size: 24.sp),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
            style: TextStyle(fontSize: 16.sp),
          ),
          SizedBox(height: 24.h),

          // Çalışma Tercihleri
          Text(
            'Çalışma Tercihleri',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          // İş Aramaya Açık
          Obx(() => SwitchListTile(
                title: Text(
                  'İş Aramaya Açık',
                  style: TextStyle(fontSize: 16.sp),
                ),
                value: controller.isAvailableForWork.value,
                onChanged: (value) =>
                    controller.isAvailableForWork.value = value,
              )),

          // Uzaktan Çalışma
          Obx(() => SwitchListTile(
                title: Text(
                  'Uzaktan Çalışmaya Açık',
                  style: TextStyle(fontSize: 16.sp),
                ),
                value: controller.isRemote.value,
                onChanged: (value) => controller.isRemote.value = value,
              )),

          // Tam Zamanlı
          Obx(() => SwitchListTile(
                title: Text(
                  'Tam Zamanlı',
                  style: TextStyle(fontSize: 16.sp),
                ),
                value: controller.isFullTime.value,
                onChanged: (value) => controller.isFullTime.value = value,
              )),

          // Yarı Zamanlı
          Obx(() => SwitchListTile(
                title: Text(
                  'Yarı Zamanlı',
                  style: TextStyle(fontSize: 16.sp),
                ),
                value: controller.isPartTime.value,
                onChanged: (value) => controller.isPartTime.value = value,
              )),

          // Serbest Çalışma
          Obx(() => SwitchListTile(
                title: Text(
                  'Serbest Çalışma',
                  style: TextStyle(fontSize: 16.sp),
                ),
                value: controller.isFreelance.value,
                onChanged: (value) => controller.isFreelance.value = value,
              )),

          // Staj
          Obx(() => SwitchListTile(
                title: Text(
                  'Staj',
                  style: TextStyle(fontSize: 16.sp),
                ),
                value: controller.isInternship.value,
                onChanged: (value) => controller.isInternship.value = value,
              )),

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
}
