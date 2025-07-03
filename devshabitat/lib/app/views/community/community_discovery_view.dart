import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/community/community_discovery_controller.dart';
import '../../widgets/community/community_card_widget.dart';
import '../../routes/app_pages.dart';

class CommunityDiscoveryView extends GetView<CommunityDiscoveryController> {
  const CommunityDiscoveryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toplulukları Keşfet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: controller.showFilters,
            tooltip: 'Filtrele',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: controller.showSearch,
            tooltip: 'Ara',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshCommunities,
        child: Obx(
          () {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.hasError.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hata: ${controller.errorMessage.value}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: controller.refreshCommunities,
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              );
            }

            if (controller.communities.isEmpty) {
              return const Center(
                child: Text('Henüz topluluk bulunmamaktadır.'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              itemCount: controller.communities.length,
              itemBuilder: (context, index) {
                final community = controller.communities[index];
                return CommunityCardWidget(
                  community: community,
                  isManageable: controller.isUserModerator(community),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.COMMUNITY_CREATE),
        icon: const Icon(Icons.add),
        label: const Text('Topluluk Oluştur'),
      ),
    );
  }
}
