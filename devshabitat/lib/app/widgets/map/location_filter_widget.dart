import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:devshabitat/app/controllers/responsive_controller.dart';

class LocationFilterWidget extends StatelessWidget {
  final double radius;
  final Function(double) onRadiusChanged;
  final List<String> selectedCategories;
  final Function(List<String>) onCategoriesChanged;
  final bool showOnlineOnly;
  final Function(bool) onOnlineStatusChanged;

  const LocationFilterWidget({
    super.key,
    required this.radius,
    required this.onRadiusChanged,
    required this.selectedCategories,
    required this.onCategoriesChanged,
    required this.showOnlineOnly,
    required this.onOnlineStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveController.to;
    return Container(
      padding: responsive.responsivePadding(all: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(responsive.responsiveValue(
          mobile: 12,
          tablet: 16,
          desktop: 20,
        )),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: responsive.responsiveValue(
              mobile: 8,
              tablet: 12,
              desktop: 16,
            ),
            offset: Offset(
                0,
                responsive.responsiveValue(
                  mobile: 2,
                  tablet: 3,
                  desktop: 4,
                )),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.distanceFilter,
            style: TextStyle(
              fontSize: responsive.responsiveValue(
                mobile: 16,
                tablet: 18,
                desktop: 20,
              ),
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
          SizedBox(height: responsive.responsivePadding(vertical: 16).top),
          Text(
            AppStrings.categories,
            style: TextStyle(
              fontSize: responsive.responsiveValue(
                mobile: 16,
                tablet: 18,
                desktop: 20,
              ),
              fontWeight: FontWeight.bold,
            ),
          ),
          Wrap(
            spacing: responsive.responsiveValue(
              mobile: 8,
              tablet: 12,
              desktop: 16,
            ),
            runSpacing: responsive.responsiveValue(
              mobile: 8,
              tablet: 12,
              desktop: 16,
            ),
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
                label: Text(
                  category,
                  style: TextStyle(
                    fontSize: responsive.responsiveValue(
                      mobile: 14,
                      tablet: 16,
                      desktop: 18,
                    ),
                  ),
                ),
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
                padding:
                    responsive.responsivePadding(horizontal: 12, vertical: 8),
              );
            }).toList(),
          ),
          SizedBox(height: responsive.responsivePadding(vertical: 16).top),
          SwitchListTile(
            title: Text(
              AppStrings.onlineOnly,
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
              ),
            ),
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
