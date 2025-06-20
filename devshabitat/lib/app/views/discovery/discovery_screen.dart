import 'package:devshabitat/app/widgets/user_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'advanced_filters_screen.dart';
import '../../controllers/discovery_controller.dart';

class DiscoveryScreen extends GetView<DiscoveryController> {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Keşfet', style: TextStyle(fontSize: 18.sp)),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.search, size: 24.sp), text: 'Arama'),
              Tab(icon: Icon(Icons.recommend, size: 24.sp), text: 'Öneriler'),
              Tab(icon: Icon(Icons.people, size: 24.sp), text: 'Bağlantılar'),
              Tab(icon: Icon(Icons.person_add, size: 24.sp), text: 'İstekler'),
            ],
            labelStyle: TextStyle(fontSize: 14.sp),
          ),
        ),
        body: TabBarView(
          children: [
            _buildSearchTab(),
            _buildRecommendationsTab(),
            _buildConnectionsTab(),
            _buildRequestsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.to(() => const AdvancedFiltersScreen()),
          child: Icon(Icons.filter_list, size: 24.sp),
        ),
      ),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.r),
          child: TextField(
            onChanged: controller.onSearchQueryChanged,
            style: TextStyle(fontSize: 16.sp),
            decoration: InputDecoration(
              hintText: 'Kullanıcı ara...',
              hintStyle: TextStyle(fontSize: 16.sp),
              prefixIcon: Icon(Icons.search, size: 24.sp),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
        Expanded(
          child: Obx(() => GridView.builder(
                padding: EdgeInsets.all(16.r),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      MediaQuery.of(Get.context!).size.width > 600 ? 3 : 2,
                  childAspectRatio: 0.75.w,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                ),
                itemCount: controller.searchResults.length,
                itemBuilder: (context, index) {
                  final user = controller.searchResults[index];
                  return UserCard(
                    user: user,
                    onTap: () => controller.onUserTap(user),
                  );
                },
              )),
        ),
      ],
    );
  }

  Widget _buildRecommendationsTab() {
    return Obx(() {
      if (controller.isLoadingRecommendations.value) {
        return Center(child: CircularProgressIndicator(strokeWidth: 2.w));
      }
      return RefreshIndicator(
        onRefresh: controller.refreshRecommendations,
        child: GridView.builder(
          padding: EdgeInsets.all(16.r),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                MediaQuery.of(Get.context!).size.width > 600 ? 3 : 2,
            childAspectRatio: 0.75.w,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
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
        ),
      );
    });
  }

  Widget _buildConnectionsTab() {
    return Obx(() {
      if (controller.isLoadingConnections.value) {
        return Center(child: CircularProgressIndicator(strokeWidth: 2.w));
      }
      return ListView.builder(
        padding: EdgeInsets.all(16.r),
        itemCount: controller.connections.length,
        itemBuilder: (context, index) {
          final connection = controller.connections[index];
          return Card(
            margin: EdgeInsets.only(bottom: 8.h),
            child: ListTile(
              contentPadding: EdgeInsets.all(12.r),
              leading: CircleAvatar(
                radius: 24.r,
                backgroundImage: NetworkImage(
                    connection.photoUrl ?? 'https://via.placeholder.com/150'),
              ),
              title: Text(
                connection.fullName,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                connection.title ?? 'Başlık belirtilmemiş',
                style: TextStyle(fontSize: 14.sp),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.message, size: 24.sp),
                    onPressed: () => controller.onMessageTap(connection),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, size: 24.sp),
                    onPressed: () => _showConnectionOptions(connection),
                  ),
                ],
              ),
              onTap: () => controller.onUserTap(connection),
            ),
          );
        },
      );
    });
  }

  Widget _buildRequestsTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelStyle: TextStyle(fontSize: 14.sp),
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
        return Center(child: CircularProgressIndicator(strokeWidth: 2.w));
      }
      return ListView.builder(
        padding: EdgeInsets.all(16.r),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return Card(
            margin: EdgeInsets.only(bottom: 8.h),
            child: ListTile(
              contentPadding: EdgeInsets.all(12.r),
              leading: CircleAvatar(
                radius: 24.r,
                backgroundImage: NetworkImage(request.profileImage),
              ),
              title: Text(
                request.fullName,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.title,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  if (request.mutualConnections > 0)
                    Text(
                      '${request.mutualConnections} ortak bağlantı',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isIncoming)
                    IconButton(
                      icon: Icon(Icons.check, size: 24.sp, color: Colors.green),
                      onPressed: () => controller.acceptRequest(request),
                    ),
                  IconButton(
                    icon: Icon(
                      isIncoming ? Icons.close : Icons.delete,
                      size: 24.sp,
                      color: Colors.red,
                    ),
                    onPressed: () =>
                        _showRequestActionDialog(request, isIncoming),
                  ),
                ],
              ),
              onTap: () => controller.onUserTap(request),
            ),
          );
        },
      );
    });
  }

  void _showConnectionOptions(dynamic connection) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.person, size: 24.sp),
              title: Text(
                'Profili Görüntüle',
                style: TextStyle(fontSize: 16.sp),
              ),
              onTap: () {
                Get.back();
                controller.onUserTap(connection);
              },
            ),
            ListTile(
              leading: Icon(Icons.message, size: 24.sp),
              title: Text(
                'Mesaj Gönder',
                style: TextStyle(fontSize: 16.sp),
              ),
              onTap: () {
                Get.back();
                controller.onMessageTap(connection);
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.person_remove, size: 24.sp, color: Colors.red),
              title: Text(
                'Bağlantıyı Kaldır',
                style: TextStyle(fontSize: 16.sp, color: Colors.red),
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
        title: Text(
          isIncoming ? 'İsteği Reddet' : 'İsteği Geri Çek',
          style: TextStyle(fontSize: 18.sp),
        ),
        content: Text(
          isIncoming
              ? 'Bu bağlantı isteğini reddetmek istediğinize emin misiniz?'
              : 'Bu bağlantı isteğini geri çekmek istediğinize emin misiniz?',
          style: TextStyle(fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'İptal',
              style: TextStyle(fontSize: 14.sp),
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
            child: Text(
              isIncoming ? 'Reddet' : 'Geri Çek',
              style: TextStyle(fontSize: 14.sp, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveConnectionDialog(dynamic connection) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Bağlantıyı Kaldır',
          style: TextStyle(fontSize: 18.sp),
        ),
        content: Text(
          'Bu kişiyi bağlantılarınızdan kaldırmak istediğinize emin misiniz?',
          style: TextStyle(fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'İptal',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.removeConnection(connection);
            },
            child: Text(
              'Kaldır',
              style: TextStyle(fontSize: 14.sp, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
