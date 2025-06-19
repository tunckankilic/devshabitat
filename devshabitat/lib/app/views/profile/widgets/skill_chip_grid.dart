import 'package:flutter/material.dart';
import '../../../models/skill_model.dart';

class SkillChipGrid extends StatelessWidget {
  final List<SkillModel> skills;
  final bool isVertical;

  const SkillChipGrid({
    super.key,
    required this.skills,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    return isVertical
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: skills.map((skill) => _buildSkillChip(skill)).toList(),
          )
        : Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((skill) => _buildSkillChip(skill)).toList(),
          );
  }

  Widget _buildSkillChip(SkillModel skill) {
    return Chip(
      avatar: skill.iconUrl != null
          ? CircleAvatar(
              backgroundImage: NetworkImage(skill.iconUrl!),
              radius: 12,
            )
          : null,
      label: Text(skill.name),
      backgroundColor: _getCategoryColor(skill.category),
      labelStyle: const TextStyle(color: Colors.white),
    );
  }

  Color _getCategoryColor(SkillCategory category) {
    switch (category) {
      case SkillCategory.programming:
        return Colors.blue;
      case SkillCategory.framework:
        return Colors.green;
      case SkillCategory.database:
        return Colors.orange;
      case SkillCategory.cloud:
        return Colors.purple;
      case SkillCategory.devops:
        return Colors.red;
      case SkillCategory.design:
        return Colors.pink;
      case SkillCategory.other:
        return Colors.grey;
    }
  }
}
