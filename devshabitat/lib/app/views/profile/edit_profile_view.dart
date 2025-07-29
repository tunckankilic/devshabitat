import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/enhanced_form_validation_controller.dart';
import '../../widgets/enhanced_form_field.dart';
import '../../widgets/advanced_file_upload.dart';

class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({super.key});

  EnhancedFormValidationController get _validationController =>
      Get.find<EnhancedFormValidationController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.editProfile),
        actions: [
          Obx(() => TextButton(
                onPressed: controller.isLoading
                    ? null
                    : () async {
                        await controller.updateProfile();
                        Get.back();
                      },
                child: controller.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(AppStrings.save),
              )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: controller.user?.photoURL != null
                        ? CachedNetworkImageProvider(controller.user!.photoURL!)
                        : null,
                    child: controller.user?.photoURL == null
                        ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                        onPressed: () => _showImageSourceDialog(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Portfolio Files Section
            Text(
              'Portfolio Dosyaları',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            AdvancedFileUpload(
              userId: controller.user?.uid ?? '',
              conversationId: 'profile_${controller.user?.uid ?? ''}',
              onFilesSelected: (files) {
                // Handle selected files
                print('Selected files: ${files.length}');
              },
              onFileUploaded: (attachment) {
                // Handle uploaded file
                print('Uploaded file: ${attachment.name}');
              },
              onUploadCancelled: (messageId) {
                // Handle cancelled upload
                print('Cancelled upload: $messageId');
              },
              customTitle: 'Portfolio Dosyası Ekle',
              customSubtitle:
                  'Proje dosyalarınızı, CV\'nizi veya diğer belgelerinizi yükleyin',
              allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
              maxFileSizeMB: 5,
            ),
            const SizedBox(height: 24),

            // Name field with EnhancedFormField
            EnhancedFormField(
              fieldType: FieldType.name,
              controller: controller.nameController,
              label: AppStrings.name,
              hint: AppStrings.nameHint,
              prefixIcon: Icons.person,
              onChanged: (value) {
                _validationController.validateName(value);
              },
            ),
            const SizedBox(height: 16),

            // Title field with EnhancedFormField
            EnhancedFormField(
              fieldType: FieldType.title,
              controller: controller.titleController,
              label: AppStrings.title,
              hint: AppStrings.titleHint,
              prefixIcon: Icons.work,
              required: false,
              onChanged: (value) {
                _validationController.validateTitle(value);
              },
            ),
            const SizedBox(height: 16),

            // Company field with EnhancedFormField
            EnhancedFormField(
              fieldType: FieldType.company,
              controller: controller.companyController,
              label: AppStrings.company,
              hint: AppStrings.companyHint,
              prefixIcon: Icons.business,
              required: false,
              onChanged: (value) {
                _validationController.validateCompany(value);
              },
            ),
            const SizedBox(height: 16),

            // Bio field with EnhancedFormField
            EnhancedFormField(
              fieldType: FieldType.bio,
              controller: controller.bioController,
              label: AppStrings.bio,
              hint: AppStrings.bioHint,
              prefixIcon: Icons.description,
              maxLines: 3,
              required: false,
              onChanged: (value) {
                _validationController.validateBio(value);
              },
            ),
            const SizedBox(height: 16),

            // Location field with EnhancedFormField
            EnhancedFormField(
              fieldType: FieldType.custom,
              controller: controller.locationController,
              label: AppStrings.location,
              hint: AppStrings.locationHint,
              prefixIcon: Icons.location_on,
              required: false,
              customValidator: (value) {
                if (value != null && value.length > 100) {
                  return 'Konum en fazla 100 karakter olabilir';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // GitHub Username field with EnhancedFormField
            EnhancedFormField(
              fieldType: FieldType.githubUsername,
              controller: controller.githubUsernameController,
              label: AppStrings.githubUsername,
              hint: AppStrings.githubUsernameHint,
              prefixIcon: Icons.code,
              required: false,
              onChanged: (value) {
                _validationController.validateGithubUsername(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.selectProfileImage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: Text(AppStrings.camera),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppStrings.gallery),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 85,
          maxWidth: 512,
          maxHeight: 512,
        );

        if (croppedFile != null) {
          // Update the photo URL in the controller
          controller.photoUrlController.text = croppedFile.path;

          Get.snackbar(
            'Başarılı',
            'Profil fotoğrafı güncellendi',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Fotoğraf seçilirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
