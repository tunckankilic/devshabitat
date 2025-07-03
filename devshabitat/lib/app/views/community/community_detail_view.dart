import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/community/community_controller.dart';
import '../../widgets/community/community_stats_widget.dart';
import '../../widgets/community/member_list_widget.dart';
import '../../widgets/community/membership_request_widget.dart';
import '../../routes/app_pages.dart';

class CommunityDetailView extends GetView<CommunityController> {
  const CommunityDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () {
          if (controller.isLoading.value) {
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
                    onPressed: () => controller
                        .loadCommunity(controller.community.value?.id ?? ''),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          final community = controller.community.value;
          if (community == null) {
            return const Center(
              child: Text('Topluluk bulunamadı'),
            );
          }

          return CustomScrollView(
            slivers: [
              // Kapak Fotoğrafı ve Topluluk Adı
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(community.name),
                  background: community.coverImageUrl != null
                      ? Image.network(
                          community.coverImageUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Theme.of(context).primaryColor,
                        ),
                ),
                actions: [
                  if (controller.isUserModerator.value)
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () => Get.toNamed(
                        AppRoutes.COMMUNITY_MANAGE,
                        arguments: community,
                      ),
                      tooltip: 'Topluluk Yönetimi',
                    ),
                ],
              ),

              // İçerik
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Topluluk Açıklaması
                      Text(
                        community.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),

                      // Topluluk İstatistikleri
                      CommunityStatsWidget(community: community),
                      const SizedBox(height: 24),

                      // Üyelik Durumu / Katıl Butonu
                      if (!controller.isUserModerator.value)
                        Obx(
                          () => Center(
                            child: ElevatedButton.icon(
                              onPressed: controller.isMember.value
                                  ? controller.leaveCommunity
                                  : controller.joinCommunity,
                              icon: Icon(
                                controller.isMember.value
                                    ? Icons.exit_to_app
                                    : Icons.person_add,
                              ),
                              label: Text(
                                controller.isMember.value
                                    ? 'Topluluktan Ayrıl'
                                    : 'Topluluğa Katıl',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: controller.isMember.value
                                    ? Colors.red
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Moderatör ise Üyelik Talepleri
                      if (controller.isUserModerator.value &&
                          controller.pendingMembers.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MembershipRequestWidget(
                              pendingMembers: controller.pendingMembers,
                              onAccept: controller.acceptMember,
                              onReject: controller.rejectMember,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),

                      // Üye Listesi
                      Text(
                        'Üyeler',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      MemberListWidget(
                        members: controller.members,
                        isAdmin: controller.isUserModerator.value,
                        onMemberTap: controller.showMemberProfile,
                        onRemoveMember: controller.removeMember,
                        onPromoteToModerator: controller.promoteToModerator,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
