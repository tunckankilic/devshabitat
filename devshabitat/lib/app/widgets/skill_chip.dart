import 'package:flutter/material.dart';

class SkillChip extends StatelessWidget {
  final String label;
  final bool isMatching;
  final VoidCallback? onDeleted;

  const SkillChip({
    super.key,
    required this.label,
    this.isMatching = false,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color:
              isMatching ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
        ),
      ),
      backgroundColor:
          isMatching ? colorScheme.primary : colorScheme.surfaceContainerHighest,
      deleteIcon: onDeleted != null
          ? Icon(
              Icons.close,
              size: 18,
              color: isMatching
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            )
          : null,
      onDeleted: onDeleted,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isMatching
            ? BorderSide.none
            : BorderSide(
                color: colorScheme.outline,
                width: 1,
              ),
      ),
    );
  }
}
