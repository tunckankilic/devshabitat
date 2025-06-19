import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/networking_controller.dart';

class ProfessionalToolsScreen extends StatelessWidget {
  final NetworkingController controller = Get.find<NetworkingController>();

  ProfessionalToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profesyonel Araçlar'),
        centerTitle: true,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSkillGapAnalysis(context),
            const SizedBox(height: 24),
            _buildCareerProgressionTracker(context),
            const SizedBox(height: 24),
            _buildNetworkingGoals(context),
            const SizedBox(height: 24),
            _buildDataExport(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillGapAnalysis(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Yetenek Analizi',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => controller.refreshAnalytics(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              final stats = controller.networkStats.value;
              return Column(
                children: [
                  for (var skill in stats.topSkills)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(skill),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: (stats.skillDistribution[skill] ?? 0)
                                .toDouble(),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer
                                .withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCareerProgressionTracker(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kariyer İlerlemesi',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.7,
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .onTertiaryContainer
                  .withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.onTertiaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildProgressChip(context, 'Mentorluk: 3/5'),
                _buildProgressChip(context, 'Sertifikalar: 2/3'),
                _buildProgressChip(context, 'Projeler: 4/5'),
                _buildProgressChip(context, 'Network: 80%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkingGoals(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Network Hedefleri',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildGoalItem(
              context,
              'Yeni Bağlantılar',
              'Bu ay 10 yeni bağlantı kur',
              0.6,
            ),
            const SizedBox(height: 8),
            _buildGoalItem(
              context,
              'Mentorluk',
              '2 yeni mentor bul',
              0.5,
            ),
            const SizedBox(height: 8),
            _buildGoalItem(
              context,
              'Etkinlikler',
              '3 network etkinliğine katıl',
              0.33,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                // Yeni hedef ekleme
                _showAddGoalDialog(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Yeni Hedef'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataExport(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Veri Dışa Aktarma',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => _exportData(context, 'pdf'),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('PDF Olarak Dışa Aktar'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => _exportData(context, 'csv'),
                  icon: const Icon(Icons.table_chart),
                  label: const Text('CSV Olarak Dışa Aktar'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => _exportData(context, 'json'),
                  icon: const Icon(Icons.code),
                  label: const Text('JSON Olarak Dışa Aktar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChip(BuildContext context, String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
      side: BorderSide.none,
    );
  }

  Widget _buildGoalItem(
    BuildContext context,
    String title,
    String subtitle,
    double progress,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor:
              Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Hedef Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Hedef Başlığı',
                hintText: 'Örn: Yeni Bağlantılar',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Hedef Açıklaması',
                hintText: 'Örn: Bu ay 5 yeni bağlantı kur',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () {
              // Hedef kaydetme işlemi
              Navigator.pop(context);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context, String format) {
    // Dışa aktarma işlemi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Veriler $format formatında dışa aktarılıyor...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
