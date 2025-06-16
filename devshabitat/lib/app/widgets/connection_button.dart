import 'package:flutter/material.dart';
import '../controllers/user_profile_controller.dart';

class ConnectionButton extends StatelessWidget {
  final ConnectionStatus status;
  final VoidCallback onConnect;
  final VoidCallback onMessage;

  const ConnectionButton({
    Key? key,
    required this.status,
    required this.onConnect,
    required this.onMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ConnectionStatus.none:
        return FloatingActionButton.extended(
          onPressed: () => _showConnectionDialog(context),
          icon: const Icon(Icons.person_add),
          label: const Text('Bağlantı Kur'),
        );

      case ConnectionStatus.pending:
        return FloatingActionButton.extended(
          onPressed: null,
          icon: const Icon(Icons.hourglass_empty),
          label: const Text('İstek Gönderildi'),
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        );

      case ConnectionStatus.connected:
        return FloatingActionButton.extended(
          onPressed: onMessage,
          icon: const Icon(Icons.message),
          label: const Text('Mesaj Gönder'),
        );
    }
  }

  Future<void> _showConnectionDialog(BuildContext context) async {
    final messageController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bağlantı İsteği'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Bu kullanıcıya bir bağlantı isteği göndermek istiyor musunuz?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Tanıtım mesajı (opsiyonel)',
                hintText: 'Kendinizi kısaca tanıtın...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              onConnect();
              Navigator.of(context).pop();
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }
}
