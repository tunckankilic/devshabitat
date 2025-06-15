import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/image_upload_controller.dart';
import '../../controllers/github_integration_controller.dart';
import 'widgets/skill_chip_grid.dart';
import 'widgets/responsive_image_picker.dart';
import 'widgets/adaptive_progress_indicator.dart';
import 'widgets/github_repo_card.dart';

class TabletProfile extends StatelessWidget {
  final ProfileController profileController;
  final _imageUploadController = Get.put(ImageUploadController());
  final _githubController = Get.put(GithubIntegrationController());

  TabletProfile({
    Key? key,
    required this.profileController,
  }) : super(key: key);

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
          padding: const EdgeInsets.all(32.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sol Kolon: Profil Resmi ve Temel Bilgiler
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    // Profil Resmi
                    ResponsiveImagePicker(
                      imageUploadController: _imageUploadController,
                      size: 200,
                    ),
                    const SizedBox(height: 24),

                    // Temel Bilgiler
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
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
                            ListTile(
                              leading: const Icon(Icons.location_on),
                              title: Text(profile.location),
                            ),
                            ListTile(
                              leading: const Icon(Icons.work),
                              title: Text(
                                'Deneyim: ${profile.experienceLevel.toString().split('.').last}',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

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
                  ],
                ),
              ),

              const SizedBox(width: 32),

              // Sağ Kolon: Detaylı Bilgiler
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bio
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hakkımda',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
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
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Yetenekler',
                              style: Theme.of(context).textTheme.headlineSmall,
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
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GitHub İstatistikleri',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 24),
                              if (_githubController.githubStats != null) ...[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatItem(
                                      context,
                                      'Toplam Repo',
                                      _githubController
                                          .githubStats!.totalRepositories
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
                                const SizedBox(height: 32),
                                Text(
                                  'Popüler Repolar',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 16),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 1.5,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                                  itemCount: _githubController
                                      .githubStats!.recentRepositories.length,
                                  itemBuilder: (context, index) {
                                    final repo = _githubController
                                        .githubStats!.recentRepositories[index];
                                    return GithubRepoCard(repo: repo);
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Portfolyo Linkleri
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Portfolyo',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            ...profile.portfolioLinks.map((link) => ListTile(
                                  leading: const Icon(Icons.link),
                                  title: Text(link),
                                  trailing: const Icon(Icons.open_in_new),
                                  onTap: () {
                                    // TODO: Link açma işlemi
                                  },
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
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
        Icon(icon, size: 40, color: Theme.of(context).primaryColor),
        const SizedBox(height: 12),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
