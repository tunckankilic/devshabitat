import 'package:flutter/material.dart';

class LocationFilterWidget extends StatelessWidget {
  final double radius;
  final Function(double) onRadiusChanged;
  final List<String> selectedCategories;
  final Function(List<String>) onCategoriesChanged;
  final bool showOnlineOnly;
  final Function(bool) onOnlineStatusChanged;

  const LocationFilterWidget({
    Key? key,
    required this.radius,
    required this.onRadiusChanged,
    required this.selectedCategories,
    required this.onCategoriesChanged,
    required this.showOnlineOnly,
    required this.onOnlineStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mesafe Filtresi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Slider(
            value: radius,
            min: 1,
            max: 50,
            divisions: 49,
            label: '${radius.round()} km',
            onChanged: onRadiusChanged,
          ),
          const SizedBox(height: 16),
          const Text(
            'Kategoriler',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              'Frontend',
              'Backend',
              'Mobile',
              'DevOps',
              'UI/UX',
              'Data Science',
            ].map((category) {
              final isSelected = selectedCategories.contains(category);
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  final newCategories = List<String>.from(selectedCategories);
                  if (selected) {
                    newCategories.add(category);
                  } else {
                    newCategories.remove(category);
                  }
                  onCategoriesChanged(newCategories);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Sadece Çevrimiçi'),
            value: showOnlineOnly,
            onChanged: onOnlineStatusChanged,
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
