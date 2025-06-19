import 'package:flutter/material.dart';

class EmojiPickerWidget extends StatelessWidget {
  final Function(String) onEmojiSelected;
  final bool isVisible;

  static const List<String> defaultEmojis = [
    '👍',
    '👎',
    '❤️',
    '😂',
    '😮',
    '😢'
  ];

  const EmojiPickerWidget({
    super.key,
    required this.onEmojiSelected,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: isVisible ? 48 : 0,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: defaultEmojis.map((emoji) {
              return _EmojiButton(
                emoji: emoji,
                onTap: () => onEmojiSelected(emoji),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _EmojiButton extends StatelessWidget {
  final String emoji;
  final VoidCallback onTap;

  const _EmojiButton({
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }
}
