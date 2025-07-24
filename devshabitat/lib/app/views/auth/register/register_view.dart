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
          if (controller.currentPageIndex == 0) {
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
            // Progress Bar
            LinearProgressIndicator(
              value: _getProgressValue(),
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
            )),

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
            if (!controller.isLastPage || controller.isLastPage)
              Padding(
                padding: _responsiveController.responsivePadding(all: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!controller.isFirstPage && !controller.isLastPage)
                      TextButton(
                        onPressed: () => controller.skipCurrentPage(),
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
                          controller.isLastPage
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
                  )),
                  _buildStepIndicator(
                    AppStrings.basicInfo,
                    0,
                    controller.currentPageIndex,
                  ),
                  _buildStepIndicator(
                    AppStrings.personalInfo,
                    1,
                    controller.currentPageIndex,
                  ),
                  _buildStepIndicator(
                    AppStrings.professionalInfo,
                    2,
                    controller.currentPageIndex,
                  ),
                  _buildStepIndicator(
                    AppStrings.skillsInfo,
                    3,
                    controller.currentPageIndex,
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: _buildCurrentStep(),
        ),
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

  Widget _buildCurrentStep() {
    switch (controller.currentPageIndex) {
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

  double _getProgressValue() {
    return (controller.currentPageIndex + 1) / 4;
  }

  String _getStepTitle() {
    switch (controller.currentPageIndex) {
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
