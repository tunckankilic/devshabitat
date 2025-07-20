import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/responsive_controller.dart';
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
              mobile: 18.sp,
              tablet: 22.sp,
            ),
          ),
        ),
        actions: [
          AdaptiveTouchTarget(
            onTap: () => Get.toNamed('/edit-profile'),
            child: Icon(
              Icons.edit,
              size: responsive.minTouchTarget.sp,
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
                  mobile: 2.w,
                  tablet: 3.w,
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
                    mobile: 16.sp,
                    tablet: 18.sp,
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
      padding: responsive.responsivePadding(all: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(user),
          SizedBox(height: 24.h),
          if (user.bio != null) ...[
            _buildSectionTitle('Hakkımda'),
            SizedBox(height: 8.h),
            _buildBioSection(user.bio!),
            SizedBox(height: 24.h),
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
      padding: responsive.responsivePadding(all: 24),
      child: Column(
        children: [
          _buildProfileHeader(user),
          SizedBox(height: 32.h),
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
                      SizedBox(height: 8.h),
                      _buildBioSection(user.bio!),
                      SizedBox(height: 24.h),
                    ],
                    _buildSkillsSection(user),
                    _buildLanguagesSection(user),
                    _buildFrameworksSection(user),
                  ],
                ),
              ),
              SizedBox(width: 32.w),
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
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: responsive.responsiveValue(
              mobile: 60.r,
              tablet: 80.r,
            ),
            backgroundColor: Colors.grey[200],
            backgroundImage: user.photoURL != null
                ? CachedNetworkImageProvider(user.photoURL!)
                : null,
            child: user.photoURL == null
                ? Icon(
                    Icons.person,
                    size: responsive.responsiveValue(
                      mobile: 60.r,
                      tablet: 80.r,
                    ),
                  )
                : null,
          ),
          SizedBox(height: 16.h),
          ResponsiveText(
            user.displayName ?? "",
            style: TextStyle(
              fontSize: responsive.responsiveValue(
                mobile: 24.sp,
                tablet: 28.sp,
              ),
              fontWeight: FontWeight.bold,
            ),
          ),
          if (user.title != null) ...[
            SizedBox(height: 4.h),
            ResponsiveText(
              user.title!,
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 16.sp,
                  tablet: 18.sp,
                ),
              ),
            ),
          ],
          if (user.company != null) ...[
            SizedBox(height: 4.h),
            ResponsiveText(
              user.company!,
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 16.sp,
                  tablet: 18.sp,
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
          mobile: 18.sp,
          tablet: 20.sp,
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
          mobile: 14.sp,
          tablet: 16.sp,
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
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: user.skills!
              .map<Widget>((skill) => Chip(
                    label: ResponsiveText(
                      skill,
                      style: TextStyle(
                        fontSize: responsive.responsiveValue(
                          mobile: 12.sp,
                          tablet: 14.sp,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildLanguagesSection(dynamic user) {
    if (user.languages?.isNotEmpty != true) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Programlama Dilleri'),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: user.languages!
              .map<Widget>((lang) => Chip(
                    label: ResponsiveText(
                      lang,
                      style: TextStyle(
                        fontSize: responsive.responsiveValue(
                          mobile: 12.sp,
                          tablet: 14.sp,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildFrameworksSection(dynamic user) {
    if (user.frameworks?.isNotEmpty != true) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Frameworks'),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: user.frameworks!
              .map<Widget>((framework) => Chip(
                    label: ResponsiveText(
                      framework,
                      style: TextStyle(
                        fontSize: responsive.responsiveValue(
                          mobile: 12.sp,
                          tablet: 14.sp,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildGithubSection(dynamic user) {
    if (user.githubUsername == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('GitHub'),
        SizedBox(height: 8.h),
        FutureBuilder<Map<String, dynamic>>(
          future: controller.fetchGithubRepoData(user.githubUsername!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: responsive.responsiveValue(
                    mobile: 2.w,
                    tablet: 3.w,
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return ResponsiveText(
                'GitHub verisi yüklenemedi: ${snapshot.error}',
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 14.sp,
                    tablet: 16.sp,
                  ),
                ),
              );
            }
            if (!snapshot.hasData) {
              return ResponsiveText(
                'GitHub verisi bulunamadı',
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 14.sp,
                    tablet: 16.sp,
                  ),
                ),
              );
            }
            return GithubRepoCard(repo: snapshot.data!);
          },
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildWorkExperienceSection(dynamic user) {
    if (user.workExperience?.isNotEmpty != true) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('İş Deneyimi'),
        SizedBox(height: 8.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: user.workExperience!.length,
          itemBuilder: (context, index) {
            final experience = user.workExperience![index];
            return ListTile(
              title: ResponsiveText(
                experience.title,
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 16.sp,
                    tablet: 18.sp,
                  ),
                ),
              ),
              subtitle: ResponsiveText(
                experience.company,
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 14.sp,
                    tablet: 16.sp,
                  ),
                ),
              ),
              trailing: ResponsiveText(
                experience.isCurrentRole ? 'Şu an' : 'Geçmiş',
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 12.sp,
                    tablet: 14.sp,
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildEducationSection(dynamic user) {
    if (user.education?.isNotEmpty != true) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Eğitim'),
        SizedBox(height: 8.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: user.education!.length,
          itemBuilder: (context, index) {
            final education = user.education![index];
            return ListTile(
              title: ResponsiveText(
                education.school,
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 16.sp,
                    tablet: 18.sp,
                  ),
                ),
              ),
              subtitle: ResponsiveText(
                '${education.degree} - ${education.field}',
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 14.sp,
                    tablet: 16.sp,
                  ),
                ),
              ),
              trailing: ResponsiveText(
                education.isCurrentlyStudying ? 'Devam ediyor' : 'Mezun',
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 12.sp,
                    tablet: 14.sp,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
