// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/controllers/developer_matching_controller.dart';
import 'package:devshabitat/app/models/user_profile_model.dart';
import 'package:devshabitat/app/widgets/common/loading_widget.dart';
import 'package:devshabitat/app/widgets/common/error_widget.dart';

class DeveloperMatchingView extends StatefulWidget {
  const DeveloperMatchingView({super.key});

  @override
  State<DeveloperMatchingView> createState() => _DeveloperMatchingViewState();
}

class _DeveloperMatchingViewState extends State<DeveloperMatchingView>
    with TickerProviderStateMixin {
  final DeveloperMatchingController controller = Get.find();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(1.5, 0)).animate(
            CurvedAnimation(
                parent: _animationController, curve: Curves.easeInOut));

    // İlk yükleme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.findSimilarDevelopers();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Eşleştirme'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showPreferencesDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refresh(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: LoadingWidget());
        }

        if (controller.error.isNotEmpty) {
          return CustomErrorWidget(
            message: controller.error.value,
            onRetry: () => controller.findSimilarDevelopers(),
          );
        }

        if (controller.similarDevelopers.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            _buildStatsCard(),
            Expanded(child: _buildSwipeCards()),
            _buildActionButtons(),
          ],
        );
      }),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Eşleşme', '${controller.similarDevelopers.length}'),
          _buildStatItem('Skor', '85%'),
          _buildStatItem('Mesafe', '< 10km'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Get.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Get.theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: Get.textTheme.bodySmall?.copyWith(
            color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeCards() {
    return PageView.builder(
      itemCount: controller.similarDevelopers.length,
      itemBuilder: (context, index) {
        final developer = controller.similarDevelopers[index];
        return GestureDetector(
          onPanUpdate: (details) {
            // Swipe animasyonu için pan gesture
            if (details.delta.dx > 10) {
              // Sağa swipe - like
              _handleSwipe(true);
            } else if (details.delta.dx < -10) {
              // Sola swipe - dislike
              _handleSwipe(false);
            }
          },
          child: _buildDeveloperCard(developer, index),
        );
      },
    );
  }

  Widget _buildDeveloperCard(UserProfile developer, int index) {
    final matchScore = controller.calculateMatchScore(developer);

    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            // Profile Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  image: developer.photoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(developer.photoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: developer.photoUrl == null
                    ? Container(
                        color: Get.theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person,
                          size: 80,
                          color: Get.theme.colorScheme.onPrimaryContainer,
                        ),
                      )
                    : null,
              ),
            ),

            // Profile Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            developer.fullName,
                            style: Get.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getMatchScoreColor(matchScore),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(matchScore * 100).toInt()}%',
                            style: Get.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (developer.title != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        developer.title!,
                        style: Get.textTheme.bodyMedium?.copyWith(
                          color:
                              Get.theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],

                    if (developer.company != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        developer.company!,
                        style: Get.textTheme.bodySmall?.copyWith(
                          color:
                              Get.theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Skills
                    if (developer.skills.isNotEmpty) ...[
                      Text(
                        'Yetenekler',
                        style: Get.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: developer.skills
                            .take(5)
                            .map((skill) => Chip(
                                  label: Text(skill),
                                  backgroundColor:
                                      Get.theme.colorScheme.primaryContainer,
                                  labelStyle: Get.textTheme.bodySmall?.copyWith(
                                    color: Get
                                        .theme.colorScheme.onPrimaryContainer,
                                  ),
                                ))
                            .toList(),
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Location
                    if (developer.locationName != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Get.theme.colorScheme.onSurface
                                .withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            developer.locationName!,
                            style: Get.textTheme.bodySmall?.copyWith(
                              color: Get.theme.colorScheme.onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMatchScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.close,
            color: Colors.red,
            onPressed: () => _handleSwipe(false),
          ),
          _buildActionButton(
            icon: Icons.favorite,
            color: Colors.green,
            onPressed: () => _handleSwipe(true),
          ),
          _buildActionButton(
            icon: Icons.message,
            color: Colors.blue,
            onPressed: () => _showMessageDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        iconSize: 28,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz eşleşme bulunamadı',
            style: Get.textTheme.headlineSmall?.copyWith(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Daha fazla geliştirici bulmak için ayarlarınızı güncelleyin',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showPreferencesDialog(),
            child: const Text('Ayarları Güncelle'),
          ),
        ],
      ),
    );
  }

  void _handleSwipe(bool isLike) async {
    if (controller.similarDevelopers.isEmpty) return;

    final currentDeveloper = controller.similarDevelopers.first;

    // Animasyon başlat
    await _animationController.forward();

    if (isLike) {
      // Eşleşme kontrolü ve işbirliği talebi
      await controller.sendCollaborationRequest(currentDeveloper.id);

      // Match dialog göster
      if (mounted) {
        _showMatchDialog(currentDeveloper);
      }
    } else {
      // Dislike feedback
      Get.snackbar(
        'Geçti',
        '${currentDeveloper.fullName} geçildi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    }

    // Kartı kaldır
    controller.similarDevelopers.removeAt(0);

    // Animasyonu sıfırla
    _animationController.reset();
  }

  void _showMatchDialog(UserProfile developer) {
    Get.dialog(
      AlertDialog(
        title: const Text('Eşleşme!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: developer.photoUrl != null
                  ? NetworkImage(developer.photoUrl!)
                  : null,
              child: developer.photoUrl == null
                  ? Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              '${developer.fullName} ile eşleştiniz!',
              style: Get.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'İşbirliği talebi gönderildi. Yanıt bekleniyor...',
              style: Get.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tamam'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showMessageDialog();
            },
            child: const Text('Mesaj Gönder'),
          ),
        ],
      ),
    );
  }

  void _showMessageDialog() {
    if (controller.similarDevelopers.isEmpty) return;

    final developer = controller.similarDevelopers.first;

    Get.dialog(
      AlertDialog(
        title: Text('${developer.fullName} ile Mesajlaş'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Mesajınızı yazın...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Başarılı',
                'Mesaj gönderildi',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  void _showPreferencesDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Eşleştirme Ayarları'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Maksimum Mesafe
              _buildSliderPreference(
                'Maksimum Mesafe',
                '${controller.maxDistance.value} km',
                controller.maxDistance.value.toDouble(),
                10.0,
                100.0,
                (value) => controller.maxDistance.value = value.toInt(),
              ),

              const SizedBox(height: 16),

              // Minimum Deneyim
              _buildSliderPreference(
                'Minimum Deneyim',
                '${controller.minExperienceYears.value} yıl',
                controller.minExperienceYears.value.toDouble(),
                0.0,
                20.0,
                (value) => controller.minExperienceYears.value = value.toInt(),
              ),

              const SizedBox(height: 16),

              // Çalışma Türü
              _buildWorkTypePreferences(),

              const SizedBox(height: 16),

              // Tercih Edilen Teknolojiler
              _buildTechnologyPreferences(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.refresh();
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderPreference(
    String label,
    String value,
    double currentValue,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              value,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: Get.theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Slider(
          value: currentValue,
          min: min,
          max: max,
          divisions: ((max - min) / 5).round(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildWorkTypePreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Çalışma Türü',
          style: Get.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Column(
              children: [
                CheckboxListTile(
                  title: const Text('Remote'),
                  value: controller.preferRemote.value,
                  onChanged: (value) =>
                      controller.preferRemote.value = value ?? false,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: const Text('Full-time'),
                  value: controller.preferFullTime.value,
                  onChanged: (value) =>
                      controller.preferFullTime.value = value ?? false,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: const Text('Part-time'),
                  value: controller.preferPartTime.value,
                  onChanged: (value) =>
                      controller.preferPartTime.value = value ?? false,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: const Text('Freelance'),
                  value: controller.preferFreelance.value,
                  onChanged: (value) =>
                      controller.preferFreelance.value = value ?? false,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            )),
      ],
    );
  }

  Widget _buildTechnologyPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tercih Edilen Teknolojiler',
          style: Get.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Flutter, Dart, Firebase (virgülle ayırın)',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            final technologies = value
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
            controller.preferredTechnologies.value = technologies;
          },
        ),
      ],
    );
  }
}
