import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/skill_chip.dart';
import '../../widgets/connection_button.dart';
import '../../controllers/user_profile_controller.dart';
import '../../models/user_profile_model.dart';

class UserProfileDetailScreen extends GetView<UserProfileController> {
  final UserProfile user;

  const UserProfileDetailScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfo(),
                  const SizedBox(height: 16),
                  _buildBio(),
                  const SizedBox(height: 24),
                  _buildSkillsSection(),
                  const SizedBox(height: 24),
                  _buildExperienceSection(),
                  const SizedBox(height: 24),
                  _buildSocialLinks(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildConnectionButton(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar.large(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(user.fullName),
        background: Hero(
          tag: 'profile_${user.id}',
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(user.photoUrl ?? ""),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.title ?? AppStrings.noTitle,
          style: Get.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 16),
            const SizedBox(width: 4),
            Text(
              user.locationName ?? AppStrings.noLocation,
              style: Get.textTheme.bodyMedium,
            ),
            const SizedBox(width: 16),
            const Icon(Icons.business_outlined, size: 16),
            const SizedBox(width: 4),
            Text(
              user.company ?? AppStrings.noCompany,
              style: Get.textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.about,
          style: Get.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          user.bio ?? AppStrings.noBio,
          style: Get.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.skills,
          style: Get.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: user.skills.map((skill) {
            final isMatching = controller.currentUserSkills.contains(skill);
            return SkillChip(
              label: skill,
              isMatching: isMatching,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExperienceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.experience,
          style: Get.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: user.workExperience.length,
          itemBuilder: (context, index) {
            final experienceMap = user.workExperience[index];
            final experience = WorkExperience.fromMap(experienceMap);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.work_outline),
              title: Text(experience.title),
              subtitle: Text(
                '${experience.company} • ${experience.isCurrentRole ? AppStrings.currently : "${experience.startDate.year} - ${experience.endDate?.year ?? ""}"}',
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSocialLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (user.socialLinks['github'] != null)
          ElevatedButton.icon(
            onPressed: () => controller.openGitHub(user.socialLinks['github']!),
            icon: const Icon(Icons.code),
            label: const Text('GitHub'),
          ),
        if (user.socialLinks['linkedin'] != null)
          ElevatedButton.icon(
            onPressed: () =>
                controller.openLinkedIn(user.socialLinks['linkedin']!),
            icon: const Icon(Icons.business_center),
            label: const Text('LinkedIn'),
          ),
      ],
    );
  }

  Widget _buildConnectionButton() {
    return Obx(() => ConnectionButton(
          status: controller.connectionStatus.value,
          onConnect: () => controller.sendConnectionRequest(user),
          onMessage: () => controller.openChat(user),
        ));
  }
}
