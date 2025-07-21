import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import '../controllers/user_profile_controller.dart';

class ConnectionButton extends StatelessWidget {
  final ConnectionStatus status;
  final VoidCallback onConnect;
  final VoidCallback onMessage;

  const ConnectionButton({
    super.key,
    required this.status,
    required this.onConnect,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ConnectionStatus.none:
        return FloatingActionButton.extended(
          onPressed: () => _showConnectionDialog(context),
          icon: const Icon(Icons.person_add),
          label: const Text(AppStrings.connect),
        );

      case ConnectionStatus.pending:
        return FloatingActionButton.extended(
          onPressed: null,
          icon: const Icon(Icons.hourglass_empty),
          label: const Text(AppStrings.requestSent),
          backgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
          foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        );

      case ConnectionStatus.connected:
        return FloatingActionButton.extended(
          onPressed: onMessage,
          icon: const Icon(Icons.message),
          label: const Text(AppStrings.sendMessage),
        );
    }
  }

  Future<void> _showConnectionDialog(BuildContext context) async {
    final messageController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.connectinRequest),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              AppStrings.connectionRequest,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: AppStrings.introductionMessage,
                hintText: AppStrings.introductionHint,
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              onConnect();
              Navigator.of(context).pop();
            },
            child: const Text(AppStrings.send),
          ),
        ],
      ),
    );
  }
}
