import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/simple_recommendation_service.dart';
import '../../models/enhanced_user_model.dart';
import '../../algorithms/connection_scoring_algorithm.dart';
import '../../repositories/enhanced_auth_repository.dart';

class RecommendationsScreen extends StatelessWidget {
  final SimpleRecommendationService _recommendationService = Get.find();
  final EnhancedAuthRepository _authRepository = Get.find();
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
        'Hata',
        'Öneriler yüklenirken bir hata oluştu',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tanıyor Olabileceğiniz Kişiler'),
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
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: Get.theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Henüz Öneri Yok',
                style: Get.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Daha fazla öneri almak için profilinizi güncelleyin:\n\n'
                '• Yeteneklerinizi ekleyin\n'
                '• İş deneyimlerinizi paylaşın\n'
                '• Lokasyon bilginizi güncelleyin\n'
                '• Şirket bilgilerinizi ekleyin',
                style: Get.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => Get.toNamed('/profile/edit'),
                icon: const Icon(Icons.edit),
                label: const Text('Profili Düzenle'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationsList() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Önerilen Bağlantılar',
                  style: Get.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Yetenekler, deneyimler ve ortak noktalar baz alınarak önerilir',
                  style: Get.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              childAspectRatio: 0.75,
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
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => Get.toNamed('/profile/${user.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : null,
                  child: user.photoURL == null
                      ? Text(
                          user.displayName?[0].toUpperCase() ?? 'A',
                          style: const TextStyle(fontSize: 24),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user.displayName ?? 'İsimsiz Kullanıcı',
                style: Get.textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (user.experience?.isNotEmpty ?? false) ...[
                const SizedBox(height: 4),
                Text(
                  user.experience!.first['role'] ?? '',
                  style: Get.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user.experience!.first['company'] ?? '',
                  style: Get.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _sendConnectionRequest(user),
                icon: const Icon(Icons.person_add),
                label: const Text('Bağlan'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 36),
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
        'Başarılı',
        'Bağlantı isteği gönderildi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _recommendations.remove(user);
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Bağlantı isteği gönderilemedi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
