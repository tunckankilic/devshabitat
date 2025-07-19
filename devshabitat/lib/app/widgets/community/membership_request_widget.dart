import 'package:devshabitat/app/models/user_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/responsive_controller.dart';
import '../../services/responsive_performance_service.dart';

class MembershipRequestWidget extends StatelessWidget {
  final List<UserProfile> pendingMembers;
  final Function(UserProfile) onAccept;
  final Function(UserProfile) onReject;

  const MembershipRequestWidget({
    super.key,
    required this.pendingMembers,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    if (pendingMembers.isEmpty) {
      return Card(
        child: Padding(
          padding: responsive.responsivePadding(all: 16),
          child: Center(
            child: Text(
              'Bekleyen üyelik talebi bulunmamaktadır.',
              style: TextStyle(
                fontSize: performanceService.getOptimizedTextSize(
                  cacheKey: 'membership_request_empty',
                  mobileSize: 14.sp,
                  tabletSize: 16.sp,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: responsive.responsivePadding(all: 16),
            child: Text(
              'Üyelik Talepleri',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: performanceService.getOptimizedTextSize(
                      cacheKey: 'membership_request_title',
                      mobileSize: 20.sp,
                      tabletSize: 24.sp,
                    ),
                  ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pendingMembers.length,
            itemBuilder: (context, index) {
              final member = pendingMembers[index];
              return ListTile(
                leading: CircleAvatar(
                  radius: responsive.responsiveValue(
                    mobile: 20.r,
                    tablet: 24.r,
                  ),
                  backgroundImage: member.photoUrl != null
                      ? NetworkImage(member.photoUrl!)
                      : null,
                  child: member.photoUrl == null && member.fullName != ""
                      ? Text(
                          member.fullName.characters.first.toUpperCase(),
                          style: TextStyle(
                            fontSize: performanceService.getOptimizedTextSize(
                              cacheKey: 'membership_request_avatar_text',
                              mobileSize: 16.sp,
                              tabletSize: 18.sp,
                            ),
                          ),
                        )
                      : null,
                ),
                title: Text(
                  member.fullName,
                  style: TextStyle(
                    fontSize: performanceService.getOptimizedTextSize(
                      cacheKey: 'membership_request_name',
                      mobileSize: 16.sp,
                      tabletSize: 18.sp,
                    ),
                  ),
                ),
                subtitle: Text(
                  member.title.toString(),
                  style: TextStyle(
                    fontSize: performanceService.getOptimizedTextSize(
                      cacheKey: 'membership_request_title_text',
                      mobileSize: 14.sp,
                      tabletSize: 16.sp,
                    ),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.check_circle,
                        size: responsive.minTouchTarget.sp,
                      ),
                      color: Colors.green,
                      onPressed: () => onAccept(member),
                      tooltip: 'Kabul Et',
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.cancel,
                        size: responsive.minTouchTarget.sp,
                      ),
                      color: Colors.red,
                      onPressed: () => onReject(member),
                      tooltip: 'Reddet',
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
