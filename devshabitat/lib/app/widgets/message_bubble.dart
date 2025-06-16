import 'package:flutter/material.dart';
import 'package:devshabitat/app/models/message_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageBubble extends StatelessWidget {
  final Message message;
  final String? highlightText;
  final VoidCallback? onMediaLoaded;
  final bool? isOwnMessage;

  const MessageBubble({
    Key? key,
    required this.message,
    this.highlightText,
    this.onMediaLoaded,
    this.isOwnMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 4),
          _buildContent(context),
          if (message.attachments.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildAttachments(context),
          ],
          const SizedBox(height: 4),
          _buildTimestamp(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          child: Text(message.senderName[0].toUpperCase()),
        ),
        const SizedBox(width: 8),
        Text(
          message.senderName,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (message.content.isEmpty) {
      return const SizedBox.shrink();
    }

    if (highlightText != null && highlightText!.isNotEmpty) {
      return _buildHighlightedText(context);
    }

    return Text(
      message.content,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  Widget _buildHighlightedText(BuildContext context) {
    final List<TextSpan> spans = [];
    final String content = message.content.toLowerCase();
    final String searchText = highlightText!.toLowerCase();
    int currentIndex = 0;

    while (true) {
      final int matchIndex = content.indexOf(searchText, currentIndex);
      if (matchIndex == -1) {
        if (currentIndex < message.content.length) {
          spans.add(TextSpan(
            text: message.content.substring(currentIndex),
          ));
        }
        break;
      }

      if (matchIndex > currentIndex) {
        spans.add(TextSpan(
          text: message.content.substring(currentIndex, matchIndex),
        ));
      }

      spans.add(TextSpan(
        text: message.content
            .substring(matchIndex, matchIndex + searchText.length),
        style: TextStyle(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.2),
          fontWeight: FontWeight.bold,
        ),
      ));

      currentIndex = matchIndex + searchText.length;
    }

    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: spans,
      ),
    );
  }

  Widget _buildAttachments(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: message.attachments.length,
      itemBuilder: (context, index) {
        final attachment = message.attachments[index];

        switch (attachment.type) {
          case MessageType.image:
            return _buildImageAttachment(context, attachment);
          case MessageType.document:
            return _buildDocumentAttachment(context, attachment);
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildImageAttachment(
      BuildContext context, MessageAttachment attachment) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: attachment.url,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildDocumentAttachment(
      BuildContext context, MessageAttachment attachment) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  attachment.size,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        timeago.format(message.timestamp, locale: 'tr'),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
