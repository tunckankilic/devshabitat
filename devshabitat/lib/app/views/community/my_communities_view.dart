import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/community/my_communities_controller.dart';
import '../../widgets/community/community_card_widget.dart';
import '../../routes/app_pages.dart';

class MyCommunitiesView extends GetView<MyCommunitiesController> {
  const MyCommunitiesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Topluluklarım'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Üye Olduğum'),
              Tab(text: 'Yönettiğim'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Üye Olunan Topluluklar
            Obx(
              () {
                if (controller.isLoadingMemberships.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.error.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hata: ${controller.error.value}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: controller.loadCommunities,
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.memberCommunities.isEmpty) {
                  return const Center(
                    child: Text('Henüz bir topluluğa üye değilsiniz.'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.loadCommunities,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: controller.memberCommunities.length,
                    itemBuilder: (context, index) {
                      final community = controller.memberCommunities[index];
                      return CommunityCardWidget(
                        community: community,
                        isManageable: false,
                      );
                    },
                  ),
                );
              },
            ),

            // Yönetilen Topluluklar
            Obx(
              () {
                if (controller.isLoadingManaged.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.error.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hata: ${controller.error.value}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: controller.loadCommunities,
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.managedCommunities.isEmpty) {
                  return const Center(
                    child: Text('Henüz bir topluluk yönetmiyorsunuz.'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.loadCommunities,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: controller.managedCommunities.length,
                    itemBuilder: (context, index) {
                      final community = controller.managedCommunities[index];
                      return CommunityCardWidget(
                        community: community,
                        isManageable: true,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Get.toNamed(AppRoutes.COMMUNITY_CREATE),
          icon: const Icon(Icons.add),
          label: const Text('Topluluk Oluştur'),
        ),
      ),
    );
  }
}
