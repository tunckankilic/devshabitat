import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/enhanced_form_validation_controller.dart';
import '../../widgets/enhanced_form_field.dart';
import '../../widgets/responsive/responsive_text.dart';

class EnhancedFormTestView extends GetView<EnhancedFormValidationController> {
  const EnhancedFormTestView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final usernameController = TextEditingController();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final urlController = TextEditingController();
    final bioController = TextEditingController();
    final titleController = TextEditingController();
    final companyController = TextEditingController();
    final githubController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Form Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Success Message
              Obx(() => controller.showSuccessMessage
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ResponsiveText(
                              controller.successMessage,
                              style: TextStyle(
                                color: Colors.green[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink()),

              // Form Fields
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ResponsiveText(
                        'Enhanced Form Fields Test',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      EnhancedFormField(
                        fieldType: FieldType.email,
                        controller: emailController,
                        label: 'E-posta',
                        hint: 'ornek@email.com',
                        prefixIcon: Icons.email,
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      EnhancedFormField(
                        fieldType: FieldType.password,
                        controller: passwordController,
                        label: 'Şifre',
                        hint: 'En az 8 karakter',
                        prefixIcon: Icons.lock,
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),

                      // Username Field
                      EnhancedFormField(
                        fieldType: FieldType.username,
                        controller: usernameController,
                        label: 'Kullanıcı Adı',
                        hint: 'kullanici_adi',
                        prefixIcon: Icons.person,
                      ),
                      const SizedBox(height: 16),

                      // Name Field
                      EnhancedFormField(
                        fieldType: FieldType.name,
                        controller: nameController,
                        label: 'Ad Soyad',
                        hint: 'Ad Soyad',
                        prefixIcon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),

                      // Phone Field
                      EnhancedFormField(
                        fieldType: FieldType.phone,
                        controller: phoneController,
                        label: 'Telefon',
                        hint: '+90 555 123 4567',
                        prefixIcon: Icons.phone,
                        required: false,
                      ),
                      const SizedBox(height: 16),

                      // URL Field
                      EnhancedFormField(
                        fieldType: FieldType.url,
                        controller: urlController,
                        label: 'Website',
                        hint: 'https://example.com',
                        prefixIcon: Icons.link,
                        required: false,
                      ),
                      const SizedBox(height: 16),

                      // Bio Field
                      EnhancedFormField(
                        fieldType: FieldType.bio,
                        controller: bioController,
                        label: 'Hakkımda',
                        hint: 'Kendiniz hakkında kısa bir açıklama...',
                        prefixIcon: Icons.description,
                        maxLines: 3,
                        required: false,
                      ),
                      const SizedBox(height: 16),

                      // Title Field
                      EnhancedFormField(
                        fieldType: FieldType.title,
                        controller: titleController,
                        label: 'Ünvan',
                        hint: 'Yazılım Geliştirici',
                        prefixIcon: Icons.work,
                        required: false,
                      ),
                      const SizedBox(height: 16),

                      // Company Field
                      EnhancedFormField(
                        fieldType: FieldType.company,
                        controller: companyController,
                        label: 'Şirket',
                        hint: 'Şirket Adı',
                        prefixIcon: Icons.business,
                        required: false,
                      ),
                      const SizedBox(height: 16),

                      // GitHub Username Field
                      EnhancedFormField(
                        fieldType: FieldType.githubUsername,
                        controller: githubController,
                        label: 'GitHub Kullanıcı Adı',
                        hint: 'kullanici-adi',
                        prefixIcon: Icons.code,
                        required: false,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Form Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ResponsiveText(
                        'Form Durumu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(() => Column(
                            children: [
                              _buildStatusRow(
                                  'E-posta', controller.isEmailValid),
                              _buildStatusRow(
                                  'Şifre', controller.isPasswordValid),
                              _buildStatusRow(
                                  'Kullanıcı Adı', controller.isUsernameValid),
                              _buildStatusRow(
                                  'Ad Soyad', controller.isNameValid),
                              _buildStatusRow(
                                  'Telefon', controller.isPhoneValid),
                              _buildStatusRow('URL', controller.isUrlValid),
                              _buildStatusRow('Bio', controller.isBioValid),
                              _buildStatusRow('Ünvan', controller.isTitleValid),
                              _buildStatusRow(
                                  'Şirket', controller.isCompanyValid),
                              _buildStatusRow(
                                  'GitHub', controller.isGithubUsernameValid),
                              const Divider(),
                              _buildStatusRow(
                                  'Form Geçerli', controller.isFormValid,
                                  isMain: true),
                            ],
                          )),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          controller.isFormValid && !controller.isSubmitting
                              ? () async {
                                  await controller.submitForm(() async {
                                    // Simulate form submission
                                    await Future.delayed(
                                        const Duration(seconds: 2));
                                    return true;
                                  });
                                }
                              : null,
                      icon: controller.isSubmitting
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.send),
                      label: ResponsiveText(
                        controller.isSubmitting
                            ? 'Gönderiliyor...'
                            : 'Formu Gönder',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      controller.resetValidation();
                      emailController.clear();
                      passwordController.clear();
                      usernameController.clear();
                      nameController.clear();
                      phoneController.clear();
                      urlController.clear();
                      bioController.clear();
                      titleController.clear();
                      companyController.clear();
                      githubController.clear();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const ResponsiveText('Sıfırla'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool isValid, {bool isMain = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.error,
            size: 20,
            color: isValid ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          ResponsiveText(
            label,
            style: TextStyle(
              fontSize: isMain ? 16 : 14,
              fontWeight: isMain ? FontWeight.bold : FontWeight.normal,
              color: isMain ? Colors.blue[700] : Colors.grey[700],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isValid ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ResponsiveText(
              isValid ? 'Geçerli' : 'Geçersiz',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isValid ? Colors.green[700] : Colors.red[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
