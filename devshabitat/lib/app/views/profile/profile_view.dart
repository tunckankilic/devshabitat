import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/github_integration_controller.dart';
import '../base/base_view.dart';
import 'widgets/github_repo_card.dart';
import '../../widgets/responsive/responsive_text.dart';
import '../../widgets/responsive/animated_responsive_layout.dart';
import 'github_integration_view.dart';

class ProfileView extends BaseView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget buildView(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: ResponsiveText(
            AppStrings.profile,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            tabs: [
              Tab(
                icon: Icon(Icons.person_outline),
                text: 'Profil',
              ),
              Tab(
                icon: Icon(Icons.code),
                text: 'GitHub',
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () => Get.toNamed('/edit-profile'),
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildProfileTab(context),
            _buildGithubTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab(BuildContext context) {
    return Obx(() {
      if (controller.isLoading) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: 3,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 16),
              ResponsiveText(
                'Profil yükleniyor...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }

      final user = controller.user;
      if (user == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              ResponsiveText(
                AppStrings.profileNotFound,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }

      return AnimatedResponsiveLayout(
        mobile: _buildMobileProfile(user, context),
        tablet: _buildTabletProfile(user, context),
        animationDuration: const Duration(milliseconds: 300),
      );
    });
  }

  Widget _buildGithubTab(BuildContext context) {
    return GetBuilder<GithubIntegrationController>(
      init: GithubIntegrationController(),
      builder: (controller) => GithubIntegrationView(),
    );
  }

  Widget _buildMobileProfile(dynamic user, BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.loadProfile(),
      color: Theme.of(context).primaryColor,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileCard(user, context),
                  SizedBox(height: 16),
                  if (user.bio != null) ...[
                    _buildAboutCard(user.bio!, context),
                    SizedBox(height: 16),
                  ],
                  _buildSkillsCard(user, context),
                  SizedBox(height: 16),
                  _buildLanguagesCard(user, context),
                  SizedBox(height: 16),
                  _buildFrameworksCard(user, context),
                  SizedBox(height: 16),
                  _buildGithubCard(user, context),
                  SizedBox(height: 16),
                  _buildWorkExperienceCard(user, context),
                  SizedBox(height: 16),
                  _buildEducationCard(user, context),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletProfile(dynamic user, BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.loadProfile(),
      color: Theme.of(context).primaryColor,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildProfileCard(user, context),
                  SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            if (user.bio != null) ...[
                              _buildAboutCard(user.bio!, context),
                              SizedBox(height: 24),
                            ],
                            _buildSkillsCard(user, context),
                            SizedBox(height: 24),
                            _buildLanguagesCard(user, context),
                            SizedBox(height: 24),
                            _buildFrameworksCard(user, context),
                          ],
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            _buildGithubCard(user, context),
                            SizedBox(height: 24),
                            _buildWorkExperienceCard(user, context),
                            SizedBox(height: 24),
                            _buildEducationCard(user, context),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(dynamic user, BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: user.photoURL != null
                        ? CachedNetworkImageProvider(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey[600],
                          )
                        : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ResponsiveText(
              user.displayName ?? "Kullanıcı",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            if (user.title != null) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ResponsiveText(
                  user.title!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            if (user.company != null) ...[
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 8),
                  ResponsiveText(
                    user.company!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModernCard({
    required String title,
    required IconData icon,
    required Widget child,
    required BuildContext context,
    Color? color,
  }) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (color ?? Theme.of(context).primaryColor)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color ?? Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ResponsiveText(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard(String bio, BuildContext context) {
    return _buildModernCard(
      title: AppStrings.aboutMe,
      icon: Icons.info_outline,
      color: Colors.blue,
      context: context,
      child: ResponsiveText(
        bio,
        style: TextStyle(
          fontSize: 15,
          height: 1.5,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildSkillsCard(dynamic user, BuildContext context) {
    if (user.skills?.isNotEmpty != true) return SizedBox.shrink();

    return _buildModernCard(
      title: AppStrings.skills,
      icon: Icons.star_outline,
      color: Colors.orange,
      context: context,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: user.skills!
            .map<Widget>((skill) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.withOpacity(0.1),
                        Colors.orange.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ResponsiveText(
                    skill,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildLanguagesCard(dynamic user, BuildContext context) {
    if (user.languages?.isNotEmpty != true) return SizedBox.shrink();

    return _buildModernCard(
      title: AppStrings.programmingLanguages,
      icon: Icons.code,
      color: Colors.green,
      context: context,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: user.languages!
            .map<Widget>((lang) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withOpacity(0.1),
                        Colors.green.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ResponsiveText(
                    lang,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildFrameworksCard(dynamic user, BuildContext context) {
    if (user.frameworks?.isNotEmpty != true) return SizedBox.shrink();

    return _buildModernCard(
      title: AppStrings.frameworks,
      icon: Icons.widgets_outlined,
      color: Colors.purple,
      context: context,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: user.frameworks!
            .map<Widget>((framework) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.withOpacity(0.1),
                        Colors.purple.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.purple.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ResponsiveText(
                    framework,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.purple[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildGithubCard(dynamic user, BuildContext context) {
    if (user.githubUsername == null) return SizedBox.shrink();

    return _buildModernCard(
      title: AppStrings.github,
      icon: Icons.code_outlined,
      color: Colors.grey[800]!,
      context: context,
      child: FutureBuilder<Map<String, dynamic>>(
        future: controller.fetchGithubRepoData(user.githubUsername!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.grey[600],
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            return Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: ResponsiveText(
                      'GitHub verisi yüklenemedi',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red[600],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: ResponsiveText(
                AppStrings.githubDataNotFound,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            );
          }
          return GithubRepoCard(repo: snapshot.data!);
        },
      ),
    );
  }

  Widget _buildWorkExperienceCard(dynamic user, BuildContext context) {
    if (user.workExperience?.isNotEmpty != true) return SizedBox.shrink();

    return _buildModernCard(
      title: AppStrings.workExperience,
      icon: Icons.work_outline,
      color: Colors.indigo,
      context: context,
      child: Column(
        children: user.workExperience!.map<Widget>((experience) {
          return Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.indigo[100]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.business_center,
                      size: 16,
                      color: Colors.indigo[600],
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ResponsiveText(
                        experience.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo[800],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ResponsiveText(
                        experience.company,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: experience.isCurrentRole
                            ? Colors.green[100]
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ResponsiveText(
                        experience.isCurrentRole
                            ? AppStrings.currently
                            : AppStrings.past,
                        style: TextStyle(
                          fontSize: 12,
                          color: experience.isCurrentRole
                              ? Colors.green[700]
                              : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEducationCard(dynamic user, BuildContext context) {
    if (user.education?.isNotEmpty != true) return SizedBox.shrink();

    return _buildModernCard(
      title: AppStrings.education,
      icon: Icons.school_outlined,
      color: Colors.teal,
      context: context,
      child: Column(
        children: user.education!.map<Widget>((education) {
          return Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal[100]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.school,
                      size: 16,
                      color: Colors.teal[600],
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ResponsiveText(
                        education.school,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal[800],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ResponsiveText(
                        '${education.degree} - ${education.field}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: education.isCurrentlyStudying
                            ? Colors.blue[100]
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ResponsiveText(
                        education.isCurrentlyStudying
                            ? AppStrings.currentlyStudying
                            : AppStrings.graduate,
                        style: TextStyle(
                          fontSize: 12,
                          color: education.isCurrentlyStudying
                              ? Colors.blue[700]
                              : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
