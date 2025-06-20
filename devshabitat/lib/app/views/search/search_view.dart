import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/message_search_controller.dart';
import '../../models/message_model.dart';

class SearchView extends GetView<MessageSearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arama'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => _showSearchAnalytics(context),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildSearchSuggestions(),
          _buildRecentSearches(),
          _buildCategoryTabs(),
          _buildSearchResults(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Mesajlarda ara...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: controller.clearSearch,
                )
              : const SizedBox()),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return Obx(() {
      if (!controller.showSuggestions.value ||
          controller.searchSuggestions.isEmpty) {
        return const SizedBox();
      }

      return Container(
        color: Colors.white,
        child: Column(
          children: [
            const Divider(height: 1),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.searchSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = controller.searchSuggestions[index];
                return ListTile(
                  leading: const Icon(Icons.search),
                  title: Text(suggestion),
                  onTap: () {
                    controller.searchController.text = suggestion;
                    controller.performSearch(suggestion);
                  },
                );
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRecentSearches() {
    return Obx(() {
      if (controller.recentSearches.isEmpty || controller.hasSearched.value) {
        return const SizedBox();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Son Aramalar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: controller.clearRecentSearches,
                  child: const Text('Temizle'),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.recentSearches.length,
            itemBuilder: (context, index) {
              final search = controller.recentSearches[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(search),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => controller.removeRecentSearch(search),
                ),
                onTap: () => controller.performSearch(search),
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildCategoryTabs() {
    return Obx(() {
      if (!controller.hasSearched.value) return const SizedBox();

      return Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: SearchCategory.values.map((category) {
                final isSelected =
                    controller.selectedCategory.value == category.toString();
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(_getCategoryLabel(category)),
                    selected: isSelected,
                    onSelected: (_) =>
                        controller.setSelectedCategory(category.toString()),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(),
        ],
      );
    });
  }

  String _getCategoryLabel(SearchCategory category) {
    switch (category) {
      case SearchCategory.all:
        return 'Tümü';
      case SearchCategory.messages:
        return 'Mesajlar';
      case SearchCategory.media:
        return 'Medya';
      case SearchCategory.documents:
        return 'Dokümanlar';
      case SearchCategory.links:
        return 'Linkler';
    }
  }

  Widget _buildSearchResults() {
    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!controller.hasSearched.value) {
          return const Center(
            child: Text('Arama yapmak için yukarıdaki alanı kullanın'),
          );
        }

        if (controller.searchResults.isEmpty) {
          return const Center(
            child: Text('Sonuç bulunamadı'),
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                scrollInfo.metrics.maxScrollExtent) {
              controller.loadMore();
            }
            return true;
          },
          child: ListView.builder(
            itemCount: controller.searchResults.length + 1,
            itemBuilder: (context, index) {
              if (index == controller.searchResults.length) {
                return Obx(() {
                  if (controller.hasMore.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return const SizedBox();
                });
              }

              final message = controller.searchResults[index];
              return _buildMessageCard(message);
            },
          ),
        );
      }),
    );
  }

  Widget _buildMessageCard(MessageModel message) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          ListTile(
            title: Text(
              message.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              'Gönderen: ${message.senderName}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Text(
              _formatDate(message.timestamp),
              style: const TextStyle(fontSize: 12),
            ),
            onTap: () => controller.navigateToMessage(message),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.share, size: 18),
                label: const Text('Paylaş'),
                onPressed: () => controller.shareSearchResults([message]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showSearchAnalytics(BuildContext context) {
    final analytics = controller.getSearchAnalytics();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Arama İstatistikleri'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Toplam Arama: ${analytics['totalSearches']}'),
            const SizedBox(height: 16),
            const Text(
              'En Çok Aranan:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${analytics['mostSearched'].term} (${analytics['mostSearched'].count} kez)',
            ),
            const SizedBox(height: 16),
            const Text(
              'Son Aramalar:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...analytics['recentSearches'].map<Widget>((stat) => Text(
                  '${stat.term} - ${_formatDate(stat.lastSearched)}',
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtreler'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterSwitch(
              'Metin Mesajları',
              controller.filterText,
              controller.toggleTextFilter,
            ),
            _buildFilterSwitch(
              'Medya',
              controller.filterMedia,
              controller.toggleMediaFilter,
            ),
            _buildFilterSwitch(
              'Dokümanlar',
              controller.filterDocuments,
              controller.toggleDocumentsFilter,
            ),
            _buildFilterSwitch(
              'Linkler',
              controller.filterLinks,
              controller.toggleLinksFilter,
            ),
            const Divider(),
            ListTile(
              title: const Text('Sıralama'),
              trailing: Obx(
                () => IconButton(
                  icon: Icon(
                    controller.sortOrder.value == SortOrder.ascending
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                  ),
                  onPressed: controller.toggleSortOrder,
                ),
              ),
            ),
            _buildFilterSwitch(
              'Öncelikli Mesajlar',
              controller.showPriority,
              (value) {
                controller.showPriority.value = value;
                if (value) {
                  _showPrioritySlider(context);
                }
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Tarih Aralığı'),
              subtitle: Obx(() {
                final start = controller.startDate.value;
                final end = controller.endDate.value;
                if (start == null || end == null) {
                  return const Text('Seçilmedi');
                }
                return Text('$start - $end');
              }),
              trailing: const Icon(Icons.date_range),
              onTap: () async {
                await controller.selectStartDate();
                await controller.selectEndDate();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.applyFilters();
              Get.back();
            },
            child: const Text('Uygula'),
          ),
        ],
      ),
    );
  }

  void _showPrioritySlider(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Minimum Öncelik'),
        content: Obx(
          () => Slider(
            value: controller.minPriority.value.toDouble(),
            min: 0,
            max: 5,
            divisions: 5,
            label: controller.minPriority.value.toString(),
            onChanged: (value) => controller.setMinPriority(value.toInt()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSwitch(
    String title,
    RxBool value,
    void Function(bool) onChanged,
  ) {
    return Obx(
      () => SwitchListTile(
        title: Text(title),
        value: value.value,
        onChanged: onChanged,
      ),
    );
  }
}
