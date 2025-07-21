import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/registration_controller.dart';
import '../../../controllers/responsive_controller.dart';
import 'steps/basic_info_step.dart';
import 'steps/personal_info_step.dart';
import 'steps/professional_info_step.dart';
import 'steps/skills_info_step.dart';

class RegisterView extends GetView<RegistrationController> {
  final _responsiveController = Get.find<ResponsiveController>();

  RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kayıt Ol',
          style: TextStyle(
            fontSize: _responsiveController.responsiveValue(
              mobile: 20.0,
              tablet: 24.0,
            ),
          ),
        ),
        leading: Obx(() {
          if (controller.currentStep == RegistrationStep.basicInfo) {
            return IconButton(
              icon: Icon(
                Icons.close,
                size: _responsiveController.responsiveValue(
                  mobile: 24.0,
                  tablet: 32.0,
                ),
              ),
              onPressed: () => Get.back(),
            );
          }
          return IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: _responsiveController.responsiveValue(
                mobile: 24.0,
                tablet: 32.0,
              ),
            ),
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
            SizedBox(
                height: _responsiveController.responsiveValue(
              mobile: 16.0,
              tablet: 24.0,
            )),

            // Step Title
            Padding(
              padding: _responsiveController.responsivePadding(
                horizontal: 16.0,
              ),
              child: Text(
                _getStepTitle(controller.currentStep),
                style: TextStyle(
                  fontSize: _responsiveController.responsiveValue(
                    mobile: 24.0,
                    tablet: 32.0,
                  ),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
                height: _responsiveController.responsiveValue(
              mobile: 24.0,
              tablet: 32.0,
            )),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: _responsiveController.responsivePadding(all: 16.0),
                child: _responsiveController.isTablet
                    ? _buildTabletLayout(controller.currentStep)
                    : _buildCurrentStep(controller.currentStep),
              ),
            ),

            // Bottom Buttons
            if (controller.currentStep != RegistrationStep.completed)
              Padding(
                padding: _responsiveController.responsivePadding(all: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (controller.currentStep != RegistrationStep.basicInfo)
                      TextButton(
                        onPressed: () => controller.skipCurrentStep(),
                        child: Text(
                          AppStrings.skipStep,
                          style: TextStyle(
                            fontSize: _responsiveController.responsiveValue(
                              mobile: 16.0,
                              tablet: 18.0,
                            ),
                          ),
                        ),
                      ),
                    SizedBox(
                        height: _responsiveController.responsiveValue(
                      mobile: 8.0,
                      tablet: 12.0,
                    )),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: _responsiveController.responsivePadding(
                            vertical: 16.0,
                          ),
                        ),
                        onPressed: controller.canProceedToNextStep
                            ? () => controller.proceedToNextStep()
                            : null,
                        child: Text(
                          controller.currentStep == RegistrationStep.skillsInfo
                              ? AppStrings.completeRegistration
                              : AppStrings.continueRegistration,
                          style: TextStyle(
                            fontSize: _responsiveController.responsiveValue(
                              mobile: 18.0,
                              tablet: 20.0,
                            ),
                          ),
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
            margin: EdgeInsets.only(
              right: _responsiveController.responsiveValue(
                mobile: 16.0,
                tablet: 24.0,
              ),
            ),
            child: Padding(
              padding: _responsiveController.responsivePadding(all: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.registrationSteps,
                    style: TextStyle(
                      fontSize: _responsiveController.responsiveValue(
                        mobile: 20.0,
                        tablet: 24.0,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                      height: _responsiveController.responsiveValue(
                    mobile: 16.0,
                    tablet: 24.0,
                  )),
                  _buildStepIndicator(
                    AppStrings.basicInfo,
                    RegistrationStep.basicInfo,
                    step,
                  ),
                  _buildStepIndicator(
                    AppStrings.personalInfo,
                    RegistrationStep.personalInfo,
                    step,
                  ),
                  _buildStepIndicator(
                    AppStrings.professionalInfo,
                    RegistrationStep.professionalInfo,
                    step,
                  ),
                  _buildStepIndicator(
                    AppStrings.skillsInfo,
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
      margin: EdgeInsets.symmetric(
        vertical: _responsiveController.responsiveValue(
          mobile: 8.0,
          tablet: 12.0,
        ),
      ),
      padding: _responsiveController.responsivePadding(all: 12.0),
      decoration: BoxDecoration(
        color: isCurrent
            ? Theme.of(Get.context!).primaryColor.withOpacity(0.1)
            : null,
        borderRadius: BorderRadius.circular(
          _responsiveController.responsiveValue(
            mobile: 8.0,
            tablet: 12.0,
          ),
        ),
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
            size: _responsiveController.responsiveValue(
              mobile: 20.0,
              tablet: 24.0,
            ),
          ),
          SizedBox(
              width: _responsiveController.responsiveValue(
            mobile: 12.0,
            tablet: 16.0,
          )),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: _responsiveController.responsiveValue(
                  mobile: 16.0,
                  tablet: 18.0,
                ),
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
        return BasicInfoStep();
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
        return AppStrings.basicInfo;
      case RegistrationStep.personalInfo:
        return AppStrings.personalInfo;
      case RegistrationStep.professionalInfo:
        return AppStrings.professionalInfo;
      case RegistrationStep.skillsInfo:
        return AppStrings.skillsInfo;
      case RegistrationStep.completed:
        return AppStrings.completed;
    }
  }
}
