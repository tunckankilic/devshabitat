import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/controllers/video/call_history_controller.dart';
import 'package:devshabitat/app/models/video/call_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class CallHistoryView extends GetView<CallHistoryController> {
  const CallHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Görüşme Geçmişi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => controller.showFilterOptions(),
          ),
        ],
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : controller.calls.isEmpty
                ? _buildEmptyState()
                : _buildCallList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.call_end,
            size: 64,
            color: Get.theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz görüşme geçmişiniz yok',
            style: Get.textTheme.titleMedium?.copyWith(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: controller.calls.length,
      itemBuilder: (context, index) {
        final call = controller.calls[index];
        return _CallHistoryTile(call: call);
      },
    );
  }
}

class _CallHistoryTile extends StatelessWidget {
  final CallModel call;

  const _CallHistoryTile({required this.call});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(call.participants.first.profileImage),
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      ),
      title: Text(
        call.isGroupCall
            ? '${call.participants.length} Kişilik Grup Görüşmesi'
            : call.participants.first.name,
      ),
      subtitle: Row(
        children: [
          Icon(
            call.callType == CallType.video ? Icons.videocam : Icons.call,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 4),
          Text(timeago.format(call.startTime, locale: 'tr')),
          const SizedBox(width: 8),
          Text('• ${_formatDuration(call.duration)}'),
        ],
      ),
      trailing: Icon(
        _getCallStatusIcon(call.status),
        color: _getCallStatusColor(call.status, context),
      ),
      onTap: () => Get.find<CallHistoryController>().showCallDetails(call),
    );
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

  IconData _getCallStatusIcon(CallStatus status) {
    switch (status) {
      case CallStatus.completed:
        return Icons.call_made;
      case CallStatus.missed:
        return Icons.call_missed;
      case CallStatus.rejected:
        return Icons.call_end;
      case CallStatus.failed:
        return Icons.error_outline;
    }
  }

  Color _getCallStatusColor(CallStatus status, BuildContext context) {
    switch (status) {
      case CallStatus.completed:
        return Colors.green;
      case CallStatus.missed:
        return Colors.red;
      case CallStatus.rejected:
        return Colors.orange;
      case CallStatus.failed:
        return Theme.of(context).colorScheme.error;
    }
  }
}
