import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/networking_controller.dart';
import '../../widgets/common/lazy_loading_list.dart';
import '../../widgets/common/advanced_search_filters.dart';
import '../../models/connection_model.dart';
import '../../constants/app_strings.dart';
import '../../controllers/responsive_controller.dart';

class ConnectionsView extends GetView<NetworkingController> {
  const ConnectionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.connections,
          style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 20, tablet: 24),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              size: responsive.responsiveValue(mobile: 24, tablet: 28),
            ),
            onPressed: () => _showFilterDialog(context),
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              size: responsive.responsiveValue(mobile: 24, tablet: 28),
            ),
            onPressed: controller.refreshConnections,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Obx(() {
            if (controller.showFilters.value) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      responsive.responsiveValue(mobile: 16, tablet: 24),
                  vertical: responsive.responsiveValue(mobile: 8, tablet: 12),
                ),
                child: AdvancedSearchFilters(
                  selectedSkills: controller.selectedSkills,
                  maxDistance: controller.maxDistance.value,
                  showOnlineOnly: controller.showOnlineOnly.value,
                  availableSkills: controller.availableSkills,
                  onSkillsChanged: controller.updateSkills,
                  onDistanceChanged: controller.updateMaxDistance,
                  onOnlineOnlyChanged: controller.toggleOnlineOnly,
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Expanded(
            child: Obx(
              () => LazyLoadingList<ConnectionModel>(
                items: controller.connections,
                hasMore: controller.hasMoreConnections,
                onLoadMore: controller.loadMoreConnections,
                padding: EdgeInsets.all(
                  responsive.responsiveValue(mobile: 8, tablet: 16),
                ),
                loadingWidget: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                emptyWidget: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size:
                            responsive.responsiveValue(mobile: 48, tablet: 64),
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.noConnections,
                        style: TextStyle(
                          fontSize: responsive.responsiveValue(
                            mobile: 16,
                            tablet: 18,
                          ),
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => _showFilterDialog(context),
                        child: const Text('Adjust Filters'),
                      ),
                    ],
                  ),
                ),
                itemBuilder: (context, connection, index) =>
                    _buildConnectionCard(connection),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final responsive = Get.find<ResponsiveController>();

    return Padding(
      padding: EdgeInsets.all(
        responsive.responsiveValue(mobile: 8, tablet: 16),
      ),
      child: TextField(
        onChanged: controller.updateSearchQuery,
        decoration: InputDecoration(
          hintText: AppStrings.searchConnections,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: Obx(() => Icon(
                  controller.showFilters.value
                      ? Icons.filter_list
                      : Icons.filter_list_outlined,
                )),
            onPressed: controller.toggleFilters,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              responsive.responsiveValue(mobile: 8, tablet: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionCard(ConnectionModel connection) {
    final responsive = Get.find<ResponsiveController>();

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: responsive.responsiveValue(mobile: 8, tablet: 16),
        vertical: responsive.responsiveValue(mobile: 4, tablet: 8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Get.theme.primaryColor,
          child: Text(
            connection.targetUserId[0].toUpperCase(),
            style: TextStyle(
              color: Get.theme.colorScheme.onPrimary,
              fontSize: responsive.responsiveValue(mobile: 16, tablet: 20),
            ),
          ),
        ),
        title: Text(
          connection.targetUserId,
          style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 16, tablet: 18),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              connection.skills.join(', '),
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 12, tablet: 14),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (connection.isOnline)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                Text(
                  connection.isOnline ? 'Online' : 'Last active: Recently',
                  style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 12, tablet: 14),
                    color: connection.isOnline ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showConnectionOptions(connection),
        ),
        onTap: () => Get.toNamed(
          '/profile/${connection.targetUserId}',
          arguments: connection,
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    controller.toggleFilters();
  }

  void _showConnectionOptions(ConnectionModel connection) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('View Profile'),
              onTap: () {
                Get.back();
                Get.toNamed(
                  '/profile/${connection.targetUserId}',
                  arguments: connection,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Send Message'),
              onTap: () {
                Get.back();
                Get.toNamed(
                  '/chat/${connection.targetUserId}',
                  arguments: connection,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: const Text('Remove Connection'),
              onTap: () {
                Get.back();
                _showRemoveConfirmation(connection);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveConfirmation(ConnectionModel connection) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remove Connection'),
        content: const Text(
          'Are you sure you want to remove this connection? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.removeConnection(connection.id);
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
