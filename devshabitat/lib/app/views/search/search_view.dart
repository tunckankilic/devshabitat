import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/message/message_search_controller.dart';
import '../../models/message_model.dart';
import '../../controllers/responsive_controller.dart';
import '../../widgets/responsive/responsive_text.dart';
import '../base/base_view.dart';

class SearchView extends BaseView<MessageSearchController> {
  const SearchView({super.key});

  @override
  Widget buildView(BuildContext context) {
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
          _buildSearchResults(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final responsive = Get.find<ResponsiveController>();

    return Padding(
      padding: EdgeInsets.all(
          responsive.responsiveValue(mobile: 12.0, tablet: 16.0)),
      child: TextField(
        onChanged: controller.setSearchQuery,
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
            size: responsive.responsiveValue(mobile: 24.0, tablet: 28.0),
          ),
          suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    size:
                        responsive.responsiveValue(mobile: 24.0, tablet: 28.0),
                  ),
                  onPressed: controller.clearSearch,
                )
              : const SizedBox()),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              responsive.responsiveValue(mobile: 12.0, tablet: 16.0),
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: responsive.responsiveValue(mobile: 12.0, tablet: 16.0),
            vertical: responsive.responsiveValue(mobile: 8.0, tablet: 12.0),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final responsive = Get.find<ResponsiveController>();

    return Expanded(
      child: Obx(() {
        if (controller.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: responsive.responsiveValue(mobile: 2.0, tablet: 3.0),
            ),
          );
        }

        if (controller.searchQuery.value.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search,
                  size: responsive.responsiveValue(mobile: 48.0, tablet: 64.0),
                  color: Colors.grey[400],
                ),
                SizedBox(
                    height:
                        responsive.responsiveValue(mobile: 16.0, tablet: 24.0)),
                ResponsiveText(
                  'Arama yapmak için yukarıdaki alanı kullanın',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 16.0, tablet: 18.0),
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
                  size: responsive.responsiveValue(mobile: 48.0, tablet: 64.0),
                  color: Colors.grey[400],
                ),
                SizedBox(
                    height:
                        responsive.responsiveValue(mobile: 16.0, tablet: 24.0)),
                ResponsiveText(
                  'Sonuç bulunamadı',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 16.0, tablet: 18.0),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.searchResults.length,
          itemBuilder: (context, index) {
            final message = controller.searchResults[index];
            return _buildMessageCard(message);
          },
        );
      }),
    );
  }

  Widget _buildMessageCard(MessageModel message) {
    final responsive = Get.find<ResponsiveController>();

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: responsive.responsiveValue(mobile: 12.0, tablet: 16.0),
        vertical: responsive.responsiveValue(mobile: 6.0, tablet: 8.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          responsive.responsiveValue(mobile: 12.0, tablet: 16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveText(
              message.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize:
                    responsive.responsiveValue(mobile: 14.0, tablet: 16.0),
              ),
            ),
            SizedBox(
                height: responsive.responsiveValue(mobile: 4.0, tablet: 6.0)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ResponsiveText(
                    'Gönderen: ${message.senderName}',
                    style: TextStyle(
                      fontSize: responsive.responsiveValue(
                          mobile: 12.0, tablet: 14.0),
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                ResponsiveText(
                  _formatDate(message.timestamp),
                  style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 12.0, tablet: 14.0),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showFilterDialog(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ResponsiveText(
          'Gelişmiş Arama',
          style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 18.0, tablet: 22.0),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => SwitchListTile(
                    title: ResponsiveText(
                      'Gelişmiş Arama',
                      style: TextStyle(
                        fontSize: responsive.responsiveValue(
                            mobile: 14.0, tablet: 16.0),
                      ),
                    ),
                    value: controller.isAdvancedSearch.value,
                    onChanged: (_) => controller.toggleAdvancedSearch(),
                  )),
              Obx(() {
                if (controller.isAdvancedSearch.value) {
                  return Column(
                    children: [
                      ListTile(
                        title: ResponsiveText(
                          'Sohbet Seç',
                          style: TextStyle(
                            fontSize: responsive.responsiveValue(
                                mobile: 14.0, tablet: 16.0),
                          ),
                        ),
                        subtitle: ResponsiveText(
                          controller.selectedConversation.value.isEmpty
                              ? 'Tüm sohbetler'
                              : controller.selectedConversation.value,
                          style: TextStyle(
                            fontSize: responsive.responsiveValue(
                                mobile: 12.0, tablet: 14.0),
                          ),
                        ),
                        onTap: () {
                          // Sohbet seçimi için dialog açılabilir
                        },
                      ),
                      ListTile(
                        title: ResponsiveText(
                          'Tarih Filtresi',
                          style: TextStyle(
                            fontSize: responsive.responsiveValue(
                                mobile: 14.0, tablet: 16.0),
                          ),
                        ),
                        subtitle: ResponsiveText(
                          controller.selectedDate.value.isEmpty
                              ? 'Tarih seçilmedi'
                              : controller.selectedDate.value,
                          style: TextStyle(
                            fontSize: responsive.responsiveValue(
                                mobile: 12.0, tablet: 14.0),
                          ),
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            controller.setDateFilter(date.toIso8601String());
                          }
                        },
                      ),
                    ],
                  );
                } else {
                  return const SizedBox();
                }
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearFilters();
              Get.back();
            },
            child: ResponsiveText(
              'Temizle',
              style: TextStyle(
                fontSize:
                    responsive.responsiveValue(mobile: 16.0, tablet: 18.0),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: ResponsiveText(
              'Tamam',
              style: TextStyle(
                fontSize:
                    responsive.responsiveValue(mobile: 16.0, tablet: 18.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
