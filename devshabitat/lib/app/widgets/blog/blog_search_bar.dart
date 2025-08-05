import 'package:flutter/material.dart';

class BlogSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final List<String> categories;
  final String? selectedCategory;
  final Function(String?) onCategoryChanged;
  final bool isLoading;

  const BlogSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search TextField
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Blog yazılarında ara...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        onSearch('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue),
              ),
            ),
            onChanged: onSearch,
          ),
          const SizedBox(height: 12),

          // Category Filter
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FilterChip(
                  label: const Text('Tümü'),
                  selected: selectedCategory == null,
                  onSelected: (selected) {
                    if (selected) {
                      onCategoryChanged(null);
                    }
                  },
                ),
                const SizedBox(width: 8),
                ...categories.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: category == selectedCategory,
                      onSelected: (selected) {
                        onCategoryChanged(selected ? category : null);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
