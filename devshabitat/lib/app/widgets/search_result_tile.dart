import 'package:flutter/material.dart';
import 'package:devshabitat/app/models/message_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class SearchResultTile extends StatelessWidget {
  final MessageModel searchResult;
  final VoidCallback onTap;
  final String highlightText;

  const SearchResultTile({
    super.key,
    required this.searchResult,
    required this.onTap,
    required this.highlightText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    child: Text(searchResult.senderName[0].toUpperCase()),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          searchResult.senderName,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          timeago.format(searchResult.timestamp, locale: 'tr'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  _buildMessageTypeIcon(),
                ],
              ),
              const SizedBox(height: 8),
              _buildHighlightedText(context),
              if (searchResult.attachments.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildAttachmentPreview(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageTypeIcon() {
    IconData icon;
    Color? color;

    switch (searchResult.type) {
      case MessageType.text:
        icon = Icons.chat_bubble_outline;
        break;
      case MessageType.image:
        icon = Icons.image_outlined;
        color = Colors.blue;
        break;
      case MessageType.document:
        icon = Icons.description_outlined;
        color = Colors.orange;
        break;
      case MessageType.link:
        icon = Icons.link;
        color = Colors.green;
        break;
      default:
        icon = Icons.chat_bubble_outline;
    }

    return Icon(icon, size: 20, color: color);
  }

  Widget _buildHighlightedText(BuildContext context) {
    if (searchResult.content.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<TextSpan> spans = [];
    final String content = searchResult.content.toLowerCase();
    final String searchText = highlightText.toLowerCase();
    int currentIndex = 0;

    while (true) {
      final int matchIndex = content.indexOf(searchText, currentIndex);
      if (matchIndex == -1) {
        // Add remaining text
        if (currentIndex < searchResult.content.length) {
          spans.add(TextSpan(
            text: searchResult.content.substring(currentIndex),
          ));
        }
        break;
      }

      // Add text before match
      if (matchIndex > currentIndex) {
        spans.add(TextSpan(
          text: searchResult.content.substring(currentIndex, matchIndex),
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: searchResult.content
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
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildAttachmentPreview(BuildContext context) {
    final attachment = searchResult.attachments.first;

    switch (searchResult.type) {
      case MessageType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            attachment.url,
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      case MessageType.document:
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
      default:
        return const SizedBox.shrink();
    }
  }
}
