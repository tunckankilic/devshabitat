import 'package:devshabitat/app/models/user_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/developer_matching_controller.dart';

class DeveloperMatchingWidget extends StatelessWidget {
  const DeveloperMatchingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SkillMatchCard(),
        SizedBox(height: 16),
        ProjectSuggestions(),
        SizedBox(height: 16),
        MentorshipCard(),
      ],
    );
  }
}

class SkillMatchCard extends GetView<DeveloperMatchingController> {
  const SkillMatchCard({super.key});

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
              'Benzer Geliştiriciler',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.similarDevelopers.isEmpty) {
                return const Center(
                  child: Text('Henüz benzer geliştirici bulunamadı'),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.similarDevelopers.length,
                itemBuilder: (context, index) {
                  final developer = controller.similarDevelopers[index];
                  return DeveloperCard(
                    developer: developer,
                    matchScore: controller.calculateMatchScore(developer),
                    onConnect: () => controller.sendCollaborationRequest(
                      developer.id,
                    ),
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

class ProjectSuggestions extends GetView<DeveloperMatchingController> {
  const ProjectSuggestions({super.key});

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
              'İşbirliği Önerileri',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.projectSuggestions.isEmpty) {
                return const Center(
                  child: Text('Henüz proje önerisi bulunamadı'),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.projectSuggestions.length,
                itemBuilder: (context, index) {
                  final project = controller.projectSuggestions[index];
                  return ProjectSuggestionCard(
                    project: project,
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

class MentorshipCard extends GetView<DeveloperMatchingController> {
  const MentorshipCard({super.key});

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
              'Mentorluk Fırsatları',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.potentialMentors.isEmpty) {
                return const Center(
                  child: Text('Henüz mentor bulunamadı'),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.potentialMentors.length,
                itemBuilder: (context, index) {
                  final mentor = controller.potentialMentors[index];
                  return MentorCard(
                    mentor: mentor,
                    onRequest: () => controller.sendMentorshipRequest(
                      mentor.id,
                    ),
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

class DeveloperCard extends StatelessWidget {
  final UserProfile developer;
  final double matchScore;
  final VoidCallback onConnect;

  const DeveloperCard({
    super.key,
    required this.developer,
    required this.matchScore,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(developer.photoUrl ?? ''),
        ),
        title: Text(developer.fullName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (developer.bio != null) Text(developer.bio!),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: developer.skills
                  .map((tech) => Chip(
                        label: Text(tech),
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.1),
                      ))
                  .toList(),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${(matchScore * 100).toInt()}% Eşleşme',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            ElevatedButton(
              onPressed: onConnect,
              child: const Text('Bağlantı Kur'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectSuggestionCard extends StatelessWidget {
  final Map<String, dynamic> project;

  const ProjectSuggestionCard({
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
              project['name'] as String,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(project['description'] as String),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: (project['technologies'] as List)
                  .map((tech) => Chip(
                        label: Text(tech as String),
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.1),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class MentorCard extends StatelessWidget {
  final UserProfile mentor;
  final VoidCallback onRequest;

  const MentorCard({
    super.key,
    required this.mentor,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(mentor.photoUrl ?? ''),
        ),
        title: Text(mentor.fullName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mentor.bio != null) Text(mentor.bio!),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: mentor.skills
                  .map((tech) => Chip(
                        label: Text(tech),
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.1),
                      ))
                  .toList(),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: onRequest,
          child: const Text('Mentorluk İste'),
        ),
      ),
    );
  }
}
