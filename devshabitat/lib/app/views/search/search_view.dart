import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/message_search_controller.dart';
import '../../models/message_model.dart';
import '../../controllers/responsive_controller.dart';
import '../../services/responsive_performance_service.dart';
import '../../widgets/responsive/responsive_text.dart';
import '../../widgets/responsive/animated_responsive_wrapper.dart';

class SearchView extends GetView<MessageSearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText(
          'Arama',
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 18,
              tablet: 22,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.analytics_outlined,
              size: responsive.responsiveValue(
                mobile: 24,
                tablet: 28,
              ),
            ),
            onPressed: () => _showSearchAnalytics(context),
          ),
          IconButton(
            icon: Icon(
              Icons.filter_list,
              size: responsive.responsiveValue(
                mobile: 24,
                tablet: 28,
              ),
            ),
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
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Padding(
      padding: performanceService.getOptimizedPadding(
        cacheKey: 'search_bar_padding',
        all: 16,
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        style: TextStyle(
          fontSize: responsive.responsiveValue(
            mobile: 16,
            tablet: 18,
          ),
        ),
        decoration: InputDecoration(
          hintText: 'Mesajlarda ara...',
          hintStyle: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 16,
              tablet: 18,
            ),
          ),
          prefixIcon: Icon(
            Icons.search,
            size: responsive.responsiveValue(
              mobile: 24,
              tablet: 28,
            ),
          ),
          suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: responsive.responsiveValue(
                      mobile: 24,
                      tablet: 28,
                    ),
                  ),
                  onPressed: controller.clearSearch,
                )
              : const SizedBox()),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              responsive.responsiveValue(
                mobile: 12,
                tablet: 16,
              ),
            ),
          ),
          contentPadding: performanceService.getOptimizedPadding(
            cacheKey: 'search_field_padding',
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    final responsive = Get.find<ResponsiveController>();

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
                  leading: Icon(
                    Icons.search,
                    size: responsive.responsiveValue(
                      mobile: 20,
                      tablet: 24,
                    ),
                  ),
                  title: ResponsiveText(
                    suggestion,
                    style: TextStyle(
                      fontSize: responsive.responsiveValue(
                        mobile: 14,
                        tablet: 16,
                      ),
                    ),
                  ),
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
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Obx(() {
      if (controller.recentSearches.isEmpty || controller.hasSearched.value) {
        return const SizedBox();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: performanceService.getOptimizedPadding(
              cacheKey: 'recent_searches_header_padding',
              horizontal: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ResponsiveText(
                  'Son Aramalar',
                  style: TextStyle(
                    fontSize: responsive.responsiveValue(
                      mobile: 16,
                      tablet: 18,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: controller.clearRecentSearches,
                  child: ResponsiveText(
                    'Temizle',
                    style: TextStyle(
                      fontSize: responsive.responsiveValue(
                        mobile: 14,
                        tablet: 16,
                      ),
                    ),
                  ),
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
                leading: Icon(
                  Icons.history,
                  size: responsive.responsiveValue(
                    mobile: 20,
                    tablet: 24,
                  ),
                ),
                title: ResponsiveText(
                  search,
                  style: TextStyle(
                    fontSize: responsive.responsiveValue(
                      mobile: 14,
                      tablet: 16,
                    ),
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.close,
                    size: responsive.responsiveValue(
                      mobile: 20,
                      tablet: 24,
                    ),
                  ),
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
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Obx(() {
      if (!controller.hasSearched.value) return const SizedBox();

      return Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: performanceService.getOptimizedPadding(
              cacheKey: 'category_tabs_padding',
              horizontal: 16,
            ),
            child: Row(
              children: SearchCategory.values.map((category) {
                final isSelected =
                    controller.selectedCategory.value == category.toString();
                return Padding(
                  padding: EdgeInsets.only(
                    right: responsive.responsiveValue(
                      mobile: 8,
                      tablet: 12,
                    ),
                  ),
                  child: FilterChip(
                    label: ResponsiveText(
                      _getCategoryLabel(category),
                      style: TextStyle(
                        fontSize: responsive.responsiveValue(
                          mobile: 12,
                          tablet: 14,
                        ),
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) =>
                        controller.setSelectedCategory(category.toString()),
                    padding: performanceService.getOptimizedPadding(
                      cacheKey: 'filter_chip_padding',
                      horizontal: 12,
                      vertical: 8,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: responsive.responsiveValue(
                mobile: 2.0,
                tablet: 3.0,
              ),
            ),
          );
        }

        if (!controller.hasSearched.value) {
          return Center(
            child: ResponsiveText(
              'Arama yapmak için yukarıdaki alanı kullanın',
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 16,
                  tablet: 18,
                ),
              ),
            ),
          );
        }

        if (controller.searchResults.isEmpty) {
          return Center(
            child: ResponsiveText(
              'Sonuç bulunamadı',
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 16,
                  tablet: 18,
                ),
              ),
            ),
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
                    return Center(
                      child: Padding(
                        padding: performanceService.getOptimizedPadding(
                          cacheKey: 'load_more_padding',
                          all: 8,
                        ),
                        child: CircularProgressIndicator(
                          strokeWidth: responsive.responsiveValue(
                            mobile: 2.0,
                            tablet: 3.0,
                          ),
                        ),
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
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Card(
      margin: performanceService.getOptimizedPadding(
        cacheKey: 'message_card_margin',
        horizontal: 16,
        vertical: 8,
      ),
      child: Column(
        children: [
          ListTile(
            title: ResponsiveText(
              message.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 14,
                  tablet: 16,
                ),
              ),
            ),
            subtitle: ResponsiveText(
              'Gönderen: ${message.senderName}',
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 12,
                  tablet: 14,
                ),
              ),
            ),
            trailing: ResponsiveText(
              _formatDate(message.timestamp),
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 12,
                  tablet: 14,
                ),
              ),
            ),
            onTap: () => controller.navigateToMessage(message),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: Icon(
                  Icons.share,
                  size: responsive.responsiveValue(
                    mobile: 18,
                    tablet: 20,
                  ),
                ),
                label: ResponsiveText(
                  'Paylaş',
                  style: TextStyle(
                    fontSize: responsive.responsiveValue(
                      mobile: 14,
                      tablet: 16,
                    ),
                  ),
                ),
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
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();
    final analytics = controller.getSearchAnalytics();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ResponsiveText(
          'Arama İstatistikleri',
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 18,
              tablet: 22,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveText(
              'Toplam Arama: ${analytics['totalSearches']}',
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 14,
                  tablet: 16,
                ),
              ),
            ),
            SizedBox(
              height: responsive.responsiveValue(
                mobile: 16,
                tablet: 20,
              ),
            ),
            ResponsiveText(
              'En Çok Aranan:',
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 14,
                  tablet: 16,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
            ResponsiveText(
              '${analytics['mostSearched'].term} (${analytics['mostSearched'].count} kez)',
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 14,
                  tablet: 16,
                ),
              ),
            ),
            SizedBox(
              height: responsive.responsiveValue(
                mobile: 16,
                tablet: 20,
              ),
            ),
            ResponsiveText(
              'Son Aramalar:',
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 14,
                  tablet: 16,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
            ...analytics['recentSearches'].map<Widget>((stat) => ResponsiveText(
                  '${stat.term} - ${_formatDate(stat.lastSearched)}',
                  style: TextStyle(
                    fontSize: responsive.responsiveValue(
                      mobile: 14,
                      tablet: 16,
                    ),
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: ResponsiveText(
              'Kapat',
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 16,
                  tablet: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ResponsiveText(
          'Filtreler',
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 18,
              tablet: 22,
            ),
          ),
        ),
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
              title: ResponsiveText(
                'Sıralama',
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 16,
                    tablet: 18,
                  ),
                ),
              ),
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
              title: ResponsiveText(
                'Tarih Aralığı',
                style: TextStyle(
                  fontSize: responsive.responsiveValue(
                    mobile: 16,
                    tablet: 18,
                  ),
                ),
              ),
              subtitle: Obx(() {
                final start = controller.startDate.value;
                final end = controller.endDate.value;
                if (start == null || end == null) {
                  return ResponsiveText(
                    'Seçilmedi',
                    style: TextStyle(
                      fontSize: responsive.responsiveValue(
                        mobile: 14,
                        tablet: 16,
                      ),
                    ),
                  );
                }
                return ResponsiveText(
                  '$start - $end',
                  style: TextStyle(
                    fontSize: responsive.responsiveValue(
                      mobile: 14,
                      tablet: 16,
                    ),
                  ),
                );
              }),
              trailing: Icon(
                Icons.date_range,
                size: responsive.responsiveValue(
                  mobile: 24,
                  tablet: 28,
                ),
              ),
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
            child: ResponsiveText(
              'İptal',
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 16,
                  tablet: 18,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.applyFilters();
              Get.back();
            },
            child: ResponsiveText(
              'Uygula',
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 16,
                  tablet: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrioritySlider(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ResponsiveText(
          'Minimum Öncelik',
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 18,
              tablet: 22,
            ),
          ),
        ),
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
            child: ResponsiveText(
              'Tamam',
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 16,
                  tablet: 18,
                ),
              ),
            ),
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
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Obx(
      () => SwitchListTile(
        title: ResponsiveText(
          title,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 14,
              tablet: 16,
            ),
          ),
        ),
        value: value.value,
        onChanged: onChanged,
      ),
    );
  }
}
