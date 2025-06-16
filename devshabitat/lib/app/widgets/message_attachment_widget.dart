import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'image_viewer_widget.dart';

enum AttachmentType {
  image,
  file,
  voice,
}

class MessageAttachment {
  final String url;
  final String? name;
  final AttachmentType type;
  final int? size;
  final double? progress;

  const MessageAttachment({
    required this.url,
    this.name,
    required this.type,
    this.size,
    this.progress,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'name': name,
      'type': type.toString().split('.').last,
      'size': size,
      'progress': progress,
    };
  }

  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      url: json['url'] as String,
      name: json['name'] as String?,
      type: AttachmentType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      size: json['size'] as int?,
      progress: json['progress'] as double?,
    );
  }
}

class MessageAttachmentWidget extends StatelessWidget {
  final MessageAttachment attachment;
  final VoidCallback? onDownload;
  final VoidCallback? onTap;

  const MessageAttachmentWidget({
    Key? key,
    required this.attachment,
    this.onDownload,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _handleTap(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildAttachmentContent(context),
        ),
      ),
    );
  }

  Widget _buildAttachmentContent(BuildContext context) {
    switch (attachment.type) {
      case AttachmentType.image:
        return _buildImageAttachment(context);
      case AttachmentType.file:
        return _buildFileAttachment(context);
      case AttachmentType.voice:
        return _buildVoiceAttachment(context);
    }
  }

  Widget _buildImageAttachment(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: attachment.url,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Icon(Icons.error_outline),
            ),
          ),
        ),
        if (attachment.progress != null)
          LinearProgressIndicator(
            value: attachment.progress,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
      ],
    );
  }

  Widget _buildFileAttachment(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.insert_drive_file,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                attachment.name ?? 'File',
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (attachment.size != null)
                Text(
                  _formatFileSize(attachment.size!),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              if (attachment.progress != null)
                LinearProgressIndicator(
                  value: attachment.progress,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: onDownload,
        ),
      ],
    );
  }

  Widget _buildVoiceAttachment(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.mic,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Voice Message',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (attachment.progress != null)
                LinearProgressIndicator(
                  value: attachment.progress,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: onTap,
        ),
      ],
    );
  }

  void _handleTap(BuildContext context) {
    if (attachment.type == AttachmentType.image) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewerWidget(
            imageUrl: attachment.url,
          ),
        ),
      );
    } else if (onTap != null) {
      onTap!();
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
