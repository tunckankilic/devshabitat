import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/portfolio_controller.dart';
import '../../widgets/feature_gate_widget.dart';

class NewProjectView extends GetView<PortfolioController> {
  const NewProjectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.newProject),
        actions: [
          Obx(() => TextButton(
                onPressed: controller.isProjectFormValid() &&
                        !controller.isCreatingProject.value
                    ? controller.createProjectFromForm
                    : null,
                child: controller.isCreatingProject.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(AppStrings.create),
              )),
        ],
      ),
      body: FeatureGate.wrap(
        feature: 'project_sharing',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Yeni Proje Oluştur',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),

              // Project Title
              Obx(() => TextFormField(
                    onChanged: (value) => controller.projectTitle.value = value,
                    decoration: InputDecoration(
                      labelText: 'Proje Adı *',
                      border: OutlineInputBorder(),
                      errorText: controller.projectTitle.value.trim().isEmpty &&
                              controller.projectCreationError.value.isNotEmpty
                          ? 'Proje adı gereklidir'
                          : null,
                    ),
                  )),
              const SizedBox(height: 16),

              // Project Description
              Obx(() => TextFormField(
                    onChanged: (value) =>
                        controller.projectDescription.value = value,
                    decoration: InputDecoration(
                      labelText: 'Açıklama *',
                      border: OutlineInputBorder(),
                      errorText: controller.projectDescription.value
                                  .trim()
                                  .isEmpty &&
                              controller.projectCreationError.value.isNotEmpty
                          ? 'Proje açıklaması gereklidir'
                          : null,
                    ),
                    maxLines: 3,
                  )),
              const SizedBox(height: 16),

              // Technologies
              Obx(() => TextFormField(
                    onChanged: (value) =>
                        controller.projectTechnologies.value = value,
                    decoration: InputDecoration(
                      labelText: 'Teknolojiler (virgülle ayrılmış) *',
                      border: OutlineInputBorder(),
                      hintText: 'Flutter, Dart, Firebase',
                      errorText: controller.projectTechnologies.value
                                  .trim()
                                  .isEmpty &&
                              controller.projectCreationError.value.isNotEmpty
                          ? 'En az bir teknoloji belirtmelisiniz'
                          : null,
                    ),
                  )),
              const SizedBox(height: 16),

              // Category
              Obx(() => TextFormField(
                    onChanged: (value) =>
                        controller.projectCategory.value = value,
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                      hintText: 'Mobile App, Web App, API',
                    ),
                  )),
              const SizedBox(height: 16),

              // Repository URL
              Obx(() => TextFormField(
                    onChanged: (value) =>
                        controller.projectRepositoryUrl.value = value,
                    decoration: InputDecoration(
                      labelText: 'GitHub Repository URL',
                      border: OutlineInputBorder(),
                      hintText: 'https://github.com/username/project',
                    ),
                    keyboardType: TextInputType.url,
                  )),
              const SizedBox(height: 16),

              // Live URL
              Obx(() => TextFormField(
                    onChanged: (value) =>
                        controller.projectLiveUrl.value = value,
                    decoration: InputDecoration(
                      labelText: 'Canlı URL (Opsiyonel)',
                      border: OutlineInputBorder(),
                      hintText: 'https://your-app.com',
                    ),
                    keyboardType: TextInputType.url,
                  )),
              const SizedBox(height: 24),

              // Form Validation Status
              Obx(() {
                final error = controller.getProjectFormError();
                if (error != null) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            error,
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return SizedBox.shrink();
              }),

              // Success/Error Messages
              Obx(() {
                if (controller.projectCreationError.value.isNotEmpty) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.projectCreationError.value,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }
}
