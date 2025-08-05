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
          if (controller.currentStepIndex == 0) {
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
            onPressed: () => controller.previousPage(),
          );
        }),
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Progress Stepper
            _buildProgressStepper(),
            SizedBox(
              height: _responsiveController.responsiveValue(
                mobile: 16.0,
                tablet: 24.0,
              ),
            ),

            // Step Title
            Padding(
              padding: _responsiveController.responsivePadding(
                horizontal: 16.0,
              ),
              child: Text(
                _getStepTitle(),
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
              ),
            ),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: _responsiveController.responsivePadding(all: 16.0),
                child: _responsiveController.isTablet
                    ? _buildTabletLayout()
                    : _buildCurrentStep(),
              ),
            ),

            // Bottom Buttons
            if (!controller.isLastStep || controller.isLastStep)
              Padding(
                padding: _responsiveController.responsivePadding(all: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!controller.isFirstStep && !controller.isLastStep)
                      TextButton(
                        onPressed: () => controller.skipCurrentStep(),
                        child: Text(AppStrings.skipStep),
                      ),
                    SizedBox(height: 8.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: _responsiveController.responsivePadding(
                            vertical: 16.0,
                          ),
                        ),
                        onPressed: controller.canGoNext
                            ? () => controller.nextPage()
                            : null,
                        child: Text(
                          controller.isLastStep
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

  Widget _buildTabletLayout() {
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
                    ),
                  ),
                  _buildStepIndicator(
                    AppStrings.basicInfo,
                    0,
                    controller.currentStepIndex,
                  ),
                  _buildStepIndicator(
                    AppStrings.personalInfo,
                    1,
                    controller.currentStepIndex,
                  ),
                  _buildStepIndicator(
                    AppStrings.professionalInfo,
                    2,
                    controller.currentStepIndex,
                  ),
                  _buildStepIndicator(
                    AppStrings.skillsInfo,
                    3,
                    controller.currentStepIndex,
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(flex: 2, child: _buildCurrentStep()),
      ],
    );
  }

  Widget _buildStepIndicator(
    String title,
    int stepIndex,
    int currentPageIndex,
  ) {
    final bool isCompleted = stepIndex < currentPageIndex;
    final bool isCurrent = stepIndex == currentPageIndex;

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
          _responsiveController.responsiveValue(mobile: 8.0, tablet: 12.0),
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
            ),
          ),
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

  Widget _buildCurrentStep() {
    switch (controller.currentStepIndex) {
      case 0:
        return BasicInfoStep();
      case 1:
        return PersonalInfoStep();
      case 2:
        return ProfessionalInfoStep();
      case 3:
        return SkillsInfoStep();
      default:
        return BasicInfoStep();
    }
  }

  Widget _buildProgressStepper() {
    final steps = [
      {'title': 'Temel', 'subtitle': 'Email & GitHub'},
      {'title': 'Kişisel', 'subtitle': 'Profil bilgileri'},
      {'title': 'Mesleki', 'subtitle': 'İş deneyimi'},
      {'title': 'Yetenekler', 'subtitle': 'Skills & Projeler'},
    ];

    return Container(
      padding: _responsiveController.responsivePadding(
        horizontal: 16.0,
        vertical: 12.0,
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isCompleted = index < controller.currentStepIndex;
          final isCurrent = index == controller.currentStepIndex;

          return Expanded(
            child: Row(
              children: [
                // Step circle
                Container(
                  width: _responsiveController.responsiveValue(
                    mobile: 32.0,
                    tablet: 40.0,
                  ),
                  height: _responsiveController.responsiveValue(
                    mobile: 32.0,
                    tablet: 40.0,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? Colors.green
                        : isCurrent
                        ? Theme.of(Get.context!).primaryColor
                        : Colors.grey[300],
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: _responsiveController.responsiveValue(
                              mobile: 16.0,
                              tablet: 20.0,
                            ),
                          )
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isCurrent
                                  ? Colors.white
                                  : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                              fontSize: _responsiveController.responsiveValue(
                                mobile: 14.0,
                                tablet: 16.0,
                              ),
                            ),
                          ),
                  ),
                ),

                // Step info
                if (_responsiveController.responsiveValue(
                  mobile: false,
                  tablet: true,
                ))
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            steps[index]['title']!,
                            style: TextStyle(
                              fontSize: _responsiveController.responsiveValue(
                                mobile: 12.0,
                                tablet: 14.0,
                              ),
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isCurrent
                                  ? Theme.of(Get.context!).primaryColor
                                  : Colors.grey[700],
                            ),
                          ),
                          Text(
                            steps[index]['subtitle']!,
                            style: TextStyle(
                              fontSize: _responsiveController.responsiveValue(
                                mobile: 10.0,
                                tablet: 12.0,
                              ),
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Connector line
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: EdgeInsets.symmetric(
                        horizontal: _responsiveController.responsiveValue(
                          mobile: 4.0,
                          tablet: 8.0,
                        ),
                      ),
                      color: isCompleted ? Colors.green : Colors.grey[300],
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  String _getStepTitle() {
    switch (controller.currentStepIndex) {
      case 0:
        return AppStrings.basicInfo;
      case 1:
        return AppStrings.personalInfo;
      case 2:
        return AppStrings.professionalInfo;
      case 3:
        return AppStrings.skillsInfo;
      default:
        return AppStrings.basicInfo;
    }
  }
}
