import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/message_search_controller.dart';
import '../../models/message_model.dart';
import '../../controllers/responsive_controller.dart';
import '../../services/responsive_performance_service.dart';
import '../../widgets/responsive/responsive_text.dart';

class SearchView extends GetView<MessageSearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText(
          AppStrings.search,
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

    final searchBarPadding = performanceService.getOptimizedPadding(
      cacheKey: 'search_bar_padding',
      horizontal: responsive.responsiveValue(mobile: 12.0, tablet: 16.0),
      vertical: responsive.responsiveValue(mobile: 8.0, tablet: 12.0),
    );

    final searchIconSize = responsive.responsiveValue(
      mobile: 24.0,
      tablet: 28.0,
    );

    final searchBarBorderRadius = responsive.responsiveValue(
      mobile: 12.0,
      tablet: 16.0,
    );

    return Padding(
      padding: searchBarPadding,
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        style: TextStyle(
          fontSize: responsive.responsiveValue(
            mobile: 16.0,
            tablet: 18.0,
          ),
        ),
        decoration: InputDecoration(
          hintText: AppStrings.searchMessages,
          hintStyle: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 16.0,
              tablet: 18.0,
            ),
          ),
          prefixIcon: Icon(
            Icons.search,
            size: searchIconSize,
          ),
          suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: searchIconSize,
                  ),
                  onPressed: controller.clearSearch,
                )
              : const SizedBox()),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(searchBarBorderRadius),
          ),
          contentPadding: performanceService.getOptimizedPadding(
            cacheKey: 'search_field_padding',
            horizontal: responsive.responsiveValue(mobile: 12.0, tablet: 16.0),
            vertical: responsive.responsiveValue(mobile: 8.0, tablet: 12.0),
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
                  AppStrings.recentSearches,
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
                    AppStrings.clear,
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

    final tabsPadding = performanceService.getOptimizedPadding(
      cacheKey: 'category_tabs_padding',
      horizontal: responsive.responsiveValue(mobile: 12.0, tablet: 16.0),
      vertical: responsive.responsiveValue(mobile: 4.0, tablet: 8.0),
    );

    final chipSpacing = responsive.responsiveValue(
      mobile: 8.0,
      tablet: 12.0,
    );

    return Obx(() {
      if (!controller.hasSearched.value) return const SizedBox();

      return Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: tabsPadding,
            child: Row(
              children: SearchCategory.values.map((category) {
                final isSelected =
                    controller.selectedCategory.value == category.toString();
                return Padding(
                  padding: EdgeInsets.only(right: chipSpacing),
                  child: FilterChip(
                    label: ResponsiveText(
                      _getCategoryLabel(category),
                      style: TextStyle(
                        fontSize: responsive.responsiveValue(
                          mobile: 12.0,
                          tablet: 14.0,
                        ),
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) =>
                        controller.setSelectedCategory(category.toString()),
                    padding: performanceService.getOptimizedPadding(
                      cacheKey: 'filter_chip_padding',
                      horizontal:
                          responsive.responsiveValue(mobile: 8.0, tablet: 12.0),
                      vertical:
                          responsive.responsiveValue(mobile: 6.0, tablet: 8.0),
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
        return AppStrings.all;
      case SearchCategory.messages:
        return AppStrings.messages;
      case SearchCategory.media:
        return AppStrings.media;
      case SearchCategory.documents:
        return AppStrings.documents;
      case SearchCategory.links:
        return AppStrings.links;
    }
  }

  Widget _buildSearchResults() {
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    final loadingIndicatorSize = responsive.responsiveValue(
      mobile: 24.0,
      tablet: 32.0,
    );

    final loadingStrokeWidth = responsive.responsiveValue(
      mobile: 2.0,
      tablet: 3.0,
    );

    final emptyStateSpacing = responsive.responsiveValue(
      mobile: 16.0,
      tablet: 24.0,
    );

    final emptyStateIconSize = responsive.responsiveValue(
      mobile: 48.0,
      tablet: 64.0,
    );

    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: SizedBox(
              width: loadingIndicatorSize,
              height: loadingIndicatorSize,
              child: CircularProgressIndicator(
                strokeWidth: loadingStrokeWidth,
              ),
            ),
          );
        }

        if (!controller.hasSearched.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search,
                  size: emptyStateIconSize,
                  color: Colors.grey[400],
                ),
                SizedBox(height: emptyStateSpacing),
                ResponsiveText(
                  'Arama yapmak için yukarıdaki alanı kullanın',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: responsive.responsiveValue(
                      mobile: 16.0,
                      tablet: 18.0,
                    ),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: emptyStateIconSize,
                  color: Colors.grey[400],
                ),
                SizedBox(height: emptyStateSpacing),
                ResponsiveText(
                  'Sonuç bulunamadı',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: responsive.responsiveValue(
                      mobile: 16.0,
                      tablet: 18.0,
                    ),
                    color: Colors.grey[600],
                  ),
                ),
              ],
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
                          all: responsive.responsiveValue(
                              mobile: 8.0, tablet: 12.0),
                        ),
                        child: SizedBox(
                          width: loadingIndicatorSize,
                          height: loadingIndicatorSize,
                          child: CircularProgressIndicator(
                            strokeWidth: loadingStrokeWidth,
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

    final cardMargin = performanceService.getOptimizedPadding(
      cacheKey: 'message_card_margin',
      horizontal: responsive.responsiveValue(mobile: 12.0, tablet: 16.0),
      vertical: responsive.responsiveValue(mobile: 6.0, tablet: 8.0),
    );

    final contentPadding = performanceService.getOptimizedPadding(
      cacheKey: 'message_content_padding',
      horizontal: responsive.responsiveValue(mobile: 12.0, tablet: 16.0),
      vertical: responsive.responsiveValue(mobile: 8.0, tablet: 12.0),
    );

    final iconSize = responsive.responsiveValue(
      mobile: 18.0,
      tablet: 20.0,
    );

    return Card(
      margin: cardMargin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: contentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  message.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: responsive.responsiveValue(
                      mobile: 14.0,
                      tablet: 16.0,
                    ),
                  ),
                ),
                SizedBox(
                    height:
                        responsive.responsiveValue(mobile: 4.0, tablet: 6.0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ResponsiveText(
                        'Gönderen: ${message.senderName}',
                        style: TextStyle(
                          fontSize: responsive.responsiveValue(
                            mobile: 12.0,
                            tablet: 14.0,
                          ),
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    ResponsiveText(
                      _formatDate(message.timestamp),
                      style: TextStyle(
                        fontSize: responsive.responsiveValue(
                          mobile: 12.0,
                          tablet: 14.0,
                        ),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.end,
            buttonPadding: EdgeInsets.symmetric(
              horizontal: responsive.responsiveValue(mobile: 8.0, tablet: 12.0),
            ),
            children: [
              TextButton.icon(
                icon: Icon(
                  Icons.share,
                  size: iconSize,
                ),
                label: ResponsiveText(
                  'Paylaş',
                  style: TextStyle(
                    fontSize: responsive.responsiveValue(
                      mobile: 14.0,
                      tablet: 16.0,
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

    final dialogPadding = performanceService.getOptimizedPadding(
      cacheKey: 'analytics_dialog_padding',
      horizontal: responsive.responsiveValue(mobile: 16.0, tablet: 24.0),
      vertical: responsive.responsiveValue(mobile: 12.0, tablet: 16.0),
    );

    final sectionSpacing = responsive.responsiveValue(
      mobile: 16.0,
      tablet: 24.0,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ResponsiveText(
          'Arama İstatistikleri',
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 18.0,
              tablet: 22.0,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        contentPadding: dialogPadding,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnalyticsSection(
                'Genel İstatistikler',
                [
                  ResponsiveText(
                    'Toplam Arama: ${analytics['totalSearches']}',
                    style: TextStyle(
                      fontSize: responsive.responsiveValue(
                        mobile: 14.0,
                        tablet: 16.0,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sectionSpacing),
              _buildAnalyticsSection(
                'En Çok Aranan',
                [
                  ResponsiveText(
                    '${analytics['mostSearched'].term} (${analytics['mostSearched'].count} kez)',
                    style: TextStyle(
                      fontSize: responsive.responsiveValue(
                        mobile: 14.0,
                        tablet: 16.0,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sectionSpacing),
              _buildAnalyticsSection(
                AppStrings.recentSearches,
                analytics['recentSearches']
                    .map<Widget>((stat) => ResponsiveText(
                          '${stat.term} - ${_formatDate(stat.lastSearched)}',
                          style: TextStyle(
                            fontSize: responsive.responsiveValue(
                              mobile: 14.0,
                              tablet: 16.0,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: ResponsiveText(
              AppStrings.close,
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 16.0,
                  tablet: 18.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection(String title, List<Widget> children) {
    final responsive = Get.find<ResponsiveController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          title,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 16.0,
              tablet: 18.0,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: responsive.responsiveValue(mobile: 8.0, tablet: 12.0)),
        ...children,
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    final dialogPadding = performanceService.getOptimizedPadding(
      cacheKey: 'filter_dialog_padding',
      horizontal: responsive.responsiveValue(mobile: 16.0, tablet: 24.0),
      vertical: responsive.responsiveValue(mobile: 12.0, tablet: 16.0),
    );

    final sectionSpacing = responsive.responsiveValue(
      mobile: 16.0,
      tablet: 24.0,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ResponsiveText(
          AppStrings.filters,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 18.0,
              tablet: 22.0,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        contentPadding: dialogPadding,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterSection(
                AppStrings.messageTypes,
                [
                  _buildFilterSwitch(
                    AppStrings.textMessages,
                    controller.filterText,
                    controller.toggleTextFilter,
                  ),
                  _buildFilterSwitch(
                    AppStrings.media,
                    controller.filterMedia,
                    controller.toggleMediaFilter,
                  ),
                  _buildFilterSwitch(
                    AppStrings.documents,
                    controller.filterDocuments,
                    controller.toggleDocumentsFilter,
                  ),
                  _buildFilterSwitch(
                    AppStrings.links,
                    controller.filterLinks,
                    controller.toggleLinksFilter,
                  ),
                ],
              ),
              SizedBox(height: sectionSpacing),
              _buildFilterSection(
                AppStrings.sortingAndPriority,
                [
                  ListTile(
                    title: ResponsiveText(
                      AppStrings.sorting,
                      style: TextStyle(
                        fontSize: responsive.responsiveValue(
                          mobile: 16.0,
                          tablet: 18.0,
                        ),
                      ),
                    ),
                    trailing: Obx(
                      () => IconButton(
                        icon: Icon(
                          controller.sortOrder.value == SortOrder.ascending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: responsive.responsiveValue(
                            mobile: 24.0,
                            tablet: 28.0,
                          ),
                        ),
                        onPressed: controller.toggleSortOrder,
                      ),
                    ),
                  ),
                  _buildFilterSwitch(
                    AppStrings.priorityMessages,
                    controller.showPriority,
                    (value) {
                      controller.showPriority.value = value;
                      if (value) {
                        _showPrioritySlider(context);
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: sectionSpacing),
              _buildFilterSection(
                AppStrings.dateRange,
                [
                  ListTile(
                    title: ResponsiveText(
                      AppStrings.selectDate,
                      style: TextStyle(
                        fontSize: responsive.responsiveValue(
                          mobile: 16.0,
                          tablet: 18.0,
                        ),
                      ),
                    ),
                    subtitle: Obx(() {
                      final start = controller.startDate.value;
                      final end = controller.endDate.value;
                      if (start == null || end == null) {
                        return ResponsiveText(
                          AppStrings.notSelected,
                          style: TextStyle(
                            fontSize: responsive.responsiveValue(
                              mobile: 14.0,
                              tablet: 16.0,
                            ),
                          ),
                        );
                      }
                      return ResponsiveText(
                        '$start - $end',
                        style: TextStyle(
                          fontSize: responsive.responsiveValue(
                            mobile: 14.0,
                            tablet: 16.0,
                          ),
                        ),
                      );
                    }),
                    trailing: Icon(
                      Icons.date_range,
                      size: responsive.responsiveValue(
                        mobile: 24.0,
                        tablet: 28.0,
                      ),
                    ),
                    onTap: () async {
                      await controller.selectStartDate();
                      await controller.selectEndDate();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: ResponsiveText(
              AppStrings.cancel,
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 16.0,
                  tablet: 18.0,
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
              AppStrings.apply,
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 16.0,
                  tablet: 18.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, List<Widget> children) {
    final responsive = Get.find<ResponsiveController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          title,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 16.0,
              tablet: 18.0,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildFilterSwitch(
    String title,
    RxBool value,
    void Function(bool) onChanged,
  ) {
    final responsive = Get.find<ResponsiveController>();

    return Obx(
      () => SwitchListTile(
        title: ResponsiveText(
          title,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 14.0,
              tablet: 16.0,
            ),
          ),
        ),
        value: value.value,
        onChanged: onChanged,
      ),
    );
  }

  void _showPrioritySlider(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    final dialogPadding = performanceService.getOptimizedPadding(
      cacheKey: 'priority_dialog_padding',
      horizontal: responsive.responsiveValue(mobile: 16.0, tablet: 24.0),
      vertical: responsive.responsiveValue(mobile: 12.0, tablet: 16.0),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ResponsiveText(
          AppStrings.minimumPriority,
          style: TextStyle(
            fontSize: responsive.responsiveValue(
              mobile: 18.0,
              tablet: 22.0,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        contentPadding: dialogPadding,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => Slider(
                value: controller.minPriority.value.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                label: controller.minPriority.value.toString(),
                onChanged: (value) => controller.setMinPriority(value.toInt()),
              ),
            ),
            SizedBox(
              height: responsive.responsiveValue(
                mobile: 16.0,
                tablet: 24.0,
              ),
            ),
            ResponsiveText(
              '${AppStrings.selectedValue}: ${controller.minPriority.value}',
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 14.0,
                  tablet: 16.0,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: ResponsiveText(
              AppStrings.ok,
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 16.0,
                  tablet: 18.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
