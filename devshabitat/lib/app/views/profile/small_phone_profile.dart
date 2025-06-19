import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/image_upload_controller.dart';
import '../../controllers/github_integration_controller.dart';
import 'widgets/skill_chip_grid.dart';
import 'widgets/responsive_image_picker.dart';
import 'widgets/github_repo_card.dart';

class SmallPhoneProfile extends StatelessWidget {
  final ProfileController profileController;
  final _imageUploadController = Get.put(ImageUploadController());
  final _githubController = Get.put(GithubIntegrationController());

  SmallPhoneProfile({
    super.key,
    required this.profileController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (profileController.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final profile = profileController.profile;
      if (profile == null) {
        return const Center(child: Text('Profil bulunamadı'));
      }

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profil Resmi
              Center(
                child: ResponsiveImagePicker(
                  imageUploadController: _imageUploadController,
                  size: 120,
                ),
              ),
              const SizedBox(height: 16),

              // İsim ve Başlık
              Center(
                child: Column(
                  children: [
                    Text(
                      profile.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      profile.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Konum
              ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(profile.location),
              ),

              // Deneyim Seviyesi
              ListTile(
                leading: const Icon(Icons.work),
                title: Text(
                    'Deneyim: ${profile.experienceLevel.toString().split('.').last}'),
              ),

              // Bio
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hakkımda',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(profile.bio),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Yetenekler
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yetenekler',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SkillChipGrid(
                        skills: profileController.skills,
                        isVertical: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // GitHub Entegrasyonu
              if (_githubController.isConnected) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GitHub İstatistikleri',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (_githubController.githubStats != null) ...[
                          Text(
                              'Toplam Repo: ${_githubController.githubStats!.totalRepositories}'),
                          Text(
                              'Toplam Katkı: ${_githubController.githubStats!.totalContributions}'),
                          const SizedBox(height: 8),
                          const Text('Popüler Repolar:'),
                          ..._githubController.githubStats!.recentRepositories
                              .map((repo) => GithubRepoCard(repo: repo))
                              ,
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // İlgi Alanları
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'İlgi Alanları',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profile.interests
                            .map((interest) => Chip(label: Text(interest)))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Portfolyo Linkleri
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Portfolyo',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...profile.portfolioLinks.map((link) => ListTile(
                            leading: const Icon(Icons.link),
                            title: Text(link),
                            onTap: () async {
                              final Uri url = Uri.parse(link);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {
                                Get.snackbar(
                                  'Hata',
                                  'Link açılamadı',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            },
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
