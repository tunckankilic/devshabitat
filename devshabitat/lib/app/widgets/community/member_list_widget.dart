import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:devshabitat/app/models/user_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/responsive_controller.dart';
import '../../services/responsive_performance_service.dart';

class MemberListWidget extends StatelessWidget {
  final List<UserProfile> members;
  final bool isAdmin;
  final Function(UserProfile)? onMemberTap;
  final Function(UserProfile)? onRemoveMember;
  final Function(UserProfile)? onPromoteToModerator;

  const MemberListWidget({
    super.key,
    required this.members,
    this.isAdmin = false,
    this.onMemberTap,
    this.onRemoveMember,
    this.onPromoteToModerator,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return ListTile(
          leading: CircleAvatar(
            radius: responsive.responsiveValue(
              mobile: 20.0,
              tablet: 24.0,
            ),
            backgroundImage:
                member.photoUrl != null ? NetworkImage(member.photoUrl!) : null,
            child: member.photoUrl == null && member.fullName != ""
                ? Text(
                    member.fullName.characters.first.toUpperCase(),
                    style: TextStyle(
                      fontSize: performanceService.getOptimizedTextSize(
                        cacheKey: 'member_list_avatar_text',
                        mobileSize: 16.0,
                        tabletSize: 18.0,
                      ),
                    ),
                  )
                : null,
          ),
          title: Text(
            member.fullName,
            style: TextStyle(
              fontSize: performanceService.getOptimizedTextSize(
                cacheKey: 'member_list_title',
                mobileSize: 16.0,
                tabletSize: 18.0,
              ),
            ),
          ),
          subtitle: member.title != null
              ? Text(
                  member.title!,
                  style: TextStyle(
                    fontSize: performanceService.getOptimizedTextSize(
                      cacheKey: 'member_list_subtitle',
                      mobileSize: 14.0,
                      tabletSize: 16.0,
                    ),
                  ),
                )
              : null,
          onTap: onMemberTap != null ? () => onMemberTap!(member) : null,
          trailing: isAdmin
              ? PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    size: responsive.minTouchTargetSize,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case AppStrings.remove:
                        if (onRemoveMember != null) onRemoveMember!(member);
                        break;
                      case AppStrings.promote:
                        if (onPromoteToModerator != null) {
                          onPromoteToModerator!(member);
                        }
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: AppStrings.promote,
                      child: Row(
                        children: [
                          Icon(
                            Icons.admin_panel_settings,
                            size: responsive.responsiveValue(
                              mobile: 20.0,
                              tablet: 24.0,
                            ),
                          ),
                          SizedBox(
                              width: responsive.responsiveValue(
                            mobile: 8.0,
                            tablet: 12.0,
                          )),
                          Text(
                            AppStrings.promote,
                            style: TextStyle(
                              fontSize: performanceService.getOptimizedTextSize(
                                cacheKey: 'member_list_promote_text',
                                mobileSize: 14.0,
                                tabletSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: AppStrings.remove,
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_remove,
                            size: responsive.responsiveValue(
                              mobile: 20.0,
                              tablet: 24.0,
                            ),
                          ),
                          SizedBox(
                              width: responsive.responsiveValue(
                            mobile: 8.0,
                            tablet: 12.0,
                          )),
                          Text(
                            AppStrings.onRemoveMember,
                            style: TextStyle(
                              fontSize: performanceService.getOptimizedTextSize(
                                cacheKey: 'member_list_remove_text',
                                mobileSize: 14.0,
                                tabletSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }
}
