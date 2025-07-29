import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/location/location_controller.dart';

class LocationHistoryView extends GetView<LocationController> {
  const LocationHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    // Load location history when view builds
    controller.loadLocationHistory();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.locationHistory),
        actions: [
          IconButton(
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: Text('Geçmişi Temizle'),
                  content: Text(
                      'Tüm konum geçmişinizi silmek istediğinizden emin misiniz?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('İptal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.clearLocationHistory();
                      },
                      child: Text('Sil'),
                    ),
                  ],
                ),
              );
            },
            icon: Icon(Icons.delete_outline),
          ),
          IconButton(
            onPressed: controller.loadLocationHistory,
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Card
          Obx(() {
            final stats = controller.getLocationStatistics();
            return Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Konum İstatistikleri',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'Toplam',
                            '${stats['total_entries']}',
                            Icons.location_on,
                            Colors.blue,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Bu Ay',
                            '${stats['month_entries']}',
                            Icons.calendar_month,
                            Colors.green,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Check-in',
                            '${stats['check_ins']}',
                            Icons.place,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

          // Location History List
          Expanded(
            child: Obx(() {
              if (controller.isLoadingHistory.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text('Konum geçmişi yükleniyor...'),
                    ],
                  ),
                );
              }

              if (controller.historyError.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        controller.historyError.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.loadLocationHistory,
                        child: Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                );
              }

              if (controller.locationHistory.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_history,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz konum geçmişi bulunmuyor',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Konum takibi açık olduğunda geçmiş konumlarınız burada görünür',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.locationHistory.length,
                itemBuilder: (context, index) {
                  final location = controller.locationHistory[index];
                  return _buildLocationHistoryItem(location);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationHistoryItem(Map<String, dynamic> location) {
    final timestamp = location['timestamp'] as DateTime;
    final placeName = location['placeName'] as String;
    final address = location['address'] as String;
    final type = location['type'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(type).withOpacity(0.1),
          child: Icon(_getTypeIcon(type), color: _getTypeColor(type)),
        ),
        title: Text(
          placeName,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(address),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _formatTime(timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getTypeColor(type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getTypeText(type),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getTypeColor(type),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'navigate':
                controller.navigateToLocation(
                  location['latitude'],
                  location['longitude'],
                  placeName,
                );
                break;
              case 'delete':
                _showDeleteConfirmation(location['id'], placeName);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'navigate',
              child: Row(
                children: [
                  Icon(Icons.navigation, size: 16),
                  const SizedBox(width: 8),
                  Text('Haritada Göster'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  Text('Sil', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          _showLocationDetails(location);
        },
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'check-in':
        return Icons.place;
      case 'manual':
        return Icons.add_location;
      case 'automatic':
      default:
        return Icons.location_on;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'check-in':
        return Colors.green;
      case 'manual':
        return Colors.blue;
      case 'automatic':
      default:
        return Colors.grey;
    }
  }

  String _getTypeText(String type) {
    switch (type) {
      case 'check-in':
        return 'Check-in';
      case 'manual':
        return 'Manuel';
      case 'automatic':
      default:
        return 'Otomatik';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 7) {
      return '${time.day}/${time.month}/${time.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Şimdi';
    }
  }

  void _showDeleteConfirmation(String entryId, String placeName) {
    Get.dialog(
      AlertDialog(
        title: Text('Konum Girişini Sil'),
        content: Text(
            '$placeName konumunu geçmişten silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteLocationEntry(entryId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _showLocationDetails(Map<String, dynamic> location) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getTypeIcon(location['type']),
                    color: _getTypeColor(location['type'])),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    location['placeName'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Adres', location['address']),
            _buildDetailRow(
                'Konum', '${location['latitude']}, ${location['longitude']}'),
            _buildDetailRow('Zaman', _formatTime(location['timestamp'])),
            _buildDetailRow('Tip', _getTypeText(location['type'])),
            if (location['accuracy'] != null)
              _buildDetailRow('Doğruluk', '${location['accuracy']} m'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      controller.navigateToLocation(
                        location['latitude'],
                        location['longitude'],
                        location['placeName'],
                      );
                    },
                    icon: Icon(Icons.navigation),
                    label: Text('Haritada Göster'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Get.back();
                    _showDeleteConfirmation(
                        location['id'], location['placeName']);
                  },
                  icon: Icon(Icons.delete, color: Colors.red),
                  label: Text('Sil', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
