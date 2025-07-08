// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/attachment_model.dart';
import 'image_viewer_widget.dart';

class MessageAttachmentWidget extends StatelessWidget {
  final MessageAttachment attachment;
  final VoidCallback? onDownload;
  final VoidCallback? onTap;

  const MessageAttachmentWidget({
    super.key,
    required this.attachment,
    this.onDownload,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withOpacity(0.5),
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
      case AttachmentType.video:
        return _buildVideoAttachment(context);
      case AttachmentType.document:
        return _buildDocumentAttachment(context);
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
            imageUrl: attachment.thumbnailUrl ?? attachment.url,
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
      ],
    );
  }

  Widget _buildVideoAttachment(BuildContext context) {
    return Row(
      children: [
        if (attachment.thumbnailUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: attachment.thumbnailUrl!,
              height: 80,
              width: 120,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            height: 80,
            width: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.play_circle_outline,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                attachment.fileName,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (attachment.size != null)
                Text(
                  _formatFileSize(attachment.size!),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentAttachment(BuildContext context) {
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
                attachment.fileName,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (attachment.size != null)
                Text(
                  _formatFileSize(attachment.size!),
                  style: Theme.of(context).textTheme.bodySmall,
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
