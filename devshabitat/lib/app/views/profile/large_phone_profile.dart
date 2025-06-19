import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/image_upload_controller.dart';
import '../../controllers/github_integration_controller.dart';
import 'widgets/skill_chip_grid.dart';
import 'widgets/responsive_image_picker.dart';
import 'widgets/github_repo_card.dart';

class LargePhoneProfile extends StatelessWidget {
  final ProfileController profileController;
  final _imageUploadController = Get.put(ImageUploadController());
  final _githubController = Get.put(GithubIntegrationController());

  LargePhoneProfile({
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst Kısım: Profil Resmi ve Temel Bilgiler
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profil Resmi
                  ResponsiveImagePicker(
                    imageUploadController: _imageUploadController,
                    size: 150,
                  ),
                  const SizedBox(width: 24),

                  // Temel Bilgiler
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          profile.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.location_on),
                            const SizedBox(width: 8),
                            Text(
                              profile.location,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.work),
                            const SizedBox(width: 8),
                            Text(
                              'Deneyim: ${profile.experienceLevel.toString().split('.').last}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Bio
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hakkımda',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profile.bio,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Yetenekler
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yetenekler',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      SkillChipGrid(
                        skills: profileController.skills,
                        isVertical: false,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // GitHub Entegrasyonu
              if (_githubController.isConnected) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GitHub İstatistikleri',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        if (_githubController.githubStats != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                context,
                                'Toplam Repo',
                                _githubController.githubStats!.totalRepositories
                                    .toString(),
                                Icons.folder,
                              ),
                              _buildStatItem(
                                context,
                                'Toplam Katkı',
                                _githubController
                                    .githubStats!.totalContributions
                                    .toString(),
                                Icons.code,
                              ),
                              _buildStatItem(
                                context,
                                'Takipçi',
                                _githubController.githubStats!.followers
                                    .toString(),
                                Icons.people,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Popüler Repolar',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          ..._githubController.githubStats!.recentRepositories
                              .map((repo) => GithubRepoCard(repo: repo))
                              ,
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // İlgi Alanları
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'İlgi Alanları',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: profile.interests
                            .map((interest) => Chip(
                                  label: Text(interest),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Portfolyo Linkleri
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Portfolyo',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ...profile.portfolioLinks.map((link) => ListTile(
                            leading: const Icon(Icons.link),
                            title: Text(link),
                            trailing: const Icon(Icons.open_in_new),
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

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
