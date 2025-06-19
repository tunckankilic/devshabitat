import 'package:devshabitat/app/widgets/user_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          title: const Text('Keşfet'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.search), text: 'Arama'),
              Tab(icon: Icon(Icons.recommend), text: 'Öneriler'),
              Tab(icon: Icon(Icons.people), text: 'Bağlantılar'),
              Tab(icon: Icon(Icons.person_add), text: 'İstekler'),
            ],
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
          child: const Icon(Icons.filter_list),
        ),
      ),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: controller.onSearchQueryChanged,
            decoration: InputDecoration(
              hintText: 'Kullanıcı ara...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Expanded(
          child: Obx(() => GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
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
        return const Center(child: CircularProgressIndicator());
      }
      return RefreshIndicator(
        onRefresh: controller.refreshRecommendations,
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
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
        return const Center(child: CircularProgressIndicator());
      }
      return ListView.builder(
        itemCount: controller.connections.length,
        itemBuilder: (context, index) {
          final connection = controller.connections[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                  connection.photoUrl ?? 'https://via.placeholder.com/150'),
            ),
            title: Text(connection.fullName),
            subtitle: Text(connection.title ?? 'Başlık belirtilmemiş'),
            trailing: IconButton(
              icon: const Icon(Icons.message),
              onPressed: () => controller.onMessageTap(connection),
            ),
            onTap: () => controller.onUserTap(connection),
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
          const TabBar(
            tabs: [
              Tab(text: 'Gelen İstekler'),
              Tab(text: 'Giden İstekler'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildRequestList(controller.incomingRequests),
                _buildRequestList(controller.outgoingRequests),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestList(RxList requests) {
    return Obx(() {
      if (controller.isLoadingRequests.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(request.profileImage),
            ),
            title: Text(request.fullName),
            subtitle: Text(request.title),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (request.isIncoming)
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () => controller.acceptRequest(request),
                  ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => controller.rejectRequest(request),
                ),
              ],
            ),
            onTap: () => controller.onUserTap(request),
          );
        },
      );
    });
  }
}
