import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/responsive_controller.dart';

class AdvancedSearchFilters extends StatelessWidget {
  final List<String> selectedSkills;
  final int maxDistance;
  final bool showOnlineOnly;
  final List<String> availableSkills;
  final Function(List<String>) onSkillsChanged;
  final Function(int) onDistanceChanged;
  final Function(bool) onOnlineOnlyChanged;

  const AdvancedSearchFilters({
    super.key,
    required this.selectedSkills,
    required this.maxDistance,
    required this.showOnlineOnly,
    required this.availableSkills,
    required this.onSkillsChanged,
    required this.onDistanceChanged,
    required this.onOnlineOnlyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(
        responsive.responsiveValue(mobile: 16, tablet: 24),
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(
          responsive.responsiveValue(mobile: 12, tablet: 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Filters',
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 18, tablet: 22),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSkillsFilter(responsive),
          const SizedBox(height: 24),
          _buildDistanceFilter(responsive),
          const SizedBox(height: 24),
          _buildOnlineFilter(responsive),
        ],
      ),
    );
  }

  Widget _buildSkillsFilter(ResponsiveController responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills',
          style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 16, tablet: 18),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableSkills.map((skill) {
            final isSelected = selectedSkills.contains(skill);
            return FilterChip(
              label: Text(
                skill,
                style: TextStyle(
                  fontSize: responsive.responsiveValue(mobile: 14, tablet: 16),
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                final newSkills = List<String>.from(selectedSkills);
                if (selected) {
                  newSkills.add(skill);
                } else {
                  newSkills.remove(skill);
                }
                onSkillsChanged(newSkills);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDistanceFilter(ResponsiveController responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Maximum Distance',
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 16, tablet: 18),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$maxDistance km',
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 14, tablet: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius:
                  responsive.responsiveValue(mobile: 8, tablet: 10),
            ),
          ),
          child: Slider(
            value: maxDistance.toDouble(),
            min: 1,
            max: 100,
            divisions: 99,
            label: '$maxDistance km',
            onChanged: (value) => onDistanceChanged(value.round()),
          ),
        ),
      ],
    );
  }

  Widget _buildOnlineFilter(ResponsiveController responsive) {
    return SwitchListTile(
      title: Text(
        'Show Online Only',
        style: TextStyle(
          fontSize: responsive.responsiveValue(mobile: 16, tablet: 18),
          fontWeight: FontWeight.w500,
        ),
      ),
      value: showOnlineOnly,
      onChanged: onOnlineOnlyChanged,
    );
  }
}
