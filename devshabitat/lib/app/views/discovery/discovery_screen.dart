import 'package:devshabitat/app/widgets/user_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'advanced_filters_screen.dart';
import '../../controllers/discovery_controller.dart';
import '../../views/base/base_view.dart';
import '../../widgets/adaptive_touch_target.dart';
import '../../widgets/responsive/responsive_safe_area.dart';
import '../../widgets/responsive/responsive_text.dart';
import '../../widgets/responsive/responsive_overflow_handler.dart'
    hide ResponsiveSafeArea, ResponsiveText;
import '../../widgets/responsive/animated_responsive_layout.dart';

class DiscoveryScreen extends BaseView<DiscoveryController> {
  const DiscoveryScreen({super.key});

  @override
  Widget buildView(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: ResponsiveText(
            'Keşfet',
            style: TextStyle(
              fontSize: responsive.responsiveValue(
                mobile: 18,
                tablet: 22,
              ),
            ),
          ),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(
                  Icons.search,
                  size: responsive.responsiveValue(
                    mobile: 24,
                    tablet: 28,
                  ),
                ),
                text: 'Arama',
              ),
              Tab(
                icon: Icon(
                  Icons.recommend,
                  size: responsive.responsiveValue(
                    mobile: 24,
                    tablet: 28,
                  ),
                ),
                text: 'Öneriler',
              ),
              Tab(
                icon: Icon(
                  Icons.people,
                  size: responsive.responsiveValue(
                    mobile: 24,
                    tablet: 28,
                  ),
                ),
                text: 'Bağlantılar',
              ),
              Tab(
                icon: Icon(
                  Icons.person_add,
                  size: responsive.responsiveValue(
                    mobile: 24,
                    tablet: 28,
                  ),
                ),
                text: 'İstekler',
              ),
            ],
            labelStyle: TextStyle(
              fontSize: responsive.responsiveValue(
                mobile: 14,
                tablet: 16,
              ),
            ),
          ),
        ),
        body: ResponsiveSafeArea(
          child: ResponsiveOverflowHandler(
            child: TabBarView(
              children: [
                _buildSearchTab(),
                _buildRecommendationsTab(),
                _buildConnectionsTab(),
                _buildRequestsTab(),
              ],
            ),
          ),
        ),
        floatingActionButton: AdaptiveTouchTarget(
          onTap: () => Get.to(() => const AdvancedFiltersScreen()),
          child: Icon(
            Icons.filter_list,
            size: responsive.responsiveValue(
              mobile: 24,
              tablet: 28,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: responsive.responsivePadding(all: 16),
          child: TextField(
            onChanged: controller.onSearchQueryChanged,
            style: TextStyle(
              fontSize: responsive.responsiveValue(
                mobile: 16,
                tablet: 18,
              ),
            ),
            decoration: InputDecoration(
              hintText: 'Kullanıcı ara...',
              hintStyle: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 16,
                  tablet: 18,
                ),
              ),
              prefixIcon: Icon(
                Icons.search,
                size: responsive.responsiveValue(
                  mobile: 24,
                  tablet: 28,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Expanded(
          child: Obx(
            () => AnimatedResponsiveLayout(
              mobile: _buildMobileSearchGrid(),
              tablet: _buildTabletSearchGrid(),
              animationDuration: const Duration(milliseconds: 300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileSearchGrid() {
    return GridView.builder(
      padding: responsive.responsivePadding(all: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: responsive.responsiveValue(
          mobile: 0.75,
          tablet: 0.75,
        ),
        crossAxisSpacing: responsive.responsiveValue(
          mobile: 16,
          tablet: 16,
        ),
        mainAxisSpacing: responsive.responsiveValue(
          mobile: 16,
          tablet: 16,
        ),
      ),
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        final user = controller.searchResults[index];
        return UserCard(
          user: user,
          onTap: () => controller.onUserTap(user),
        );
      },
    );
  }

  Widget _buildTabletSearchGrid() {
    return GridView.builder(
      padding: responsive.responsivePadding(all: 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: responsive.responsiveValue(
          mobile: 0.8,
          tablet: 0.8,
        ),
        crossAxisSpacing: responsive.responsiveValue(
          mobile: 24,
          tablet: 24,
        ),
        mainAxisSpacing: responsive.responsiveValue(
          mobile: 24,
          tablet: 24,
        ),
      ),
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        final user = controller.searchResults[index];
        return UserCard(
          user: user,
          onTap: () => controller.onUserTap(user),
        );
      },
    );
  }

  Widget _buildRecommendationsTab() {
    return Obx(() {
      if (controller.isLoadingRecommendations.value) {
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: responsive.responsiveValue(
              mobile: 2,
              tablet: 3,
            ),
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: controller.refreshRecommendations,
        child: AnimatedResponsiveLayout(
          mobile: _buildMobileRecommendationsGrid(),
          tablet: _buildTabletRecommendationsGrid(),
          animationDuration: const Duration(milliseconds: 300),
        ),
      );
    });
  }

  Widget _buildMobileRecommendationsGrid() {
    return GridView.builder(
      padding: responsive.responsivePadding(all: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: responsive.responsiveValue(
          mobile: 0.75,
          tablet: 0.75,
        ),
        crossAxisSpacing: responsive.responsiveValue(
          mobile: 16,
          tablet: 16,
        ),
        mainAxisSpacing: responsive.responsiveValue(
          mobile: 16,
          tablet: 16,
        ),
      ),
      itemCount: controller.recommendedUsers.length,
      itemBuilder: (context, index) {
        final user = controller.recommendedUsers[index];
        return UserCard(
          user: user,
          onTap: () => controller.onUserTap(user),
          matchPercentage: controller.calculateMatchPercentage(user),
        );
      },
    );
  }

  Widget _buildTabletRecommendationsGrid() {
    return GridView.builder(
      padding: responsive.responsivePadding(all: 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: responsive.responsiveValue(
          mobile: 0.8,
          tablet: 0.8,
        ),
        crossAxisSpacing: responsive.responsiveValue(
          mobile: 24,
          tablet: 24,
        ),
        mainAxisSpacing: responsive.responsiveValue(
          mobile: 24,
          tablet: 24,
        ),
      ),
      itemCount: controller.recommendedUsers.length,
      itemBuilder: (context, index) {
        final user = controller.recommendedUsers[index];
        return UserCard(
          user: user,
          onTap: () => controller.onUserTap(user),
          matchPercentage: controller.calculateMatchPercentage(user),
        );
      },
    );
  }

  Widget _buildConnectionsTab() {
    return Obx(() {
      if (controller.isLoadingConnections.value) {
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: responsive.responsiveValue(
              mobile: 2,
              tablet: 3,
            ),
          ),
        );
      }
      return AnimatedResponsiveLayout(
        mobile: _buildMobileConnectionsList(),
        tablet: _buildTabletConnectionsList(),
        animationDuration: const Duration(milliseconds: 300),
      );
    });
  }

  Widget _buildMobileConnectionsList() {
    return ListView.builder(
      padding: responsive.responsivePadding(all: 16),
      itemCount: controller.connections.length,
      itemBuilder: (context, index) {
        final connection = controller.connections[index];
        return _buildConnectionCard(connection);
      },
    );
  }

  Widget _buildTabletConnectionsList() {
    return GridView.builder(
      padding: responsive.responsivePadding(all: 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: responsive.responsiveValue(
          mobile: 3,
          tablet: 3,
        ),
        crossAxisSpacing: responsive.responsiveValue(
          mobile: 24,
          tablet: 24,
        ),
        mainAxisSpacing: responsive.responsiveValue(
          mobile: 24,
          tablet: 24,
        ),
      ),
      itemCount: controller.connections.length,
      itemBuilder: (context, index) {
        final connection = controller.connections[index];
        return _buildConnectionCard(connection);
      },
    );
  }

  Widget _buildConnectionCard(dynamic connection) {
    return Card(
      margin: EdgeInsets.only(
        bottom: responsive.responsiveValue(
          mobile: 8,
          tablet: 12,
        ),
      ),
      child: ListTile(
        contentPadding: responsive.responsivePadding(all: 12),
        leading: CircleAvatar(
          radius: responsive.responsiveValue(
            mobile: 24,
            tablet: 32,
          ),
          backgroundImage: NetworkImage(
            connection.photoUrl ?? 'https://via.placeholder.com/150',
          ),
        ),
        title: ResponsiveText(
          connection.fullName,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 16,
              tablet: 18,
            ),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: ResponsiveText(
          connection.title ?? 'Başlık belirtilmemiş',
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 14,
              tablet: 16,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AdaptiveTouchTarget(
              onTap: () => controller.onMessageTap(connection),
              child: Icon(
                Icons.message,
                size: responsive.responsiveValue(
                  mobile: 24,
                  tablet: 28,
                ),
              ),
            ),
            AdaptiveTouchTarget(
              onTap: () => _showConnectionOptions(connection),
              child: Icon(
                Icons.more_vert,
                size: responsive.responsiveValue(
                  mobile: 24,
                  tablet: 28,
                ),
              ),
            ),
          ],
        ),
        onTap: () => controller.onUserTap(connection),
      ),
    );
  }

  Widget _buildRequestsTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelStyle: TextStyle(
              fontSize: responsive.responsiveValue(
                mobile: 14,
                tablet: 16,
              ),
            ),
            tabs: [
              Tab(text: 'Gelen İstekler'),
              Tab(text: 'Giden İstekler'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildRequestList(controller.incomingRequests, true),
                _buildRequestList(controller.outgoingRequests, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestList(RxList requests, bool isIncoming) {
    return Obx(() {
      if (controller.isLoadingRequests.value) {
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: responsive.responsiveValue(
              mobile: 2,
              tablet: 3,
            ),
          ),
        );
      }
      return AnimatedResponsiveLayout(
        mobile: _buildMobileRequestList(requests, isIncoming),
        tablet: _buildTabletRequestList(requests, isIncoming),
        animationDuration: const Duration(milliseconds: 300),
      );
    });
  }

  Widget _buildMobileRequestList(RxList requests, bool isIncoming) {
    return ListView.builder(
      padding: responsive.responsivePadding(all: 16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildRequestCard(request, isIncoming);
      },
    );
  }

  Widget _buildTabletRequestList(RxList requests, bool isIncoming) {
    return GridView.builder(
      padding: responsive.responsivePadding(all: 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: responsive.responsiveValue(
          mobile: 3,
          tablet: 3,
        ),
        crossAxisSpacing: responsive.responsiveValue(
          mobile: 24,
          tablet: 24,
        ),
        mainAxisSpacing: responsive.responsiveValue(
          mobile: 24,
          tablet: 24,
        ),
      ),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildRequestCard(request, isIncoming);
      },
    );
  }

  Widget _buildRequestCard(dynamic request, bool isIncoming) {
    return Card(
      margin: EdgeInsets.only(
        bottom: responsive.responsiveValue(
          mobile: 8,
          tablet: 12,
        ),
      ),
      child: ListTile(
        contentPadding: responsive.responsivePadding(all: 12),
        leading: CircleAvatar(
          radius: responsive.responsiveValue(
            mobile: 24,
            tablet: 32,
          ),
          backgroundImage: NetworkImage(request.profileImage),
        ),
        title: ResponsiveText(
          request.fullName,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 16,
              tablet: 18,
            ),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveText(
              request.title,
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 14,
                  tablet: 16,
                ),
              ),
            ),
            if (request.mutualConnections > 0)
              ResponsiveText(
                '${request.mutualConnections} ortak bağlantı',
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 12,
                    tablet: 14,
                  ),
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isIncoming)
              AdaptiveTouchTarget(
                onTap: () => controller.acceptRequest(request),
                child: Icon(
                  Icons.check,
                  size: responsive.responsiveValue(
                    mobile: 24,
                    tablet: 28,
                  ),
                  color: Colors.green,
                ),
              ),
            AdaptiveTouchTarget(
              onTap: () => _showRequestActionDialog(request, isIncoming),
              child: Icon(
                isIncoming ? Icons.close : Icons.delete,
                size: responsive.responsiveValue(
                  mobile: 24,
                  tablet: 28,
                ),
                color: Colors.red,
              ),
            ),
          ],
        ),
        onTap: () => controller.onUserTap(request),
      ),
    );
  }

  void _showConnectionOptions(dynamic connection) {
    Get.bottomSheet(
      Container(
        padding: responsive.responsivePadding(all: 16),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(responsive.responsiveValue(
              mobile: 16,
              tablet: 16,
            )),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.person,
                size: responsive.responsiveValue(
                  mobile: 24,
                  tablet: 28,
                ),
              ),
              title: ResponsiveText(
                'Profili Görüntüle',
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 16,
                    tablet: 18,
                  ),
                ),
              ),
              onTap: () {
                Get.back();
                controller.onUserTap(connection);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.message,
                size: responsive.responsiveValue(
                  mobile: 24,
                  tablet: 28,
                ),
              ),
              title: ResponsiveText(
                'Mesaj Gönder',
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 16,
                    tablet: 18,
                  ),
                ),
              ),
              onTap: () {
                Get.back();
                controller.onMessageTap(connection);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.person_remove,
                size: responsive.responsiveValue(
                  mobile: 24,
                  tablet: 28,
                ),
                color: Colors.red,
              ),
              title: ResponsiveText(
                'Bağlantıyı Kaldır',
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 16,
                    tablet: 18,
                  ),
                  color: Colors.red,
                ),
              ),
              onTap: () {
                Get.back();
                _showRemoveConnectionDialog(connection);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestActionDialog(dynamic request, bool isIncoming) {
    Get.dialog(
      AlertDialog(
        title: ResponsiveText(
          isIncoming ? 'İsteği Reddet' : 'İsteği Geri Çek',
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 18,
              tablet: 20,
            ),
          ),
        ),
        content: ResponsiveText(
          isIncoming
              ? 'Bu bağlantı isteğini reddetmek istediğinize emin misiniz?'
              : 'Bu bağlantı isteğini geri çekmek istediğinize emin misiniz?',
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 16,
              tablet: 18,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: ResponsiveText(
              'İptal',
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 14,
                  tablet: 16,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              if (isIncoming) {
                controller.rejectRequest(request);
              } else {
                controller.cancelRequest(request);
              }
            },
            child: ResponsiveText(
              isIncoming ? 'Reddet' : 'Geri Çek',
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 14,
                  tablet: 16,
                ),
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveConnectionDialog(dynamic connection) {
    Get.dialog(
      AlertDialog(
        title: ResponsiveText(
          'Bağlantıyı Kaldır',
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 18,
              tablet: 20,
            ),
          ),
        ),
        content: ResponsiveText(
          'Bu kişiyi bağlantılarınızdan kaldırmak istediğinize emin misiniz?',
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 16,
              tablet: 18,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: ResponsiveText(
              'İptal',
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 14,
                  tablet: 16,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.removeConnection(connection);
            },
            child: ResponsiveText(
              'Kaldır',
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 14,
                  tablet: 16,
                ),
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
