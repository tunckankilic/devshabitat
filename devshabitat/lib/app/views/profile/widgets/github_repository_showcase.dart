import 'package:flutter/material.dart';
import '../../../widgets/responsive/responsive_text.dart';

class GithubRepositoryShowcase extends StatelessWidget {
  final List<Map<String, dynamic>> repositories;
  final VoidCallback? onRefresh;
  final bool isLoading;

  const GithubRepositoryShowcase({
    super.key,
    required this.repositories,
    this.onRefresh,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.folder_special,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ResponsiveText(
                    'Repository Showcase',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                if (onRefresh != null)
                  IconButton(
                    onPressed: isLoading ? null : onRefresh,
                    icon: isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.grey[600],
                            ),
                          )
                        : Icon(Icons.refresh, color: Colors.grey[600]),
                  ),
              ],
            ),
            SizedBox(height: 16),
            if (repositories.isEmpty)
              _buildEmptyState(context)
            else
              _buildRepositoryList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_outlined,
              size: 40,
              color: Colors.grey[400],
            ),
            SizedBox(height: 8),
            ResponsiveText(
              'Repository bulunamadı',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            ResponsiveText(
              'GitHub hesabınızda public repository yok',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepositoryList(BuildContext context) {
    return Column(
      children: repositories.take(5).map((repo) {
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.folder,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ResponsiveText(
                      repo['name'] ?? 'Unknown Repository',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  if (repo['private'] == true)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ResponsiveText(
                        'Private',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              if (repo['description'] != null) ...[
                SizedBox(height: 8),
                ResponsiveText(
                  repo['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 12),
              Row(
                children: [
                  if (repo['language'] != null) ...[
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getLanguageColor(repo['language']),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6),
                    ResponsiveText(
                      repo['language'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 16),
                  ],
                  Icon(
                    Icons.star_outline,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  SizedBox(width: 4),
                  ResponsiveText(
                    '${repo['stargazers_count'] ?? 0}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(width: 16),
                  Icon(
                    Icons.call_split,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  SizedBox(width: 4),
                  ResponsiveText(
                    '${repo['forks_count'] ?? 0}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getLanguageColor(String language) {
    final colors = {
      'JavaScript': Colors.yellow[600]!,
      'TypeScript': Colors.blue[600]!,
      'Python': Colors.blue[400]!,
      'Java': Colors.orange[600]!,
      'C++': Colors.pink[600]!,
      'C#': Colors.purple[600]!,
      'PHP': Colors.purple[400]!,
      'Ruby': Colors.red[600]!,
      'Go': Colors.cyan[600]!,
      'Rust': Colors.orange[700]!,
      'Swift': Colors.orange[500]!,
      'Kotlin': Colors.purple[500]!,
      'Dart': Colors.blue[500]!,
      'HTML': Colors.orange[500]!,
      'CSS': Colors.pink[500]!,
      'Shell': Colors.green[600]!,
      'Dockerfile': Colors.blue[400]!,
      'Vue': Colors.green[500]!,
      'React': Colors.cyan[500]!,
      'Angular': Colors.red[500]!,
    };

    return colors[language] ?? Colors.grey[400]!;
  }
}
