import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/github_content_controller.dart';
import '../../models/github_repository_model.dart';
import '../../models/collaboration_request_model.dart';

class CodeCollaborationWidget extends StatelessWidget {
  final GitHubRepositoryModel repository;
  final CollaborationRequestModel? existingRequest;

  const CodeCollaborationWidget({
    super.key,
    required this.repository,
    this.existingRequest,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GitHubContentController>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'İşbirliği İsteği',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),

            // Repository Info
            ListTile(
              leading: Icon(Icons.book_outlined),
              title: Text(repository.name),
              subtitle: Text(repository.description ?? ''),
              trailing: repository.isPrivate
                  ? Icon(Icons.lock_outline)
                  : Icon(Icons.public),
            ),

            Divider(),

            // Collaboration Type Selection
            _buildCollaborationTypeSection(controller),

            SizedBox(height: 16),

            // Message Input
            _buildMessageInput(controller),

            SizedBox(height: 16),

            // Skills and Requirements
            _buildSkillsSection(controller),

            SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (existingRequest != null)
                  TextButton(
                    onPressed: () => controller.cancelCollaborationRequest(
                      repository,
                      existingRequest!,
                    ),
                    child: Text('İptal Et'),
                  ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => controller.submitCollaborationRequest(
                    repository,
                    existingRequest,
                  ),
                  child: Text(existingRequest != null ? 'Güncelle' : 'Gönder'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollaborationTypeSection(GitHubContentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('İşbirliği Türü', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildCollaborationTypeChip('Kod İnceleme', Icons.code, controller),
            _buildCollaborationTypeChip(
              'Hata Düzeltme',
              Icons.bug_report,
              controller,
            ),
            _buildCollaborationTypeChip(
              'Özellik Geliştirme',
              Icons.build,
              controller,
            ),
            _buildCollaborationTypeChip(
              'Dokümantasyon',
              Icons.description,
              controller,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCollaborationTypeChip(
    String label,
    IconData icon,
    GitHubContentController controller,
  ) {
    return Obx(() {
      final isSelected = controller.selectedCollaborationType.value == label;
      return FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(icon, size: 16), SizedBox(width: 4), Text(label)],
        ),
        selected: isSelected,
        onSelected: (bool selected) {
          controller.setCollaborationType(selected ? label : null);
        },
      );
    });
  }

  Widget _buildMessageInput(GitHubContentController controller) {
    return TextField(
      controller: controller.messageController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'İşbirliği Mesajı',
        hintText: 'Projeye nasıl katkıda bulunmak istediğinizi açıklayın...',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildSkillsSection(GitHubContentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gerekli Beceriler',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: repository.languages.keys.map((language) {
            return Obx(() {
              final isSelected = controller.selectedSkills.contains(language);
              return FilterChip(
                label: Text(language),
                selected: isSelected,
                onSelected: (bool selected) {
                  controller.toggleSkill(language);
                },
              );
            });
          }).toList(),
        ),
      ],
    );
  }
}
