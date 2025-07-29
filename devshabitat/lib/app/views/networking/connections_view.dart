import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/networking_controller.dart';

class ConnectionsView extends GetView<NetworkingController> {
  const ConnectionsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Load suggested connections when view builds
    controller.loadSuggestedConnections();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.addConnection),
        actions: [
          IconButton(
            onPressed: controller.refreshSuggestedConnections,
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: controller.updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Kişi, beceri veya konum ara...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
              ),
            ),
          ),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.isLoadingSuggestions.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text('Önerilen bağlantılar yükleniyor...'),
                    ],
                  ),
                );
              }

              if (controller.suggestionsError.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        controller.suggestionsError.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.loadSuggestedConnections,
                        child: Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                );
              }

              final suggestions = controller.filteredSuggestedConnections;

              if (suggestions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        controller.searchQuery.value.isNotEmpty
                            ? 'Aramanızla eşleşen bağlantı bulunamadı'
                            : 'Henüz önerilen bağlantı bulunmuyor',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final user = suggestions[index];
                  return _buildConnectionCard(user);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionCard(dynamic user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: user.photoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            user.photoUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.blue),
                          ),
                        )
                      : Icon(Icons.person, size: 30, color: Colors.blue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (user.title != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          user.title!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (user.locationName != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              user.locationName!,
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (user.bio != null) ...[
              const SizedBox(height: 12),
              Text(
                user.bio!,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
            if (user.skills.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: user.skills.take(5).map<Widget>((skill) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Obx(() {
                    final isPending = controller.isRequestPending(user.id);
                    return ElevatedButton(
                      onPressed: isPending
                          ? null
                          : () => controller.sendConnectionRequest(user.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPending ? Colors.grey : Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: isPending
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('Gönderiliyor...'),
                              ],
                            )
                          : Text('Bağlantı Talebi Gönder'),
                    );
                  }),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    Get.snackbar(
                      'Profil',
                      '${user.fullName} profili açılacak',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  child: Text('Profili Gör'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
