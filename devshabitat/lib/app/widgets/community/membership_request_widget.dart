import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:devshabitat/app/models/user_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
              AppStrings.noPendingMembers,
              style: TextStyle(
                fontSize: performanceService.getOptimizedTextSize(
                  cacheKey: 'membership_request_empty',
                  mobileSize: 14.0,
                  tabletSize: 16.0,
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
              AppStrings.membershipRequests,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: performanceService.getOptimizedTextSize(
                      cacheKey: 'membership_request_title',
                      mobileSize: 20.0,
                      tabletSize: 24.0,
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
                    mobile: 20.0,
                    tablet: 24.0,
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
                      cacheKey: 'membership_request_name',
                      mobileSize: 16.0,
                      tabletSize: 18.0,
                    ),
                  ),
                ),
                subtitle: Text(
                  member.title.toString(),
                  style: TextStyle(
                    fontSize: performanceService.getOptimizedTextSize(
                      cacheKey: 'membership_request_title_text',
                      mobileSize: 14.0,
                      tabletSize: 16.0,
                    ),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.check_circle,
                        size: responsive.minTouchTargetSize,
                      ),
                      color: Colors.green,
                      onPressed: () => onAccept(member),
                      tooltip: AppStrings.accept,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.cancel,
                        size: responsive.minTouchTargetSize,
                      ),
                      color: Colors.red,
                      onPressed: () => onReject(member),
                      tooltip: AppStrings.reject,
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
