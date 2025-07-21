import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/profile_controller.dart';

class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.editProfile),
        actions: [
          TextButton(
            onPressed: () async {
              await controller.updateProfile();
              Get.back();
            },
            child: Text(AppStrings.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profil Fotoğrafı
            Center(
              child: Stack(
                children: [
                  Obx(() {
                    final photoUrl = controller.user?.photoURL;
                    return Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                      child: photoUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            )
                          : ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: photoUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                    );
                  }),
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

            // Ad Soyad
            TextFormField(
              controller: controller.nameController,
              decoration: InputDecoration(
                labelText: AppStrings.name,
                hintText: AppStrings.nameHint,
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Ünvan
            TextFormField(
              controller: controller.titleController,
              decoration: InputDecoration(
                labelText: AppStrings.title,
                hintText: AppStrings.titleHint,
                prefixIcon: Icon(Icons.work),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Şirket
            TextFormField(
              controller: controller.companyController,
              decoration: const InputDecoration(
                labelText: AppStrings.company,
                hintText: AppStrings.companyHint,
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Bio
            TextFormField(
              controller: controller.bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: AppStrings.bio,
                hintText: AppStrings.bioHint,
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            // Konum
            TextFormField(
              controller: controller.locationController,
              decoration: InputDecoration(
                labelText: AppStrings.location,
                hintText: AppStrings.locationHint,
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // GitHub Kullanıcı Adı
            TextFormField(
              controller: controller.githubUsernameController,
              decoration: InputDecoration(
                labelText: AppStrings.githubUsername,
                hintText: AppStrings.githubUsernameHint,
                prefixIcon: Icon(Icons.code),
                border: OutlineInputBorder(),
              ),
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
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 80,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: AppStrings.editProfileImage,
              toolbarColor: Get.theme.primaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
            ),
            IOSUiSettings(
              title: AppStrings.editProfileImage,
              aspectRatioLockEnabled: true,
              minimumAspectRatio: 1.0,
            ),
          ],
        );

        if (croppedFile != null) {
          await controller.updateProfilePhoto(croppedFile.path);
        }
      }
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        AppStrings.errorOccurredWhileSelectingImage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
