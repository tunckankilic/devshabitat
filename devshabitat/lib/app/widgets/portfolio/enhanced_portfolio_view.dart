// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/portfolio_controller.dart';
import '../../models/portfolio/tech_stack_model.dart';
import '../../models/portfolio/project_model.dart';

class EnhancedPortfolioView extends GetView<PortfolioController> {
  const EnhancedPortfolioView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TechStackVisualizer(),
          const SizedBox(height: 24),
          const ProjectShowcase(),
          const SizedBox(height: 24),
          const ContributionTimeline(),
        ],
      ),
    );
  }
}

class TechStackVisualizer extends GetView<PortfolioController> {
  const TechStackVisualizer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Teknoloji Stack',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: controller.techStack
                    .map((tech) => TechStackItem(tech: tech))
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class TechStackItem extends StatelessWidget {
  final TechStackModel tech;

  const TechStackItem({
    super.key,
    required this.tech,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(tech.name),
      subtitle: Row(
        children: [
          Icon(
            _getExperienceLevelIcon(tech.experienceLevel),
            size: 16,
            color: _getExperienceLevelColor(tech.experienceLevel),
          ),
          const SizedBox(width: 8),
          Text(_getExperienceLevelText(tech.experienceLevel)),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${tech.projectCount} proje'),
          Text('${tech.totalStars} yıldız'),
        ],
      ),
    );
  }

  IconData _getExperienceLevelIcon(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.beginner:
        return Icons.star_border;
      case ExperienceLevel.intermediate:
        return Icons.star_half;
      case ExperienceLevel.advanced:
        return Icons.star;
      case ExperienceLevel.expert:
        return Icons.auto_awesome;
    }
  }

  Color _getExperienceLevelColor(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.beginner:
        return Colors.green;
      case ExperienceLevel.intermediate:
        return Colors.blue;
      case ExperienceLevel.advanced:
        return Colors.purple;
      case ExperienceLevel.expert:
        return Colors.orange;
    }
  }

  String _getExperienceLevelText(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.beginner:
        return 'Başlangıç';
      case ExperienceLevel.intermediate:
        return 'Orta Seviye';
      case ExperienceLevel.advanced:
        return 'İleri Seviye';
      case ExperienceLevel.expert:
        return 'Uzman';
    }
  }
}

class ProjectShowcase extends GetView<PortfolioController> {
  const ProjectShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Öne Çıkan Projeler',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.featuredProjects.length,
                itemBuilder: (context, index) {
                  return ProjectCard(
                    project: controller.featuredProjects[index],
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final ProjectModel project;

  const ProjectCard({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(project.description),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(project.language),
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16),
                    const SizedBox(width: 4),
                    Text('${project.stars}'),
                    const SizedBox(width: 16),
                    const Icon(Icons.call_split, size: 16),
                    const SizedBox(width: 4),
                    Text('${project.forks}'),
                  ],
                ),
              ],
            ),
            if (project.topics.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: project.topics
                    .map((topic) => Chip(
                          label: Text(topic),
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ContributionTimeline extends GetView<PortfolioController> {
  const ContributionTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Katkı Zaman Çizelgesi',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.contributionData.isEmpty) {
                return const Center(
                  child: Text('Katkı verisi bulunamadı'),
                );
              }

              return SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: controller.contributionData.entries
                            .map((e) => FlSpot(
                                  e.key.hashCode.toDouble(),
                                  e.value.toDouble(),
                                ))
                            .toList(),
                        isCurved: true,
                        color: Theme.of(context).primaryColor,
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
