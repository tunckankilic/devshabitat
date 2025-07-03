import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/responsive_controller.dart';
import '../base/base_view.dart';
import 'widgets/github_repo_card.dart';

class ProfileView extends BaseView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget buildView(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Profil', style: TextStyle(fontSize: 18.sp)),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, size: 24.sp),
            onPressed: () => Get.toNamed('/edit-profile'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = controller.user;
        if (user == null) {
          return Center(
            child: Text(
              'Profil bulunamadı',
              style: TextStyle(fontSize: 16.sp),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadProfile(),
          child: SingleChildScrollView(
            padding: responsive.responsivePadding(
              left: 16,
              top: 16,
              right: 16,
              bottom: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profil Fotoğrafı ve Temel Bilgiler
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: responsive.r(60),
                        backgroundColor: Colors.grey[200],
                        backgroundImage: user.photoURL != null
                            ? CachedNetworkImageProvider(user.photoURL!)
                            : null,
                        child: user.photoURL == null
                            ? Icon(Icons.person, size: responsive.r(60))
                            : null,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        user.displayName ?? "",
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (user.title != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          user.title!,
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ],
                      if (user.company != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          user.company!,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Bio
                if (user.bio != null) ...[
                  Text(
                    'Hakkımda',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    user.bio!,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  SizedBox(height: 24.h),
                ],

                // Yetenekler
                if (user.skills?.isNotEmpty == true) ...[
                  Text(
                    'Yetenekler',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: user.skills!
                        .map((skill) => Chip(
                              label: Text(
                                skill,
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 24.h),
                ],

                // Programlama Dilleri
                if (user.languages?.isNotEmpty == true) ...[
                  Text(
                    'Programlama Dilleri',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: user.languages!
                        .map((lang) => Chip(
                              label: Text(
                                lang,
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 24.h),
                ],

                // Frameworks
                if (user.frameworks?.isNotEmpty == true) ...[
                  Text(
                    'Frameworks',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: user.frameworks!
                        .map((framework) => Chip(
                              label: Text(
                                framework,
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 24.h),
                ],

                // GitHub Bilgileri
                if (user.githubUsername != null) ...[
                  Text(
                    'GitHub',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  FutureBuilder<Map<String, dynamic>>(
                    future:
                        controller.fetchGithubRepoData(user.githubUsername!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text(
                          'GitHub verisi yüklenemedi: ${snapshot.error}',
                          style: TextStyle(fontSize: 14.sp),
                        );
                      }
                      if (!snapshot.hasData) {
                        return Text(
                          'GitHub verisi bulunamadı',
                          style: TextStyle(fontSize: 14.sp),
                        );
                      }
                      return GithubRepoCard(repo: snapshot.data!);
                    },
                  ),
                  SizedBox(height: 24.h),
                ],

                // İş Deneyimi
                if (user.workExperience?.isNotEmpty == true) ...[
                  Text(
                    'İş Deneyimi',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: user.workExperience!.length,
                    itemBuilder: (context, index) {
                      final experience = user.workExperience![index];
                      return ListTile(
                        title: Text(
                          experience.title,
                          style: TextStyle(fontSize: 16.sp),
                        ),
                        subtitle: Text(
                          experience.company,
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        trailing: Text(
                          experience.isCurrentRole ? 'Şu an' : 'Geçmiş',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 24.h),
                ],

                // Eğitim
                if (user.education?.isNotEmpty == true) ...[
                  Text(
                    'Eğitim',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: user.education!.length,
                    itemBuilder: (context, index) {
                      final education = user.education![index];
                      return ListTile(
                        title: Text(
                          education.school,
                          style: TextStyle(fontSize: 16.sp),
                        ),
                        subtitle: Text(
                          '${education.degree} - ${education.field}',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        trailing: Text(
                          education.isCurrentlyStudying
                              ? 'Devam ediyor'
                              : 'Mezun',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}
