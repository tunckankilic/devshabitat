import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/github_repository_model.dart';
import '../../controllers/github_content_controller.dart';

class RepositoryShowcaseWidget extends StatelessWidget {
  final GitHubRepositoryModel repository;
  final bool showFullDescription;
  final bool enableInteractions;

  const RepositoryShowcaseWidget({
    Key? key,
    required this.repository,
    this.showFullDescription = false,
    this.enableInteractions = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GitHubContentController>();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Repository Header
            Row(
              children: [
                Icon(Icons.book_outlined),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    repository.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (repository.isPrivate) Icon(Icons.lock_outline, size: 16),
              ],
            ),

            SizedBox(height: 12),

            // Description
            if (repository.description != null) ...[
              Text(
                repository.description!,
                maxLines: showFullDescription ? null : 3,
                overflow: showFullDescription ? null : TextOverflow.ellipsis,
              ),
              SizedBox(height: 16),
            ],

            // Stats Row
            Row(
              children: [
                _buildStat(Icons.star_border, '${repository.stars}', 'Yıldız'),
                SizedBox(width: 16),
                _buildStat(Icons.call_split, '${repository.forks}', 'Fork'),
                SizedBox(width: 16),
                _buildStat(
                  Icons.remove_red_eye_outlined,
                  '${repository.watchers}',
                  'İzleyici',
                ),
              ],
            ),

            SizedBox(height: 16),

            // Language Stats
            if (repository.languages.isNotEmpty) ...[
              Text(
                'Kullanılan Diller',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              Row(
                children: repository.languages.entries
                    .map((e) => _buildLanguageChip(e.key, e.value))
                    .toList(),
              ),
              SizedBox(height: 16),
            ],

            // Interaction Buttons
            if (enableInteractions) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: 'Tartışma',
                    onPressed: () => controller.openDiscussion(repository),
                  ),
                  _buildActionButton(
                    icon: Icons.share,
                    label: 'Paylaş',
                    onPressed: () => controller.shareRepository(repository),
                  ),
                  _buildActionButton(
                    icon: Icons.code,
                    label: 'İşbirliği',
                    onPressed: () =>
                        controller.initiateCollaboration(repository),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String count, String label) {
    return Row(
      children: [
        Icon(icon, size: 16),
        SizedBox(width: 4),
        Text(count),
        SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  Widget _buildLanguageChip(String language, double percentage) {
    return Chip(
      label: Text(
        '$language ${percentage.toStringAsFixed(1)}%',
        style: TextStyle(fontSize: 12),
      ),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}
