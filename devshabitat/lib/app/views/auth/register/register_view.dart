import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controllers/registration_controller.dart';
import '../../../controllers/responsive_controller.dart';
import '../../base/base_view.dart';
import 'steps/basic_info_step.dart';
import 'steps/personal_info_step.dart';
import 'steps/professional_info_step.dart';
import 'steps/skills_info_step.dart';

class RegisterView extends BaseView<RegistrationController> {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget buildView(BuildContext context) {
    final ResponsiveController responsive = Get.find<ResponsiveController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kayıt Ol',
          style: TextStyle(fontSize: 20.sp),
        ),
        leading: Obx(() {
          if (controller.currentStep == RegistrationStep.basicInfo) {
            return IconButton(
              icon: Icon(Icons.close, size: 24.sp),
              onPressed: () => Get.back(),
            );
          }
          return IconButton(
            icon: Icon(Icons.arrow_back, size: 24.sp),
            onPressed: () => controller.goBack(),
          );
        }),
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: _getProgressValue(controller.currentStep),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 16.h),

            // Step Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                _getStepTitle(controller.currentStep),
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: responsive.isTablet
                    ? _buildTabletLayout(controller.currentStep)
                    : _buildCurrentStep(controller.currentStep),
              ),
            ),

            // Bottom Buttons
            if (controller.currentStep != RegistrationStep.completed)
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (controller.currentStep != RegistrationStep.basicInfo)
                      TextButton(
                        onPressed: () => controller.skipCurrentStep(),
                        child: Text(
                          'Bu Adımı Atla',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                    SizedBox(height: 8.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        onPressed: controller.canProceedToNextStep
                            ? () => controller.proceedToNextStep()
                            : null,
                        child: Text(
                          controller.currentStep == RegistrationStep.skillsInfo
                              ? 'Kaydı Tamamla'
                              : 'Devam Et',
                          style: TextStyle(fontSize: 18.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildTabletLayout(RegistrationStep step) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Card(
            margin: EdgeInsets.only(right: 16.w),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kayıt Adımları',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildStepIndicator(
                    'Temel Bilgiler',
                    RegistrationStep.basicInfo,
                    step,
                  ),
                  _buildStepIndicator(
                    'Kişisel Bilgiler',
                    RegistrationStep.personalInfo,
                    step,
                  ),
                  _buildStepIndicator(
                    'Profesyonel Bilgiler',
                    RegistrationStep.professionalInfo,
                    step,
                  ),
                  _buildStepIndicator(
                    'Yetenekler ve Diller',
                    RegistrationStep.skillsInfo,
                    step,
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: _buildCurrentStep(step),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(
    String title,
    RegistrationStep stepEnum,
    RegistrationStep currentStep,
  ) {
    final bool isCompleted = stepEnum.index < currentStep.index;
    final bool isCurrent = stepEnum == currentStep;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isCurrent
            ? Theme.of(Get.context!).primaryColor.withOpacity(0.1)
            : null,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isCompleted
              ? Theme.of(Get.context!).primaryColor
              : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: isCompleted
                ? Theme.of(Get.context!).primaryColor
                : Colors.grey[600],
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCurrent ? Theme.of(Get.context!).primaryColor : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(RegistrationStep step) {
    switch (step) {
      case RegistrationStep.basicInfo:
        return const BasicInfoStep();
      case RegistrationStep.personalInfo:
        return PersonalInfoStep();
      case RegistrationStep.professionalInfo:
        return const ProfessionalInfoStep();
      case RegistrationStep.skillsInfo:
        return const SkillsInfoStep();
      case RegistrationStep.completed:
        return const SizedBox.shrink();
    }
  }

  double _getProgressValue(RegistrationStep step) {
    switch (step) {
      case RegistrationStep.basicInfo:
        return 0.25;
      case RegistrationStep.personalInfo:
        return 0.5;
      case RegistrationStep.professionalInfo:
        return 0.75;
      case RegistrationStep.skillsInfo:
      case RegistrationStep.completed:
        return 1.0;
    }
  }

  String _getStepTitle(RegistrationStep step) {
    switch (step) {
      case RegistrationStep.basicInfo:
        return 'Temel Bilgiler';
      case RegistrationStep.personalInfo:
        return 'Kişisel Bilgiler';
      case RegistrationStep.professionalInfo:
        return 'Profesyonel Bilgiler';
      case RegistrationStep.skillsInfo:
        return 'Yetenekler ve Diller';
      case RegistrationStep.completed:
        return 'Kayıt Tamamlandı';
    }
  }
}
