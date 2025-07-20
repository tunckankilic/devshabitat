import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/profile_controller.dart';
import '../base/base_view.dart';
import 'widgets/github_repo_card.dart';
import '../../widgets/adaptive_touch_target.dart';
import '../../widgets/responsive/responsive_safe_area.dart';
import '../../widgets/responsive/responsive_text.dart';
import '../../widgets/responsive/responsive_overflow_handler.dart'
    hide ResponsiveText, ResponsiveSafeArea;
import '../../widgets/responsive/animated_responsive_layout.dart';

class ProfileView extends BaseView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText(
          'Profil',
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 18,
              tablet: 22,
            ),
          ),
        ),
        actions: [
          AdaptiveTouchTarget(
            onTap: () => Get.toNamed('/edit-profile'),
            child: Icon(
              Icons.edit,
              size: responsive.minTouchTarget,
            ),
          ),
        ],
      ),
      body: ResponsiveSafeArea(
        child: Obx(() {
          if (controller.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: responsive.responsiveValue(
                  mobile: 2,
                  tablet: 3,
                ),
              ),
            );
          }

          final user = controller.user;
          if (user == null) {
            return Center(
              child: ResponsiveText(
                'Profil bulunamadı',
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 16,
                    tablet: 18,
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.loadProfile(),
            child: ResponsiveOverflowHandler(
              child: AnimatedResponsiveLayout(
                mobile: _buildMobileProfile(user),
                tablet: _buildTabletProfile(user),
                animationDuration: const Duration(milliseconds: 300),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMobileProfile(dynamic user) {
    return SingleChildScrollView(
      padding: responsive.responsivePadding(
          all: responsive.responsiveValue(mobile: 16, tablet: 24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(user),
          SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),
          if (user.bio != null) ...[
            _buildSectionTitle('Hakkımda'),
            SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
            _buildBioSection(user.bio!),
            SizedBox(
                height: responsive.responsiveValue(mobile: 24, tablet: 32)),
          ],
          _buildSkillsSection(user),
          _buildLanguagesSection(user),
          _buildFrameworksSection(user),
          _buildGithubSection(user),
          _buildWorkExperienceSection(user),
          _buildEducationSection(user),
        ],
      ),
    );
  }

  Widget _buildTabletProfile(dynamic user) {
    return SingleChildScrollView(
      padding: responsive.responsivePadding(
          all: responsive.responsiveValue(mobile: 24, tablet: 32)),
      child: Column(
        children: [
          _buildProfileHeader(user),
          SizedBox(height: responsive.responsiveValue(mobile: 32, tablet: 40)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (user.bio != null) ...[
                      _buildSectionTitle('Hakkımda'),
                      SizedBox(
                          height: responsive.responsiveValue(
                              mobile: 8, tablet: 12)),
                      _buildBioSection(user.bio!),
                      SizedBox(
                          height: responsive.responsiveValue(
                              mobile: 24, tablet: 32)),
                    ],
                    _buildSkillsSection(user),
                    _buildLanguagesSection(user),
                    _buildFrameworksSection(user),
                  ],
                ),
              ),
              SizedBox(
                  width: responsive.responsiveValue(mobile: 24, tablet: 32)),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGithubSection(user),
                    _buildWorkExperienceSection(user),
                    _buildEducationSection(user),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    final avatarSize = responsive.responsiveValue(
      mobile: 60.0,
      tablet: 80.0,
    );

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: avatarSize,
            backgroundColor: Colors.grey[200],
            backgroundImage: user.photoURL != null
                ? CachedNetworkImageProvider(user.photoURL!)
                : null,
            child: user.photoURL == null
                ? Icon(
                    Icons.person,
                    size: avatarSize,
                  )
                : null,
          ),
          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 24)),
          ResponsiveText(
            user.displayName ?? "",
            style: TextStyle(
              fontSize: responsive.responsiveValue(
                mobile: 24,
                tablet: 28,
              ),
              fontWeight: FontWeight.bold,
            ),
          ),
          if (user.title != null) ...[
            SizedBox(height: responsive.responsiveValue(mobile: 4, tablet: 6)),
            ResponsiveText(
              user.title!,
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 16,
                  tablet: 18,
                ),
              ),
            ),
          ],
          if (user.company != null) ...[
            SizedBox(height: responsive.responsiveValue(mobile: 4, tablet: 6)),
            ResponsiveText(
              user.company!,
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 16,
                  tablet: 18,
                ),
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return ResponsiveText(
      title,
      style: TextStyle(
        fontSize: responsive.responsiveValue(
          mobile: 18,
          tablet: 20,
        ),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildBioSection(String bio) {
    return ResponsiveText(
      bio,
      style: TextStyle(
        fontSize: responsive.responsiveValue(
          mobile: 14,
          tablet: 16,
        ),
      ),
    );
  }

  Widget _buildSkillsSection(dynamic user) {
    if (user.skills?.isNotEmpty != true) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Yetenekler'),
        SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
        Wrap(
          spacing: responsive.responsiveValue(mobile: 8, tablet: 12),
          runSpacing: responsive.responsiveValue(mobile: 8, tablet: 12),
          children: user.skills!
              .map<Widget>((skill) => Container(
                    padding: responsive.responsivePadding(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(Get.context!).chipTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(
                          responsive.responsiveValue(mobile: 16, tablet: 20)),
                    ),
                    child: ResponsiveText(
                      skill,
                      style: TextStyle(
                        fontSize: responsive.responsiveValue(
                          mobile: 12,
                          tablet: 14,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),
      ],
    );
  }

  Widget _buildLanguagesSection(dynamic user) {
    if (user.languages?.isNotEmpty != true) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Programlama Dilleri'),
        SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
        Wrap(
          spacing: responsive.responsiveValue(mobile: 8, tablet: 12),
          runSpacing: responsive.responsiveValue(mobile: 8, tablet: 12),
          children: user.languages!
              .map<Widget>((lang) => Container(
                    padding: responsive.responsivePadding(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(Get.context!).chipTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(
                          responsive.responsiveValue(mobile: 16, tablet: 20)),
                    ),
                    child: ResponsiveText(
                      lang,
                      style: TextStyle(
                        fontSize: responsive.responsiveValue(
                          mobile: 12,
                          tablet: 14,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),
      ],
    );
  }

  Widget _buildFrameworksSection(dynamic user) {
    if (user.frameworks?.isNotEmpty != true) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Frameworks'),
        SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
        Wrap(
          spacing: responsive.responsiveValue(mobile: 8, tablet: 12),
          runSpacing: responsive.responsiveValue(mobile: 8, tablet: 12),
          children: user.frameworks!
              .map<Widget>((framework) => Container(
                    padding: responsive.responsivePadding(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(Get.context!).chipTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(
                          responsive.responsiveValue(mobile: 16, tablet: 20)),
                    ),
                    child: ResponsiveText(
                      framework,
                      style: TextStyle(
                        fontSize: responsive.responsiveValue(
                          mobile: 12,
                          tablet: 14,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),
      ],
    );
  }

  Widget _buildGithubSection(dynamic user) {
    if (user.githubUsername == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('GitHub'),
        SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
        FutureBuilder<Map<String, dynamic>>(
          future: controller.fetchGithubRepoData(user.githubUsername!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: responsive.responsiveValue(
                    mobile: 2,
                    tablet: 3,
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return ResponsiveText(
                'GitHub verisi yüklenemedi: ${snapshot.error}',
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 14,
                    tablet: 16,
                  ),
                ),
              );
            }
            if (!snapshot.hasData) {
              return ResponsiveText(
                'GitHub verisi bulunamadı',
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 14,
                    tablet: 16,
                  ),
                ),
              );
            }
            return GithubRepoCard(repo: snapshot.data!);
          },
        ),
        SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),
      ],
    );
  }

  Widget _buildWorkExperienceSection(dynamic user) {
    if (user.workExperience?.isNotEmpty != true) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('İş Deneyimi'),
        SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: user.workExperience!.length,
          itemBuilder: (context, index) {
            final experience = user.workExperience![index];
            return Container(
              padding: responsive.responsivePadding(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveText(
                    experience.title,
                    style: TextStyle(
                      fontSize: responsive.responsiveValue(
                        mobile: 16,
                        tablet: 18,
                      ),
                    ),
                  ),
                  SizedBox(
                      height: responsive.responsiveValue(mobile: 4, tablet: 6)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ResponsiveText(
                          experience.company,
                          style: TextStyle(
                            fontSize: responsive.responsiveValue(
                              mobile: 14,
                              tablet: 16,
                            ),
                          ),
                        ),
                      ),
                      ResponsiveText(
                        experience.isCurrentRole ? 'Şu an' : 'Geçmiş',
                        style: TextStyle(
                          fontSize: responsive.responsiveValue(
                            mobile: 12,
                            tablet: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),
      ],
    );
  }

  Widget _buildEducationSection(dynamic user) {
    if (user.education?.isNotEmpty != true) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Eğitim'),
        SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: user.education!.length,
          itemBuilder: (context, index) {
            final education = user.education![index];
            return Container(
              padding: responsive.responsivePadding(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveText(
                    education.school,
                    style: TextStyle(
                      fontSize: responsive.responsiveValue(
                        mobile: 16,
                        tablet: 18,
                      ),
                    ),
                  ),
                  SizedBox(
                      height: responsive.responsiveValue(mobile: 4, tablet: 6)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ResponsiveText(
                          '${education.degree} - ${education.field}',
                          style: TextStyle(
                            fontSize: responsive.responsiveValue(
                              mobile: 14,
                              tablet: 16,
                            ),
                          ),
                        ),
                      ),
                      ResponsiveText(
                        education.isCurrentlyStudying
                            ? 'Devam ediyor'
                            : 'Mezun',
                        style: TextStyle(
                          fontSize: responsive.responsiveValue(
                            mobile: 12,
                            tablet: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
