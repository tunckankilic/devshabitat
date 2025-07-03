import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devshabitat/app/models/video/call_model.dart';

class CallHistoryController extends GetxController {
  final _calls = <CallModel>[].obs;
  final _isLoading = true.obs;
  final _selectedFilter = CallStatus.completed.obs;

  List<CallModel> get calls => _calls;
  bool get isLoading => _isLoading.value;
  CallStatus get selectedFilter => _selectedFilter.value;

  StreamSubscription<QuerySnapshot>? _callsSubscription;

  @override
  void onInit() {
    super.onInit();
    _loadCallHistory();
  }

  @override
  void onClose() {
    _callsSubscription?.cancel();
    super.onClose();
  }

  void _loadCallHistory() {
    final userId = Get.find<String>(tag: 'userId');

    _callsSubscription = FirebaseFirestore.instance
        .collection('calls')
        .where('participants', arrayContains: userId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        _isLoading.value = false;
        _calls.value = snapshot.docs
            .map((doc) => CallModel.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .where((call) =>
                _selectedFilter.value == CallStatus.completed ||
                call.status == _selectedFilter.value)
            .toList();
      },
      onError: (error) {
        print('Call history load error: $error');
        _isLoading.value = false;
      },
    );
  }

  void showFilterOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Görüşme Durumu',
                    style: Get.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            const Divider(),
            _buildFilterOption(
              title: 'Tüm Görüşmeler',
              value: CallStatus.completed,
              icon: Icons.call,
            ),
            _buildFilterOption(
              title: 'Cevapsız Aramalar',
              value: CallStatus.missed,
              icon: Icons.call_missed,
            ),
            _buildFilterOption(
              title: 'Reddedilen Aramalar',
              value: CallStatus.rejected,
              icon: Icons.call_end,
            ),
            _buildFilterOption(
              title: 'Başarısız Aramalar',
              value: CallStatus.failed,
              icon: Icons.error_outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption({
    required String title,
    required CallStatus value,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Obx(() => Radio<CallStatus>(
            value: value,
            groupValue: _selectedFilter.value,
            onChanged: (newValue) {
              if (newValue != null) {
                _selectedFilter.value = newValue;
                _loadCallHistory();
                Get.back();
              }
            },
          )),
      onTap: () {
        _selectedFilter.value = value;
        _loadCallHistory();
        Get.back();
      },
    );
  }

  void showCallDetails(CallModel call) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Görüşme Detayları',
              style: Get.textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Durum', _getStatusText(call.status)),
            _buildDetailRow('Süre', _formatDuration(call.duration)),
            _buildDetailRow('Tarih', _formatDateTime(call.startTime)),
            _buildDetailRow(
              'Katılımcılar',
              call.participants.map((p) => p.name).join(', '),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.call),
                label: const Text('Yeniden Ara'),
                onPressed: () => _initiateNewCall(call),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Get.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(CallStatus status) {
    switch (status) {
      case CallStatus.completed:
        return 'Tamamlandı';
      case CallStatus.missed:
        return 'Cevapsız';
      case CallStatus.rejected:
        return 'Reddedildi';
      case CallStatus.failed:
        return 'Başarısız';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}s ${duration.inMinutes.remainder(60)}d';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}d ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _initiateNewCall(CallModel previousCall) async {
    try {
      final newCall = CallModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        roomId: 'room_${DateTime.now().millisecondsSinceEpoch}',
        callType: previousCall.callType,
        status: CallStatus.completed,
        startTime: DateTime.now(),
        duration: const Duration(),
        participants: previousCall.participants,
        isGroupCall: previousCall.isGroupCall,
      );

      // Yeni görüşme başlat
      await FirebaseFirestore.instance
          .collection('calls')
          .doc(newCall.id)
          .set(newCall.toJson());

      Get.back(); // Detay sayfasını kapat
      Get.toNamed('/video-call', arguments: newCall);
    } catch (e) {
      print('New call initiation error: $e');
      Get.snackbar(
        'Hata',
        'Görüşme başlatılamadı',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
