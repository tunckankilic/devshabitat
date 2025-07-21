import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/simple_recommendation_service.dart';
import '../../models/enhanced_user_model.dart';
import '../../controllers/responsive_controller.dart';

class RecommendationsScreen extends StatelessWidget {
  final SimpleRecommendationService _recommendationService = Get.find();
  final AuthRepository _authRepository = Get.find();
  final RxList<EnhancedUserModel> _recommendations = <EnhancedUserModel>[].obs;
  final RxBool _isLoading = false.obs;

  RecommendationsScreen({super.key});

  Future<void> _loadRecommendations() async {
    try {
      _isLoading.value = true;
      final recommendations =
          await _recommendationService.getRecommendedConnections();
      _recommendations.value = recommendations;
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        AppStrings.errorLoadingRecommendations,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.peopleYouMayKnow,
          style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 18, tablet: 20)),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadRecommendations,
        child: Obx(
          () => _isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : _recommendations.isEmpty
                  ? _buildEmptyState()
                  : _buildRecommendationsList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final responsive = Get.find<ResponsiveController>();

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: responsive.responsivePadding(all: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: responsive.responsiveValue(mobile: 64, tablet: 80),
                color: Get.theme.colorScheme.primary,
              ),
              SizedBox(
                  height: responsive.responsiveValue(mobile: 16, tablet: 24)),
              Text(
                AppStrings.noRecommendations,
                style: Get.textTheme.headlineSmall?.copyWith(
                  fontSize: responsive.responsiveValue(mobile: 20, tablet: 24),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                  height: responsive.responsiveValue(mobile: 8, tablet: 12)),
              Text(
                AppStrings.updateProfileForMoreRecommendations,
                style: Get.textTheme.bodyLarge?.copyWith(
                  fontSize: responsive.responsiveValue(mobile: 16, tablet: 18),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                  height: responsive.responsiveValue(mobile: 24, tablet: 32)),
              FilledButton.icon(
                onPressed: () => Get.toNamed('/profile/edit'),
                icon: Icon(Icons.edit,
                    size: responsive.responsiveValue(mobile: 20, tablet: 24)),
                label: Text(
                  AppStrings.editProfile,
                  style: TextStyle(
                      fontSize:
                          responsive.responsiveValue(mobile: 16, tablet: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationsList() {
    final responsive = Get.find<ResponsiveController>();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: responsive.responsivePadding(all: 16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.recommendedConnections,
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontSize:
                        responsive.responsiveValue(mobile: 20, tablet: 24),
                  ),
                ),
                SizedBox(
                    height: responsive.responsiveValue(mobile: 8, tablet: 12)),
                Text(
                  AppStrings.recommendationsBasedOnSkills,
                  style: Get.textTheme.bodyMedium?.copyWith(
                    fontSize:
                        responsive.responsiveValue(mobile: 14, tablet: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: responsive.responsivePadding(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: responsive.gridColumns,
              mainAxisSpacing: responsive.gridSpacing,
              crossAxisSpacing: responsive.gridSpacing,
              childAspectRatio: responsive.responsiveValue(
                  mobile: 0.75, tablet: 0.85, desktop: 1.0),
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final user = _recommendations[index];
                return _buildRecommendationCard(user);
              },
              childCount: _recommendations.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(EnhancedUserModel user) {
    final responsive = Get.find<ResponsiveController>();

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => Get.toNamed('/profile/${user.id}'),
        child: Padding(
          padding: responsive.responsivePadding(all: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: responsive.responsiveValue(mobile: 40, tablet: 50),
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : null,
                  child: user.photoURL == null
                      ? Text(
                          user.displayName?[0].toUpperCase() ?? 'A',
                          style: TextStyle(
                              fontSize: responsive.responsiveValue(
                                  mobile: 24, tablet: 28)),
                        )
                      : null,
                ),
              ),
              SizedBox(
                  height: responsive.responsiveValue(mobile: 12, tablet: 16)),
              Text(
                user.displayName ?? AppStrings.unknownUser,
                style: Get.textTheme.titleMedium?.copyWith(
                  fontSize: responsive.responsiveValue(mobile: 16, tablet: 18),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (user.experience?.isNotEmpty ?? false) ...[
                SizedBox(
                    height: responsive.responsiveValue(mobile: 4, tablet: 6)),
                Text(
                  user.experience!.first['role'] ?? '',
                  style: Get.textTheme.bodyMedium?.copyWith(
                    fontSize:
                        responsive.responsiveValue(mobile: 14, tablet: 16),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user.experience!.first['company'] ?? '',
                  style: Get.textTheme.bodySmall?.copyWith(
                    fontSize:
                        responsive.responsiveValue(mobile: 12, tablet: 14),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _sendConnectionRequest(user),
                icon: Icon(Icons.person_add,
                    size: responsive.responsiveValue(mobile: 18, tablet: 20)),
                label: Text(
                  AppStrings.connect,
                  style: TextStyle(
                      fontSize:
                          responsive.responsiveValue(mobile: 14, tablet: 16)),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: Size(double.infinity,
                      responsive.responsiveValue(mobile: 36, tablet: 44)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendConnectionRequest(EnhancedUserModel user) async {
    try {
      await _authRepository.addConnection(user.id.value);
      Get.snackbar(
        AppStrings.success,
        AppStrings.connectionRequestSent,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _recommendations.remove(user);
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        AppStrings.connectionRequestFailed,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
