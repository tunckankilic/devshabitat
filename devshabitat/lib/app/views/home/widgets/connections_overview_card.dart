import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/responsive_controller.dart';

class ConnectionsOverviewCard extends GetView<HomeController> {
  const ConnectionsOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          responsive.responsiveValue(
            mobile: 16,
            tablet: 20,
          ),
        ),
      ),
      child: Padding(
        padding: responsive.responsivePadding(
          all: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.myConnections,
                  style: TextStyle(
                    fontSize: responsive.responsiveValue(
                      mobile: 18,
                      tablet: 22,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed('/connections'),
                  child: Text(
                    AppStrings.viewAll,
                    style: TextStyle(
                      fontSize: responsive.responsiveValue(
                        mobile: 14,
                        tablet: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
                height: responsive.responsiveValue(mobile: 16, tablet: 20)),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                children: [
                  _buildConnectionStat(
                    label: AppStrings.totalConnections,
                    value: controller.connectionCount.value.toString(),
                    icon: Icons.people,
                  ),
                  SizedBox(
                      height:
                          responsive.responsiveValue(mobile: 12, tablet: 16)),
                  _buildConnectionStat(
                    label: AppStrings.newMessages,
                    value: '3',
                    icon: Icons.message,
                  ),
                  SizedBox(
                      height:
                          responsive.responsiveValue(mobile: 12, tablet: 16)),
                  _buildConnectionStat(
                    label: AppStrings.pendingRequests,
                    value: '5',
                    icon: Icons.person_add,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final responsive = Get.find<ResponsiveController>();

    return Container(
      padding: responsive.responsivePadding(
        all: 12,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(
          responsive.responsiveValue(
            mobile: 8,
            tablet: 12,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: responsive.responsiveValue(
              mobile: 24,
              tablet: 28,
            ),
          ),
          SizedBox(width: responsive.responsiveValue(mobile: 12, tablet: 16)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 14,
                    tablet: 16,
                  ),
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 18,
                    tablet: 22,
                  ),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
