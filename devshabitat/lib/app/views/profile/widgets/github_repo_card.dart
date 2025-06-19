import 'package:flutter/material.dart';

class GithubRepoCard extends StatelessWidget {
  final Map<String, dynamic> repo;

  const GithubRepoCard({
    super.key,
    required this.repo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Repo Adı
            Text(
              repo['name'] as String,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),

            // Repo Açıklaması
            if (repo['description'] != null)
              Text(
                repo['description'] as String,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 8),

            // Repo İstatistikleri
            Row(
              children: [
                // Dil
                if (repo['language'] != null) ...[
                  Icon(
                    Icons.circle,
                    size: 12,
                    color: _getLanguageColor(repo['language'] as String),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    repo['language'] as String,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                ],

                // Yıldız
                const Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber,
                ),
                const SizedBox(width: 4),
                Text(
                  repo['stars'].toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 16),

                // Fork
                const Icon(
                  Icons.call_split,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  repo['forks'].toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getLanguageColor(String language) {
    switch (language.toLowerCase()) {
      case 'dart':
        return Colors.blue;
      case 'javascript':
        return Colors.yellow;
      case 'python':
        return Colors.green;
      case 'java':
        return Colors.orange;
      case 'kotlin':
        return Colors.purple;
      case 'swift':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
