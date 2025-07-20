import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/message/message_search_controller.dart';
import '../../models/message_model.dart';
import '../base/base_view.dart';
import '../../controllers/responsive_controller.dart';

class MessageSearchView extends BaseView<MessageSearchController> {
  final String? conversationId = Get.parameters['id'];

  MessageSearchView({super.key});

  @override
  Widget buildView(BuildContext context) {
    final responsive = Get.find<ResponsiveController>();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 16, tablet: 18)),
          decoration: InputDecoration(
            hintText: 'Mesajlarda ara...',
            hintStyle: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 16, tablet: 18)),
            border: InputBorder.none,
          ),
          onChanged: controller.setSearchQuery,
        ),
        actions: [
          Obx(() {
            if (!controller.isAdvancedSearch.value) {
              return IconButton(
                icon: Icon(Icons.filter_list,
                    size: responsive.responsiveValue(mobile: 24, tablet: 28)),
                onPressed: controller.toggleAdvancedSearch,
              );
            }
            return IconButton(
              icon: Icon(Icons.filter_list_off,
                  size: responsive.responsiveValue(mobile: 24, tablet: 28)),
              onPressed: controller.toggleAdvancedSearch,
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // Gelişmiş arama filtreleri
          Obx(() {
            if (!controller.isAdvancedSearch.value) {
              return const SizedBox();
            }

            return Container(
              padding: EdgeInsets.all(
                  responsive.responsiveValue(mobile: 16, tablet: 20)),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius:
                        responsive.responsiveValue(mobile: 4, tablet: 6),
                    offset: Offset(
                        0, responsive.responsiveValue(mobile: 2, tablet: 3)),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtreler',
                    style: TextStyle(
                      fontSize:
                          responsive.responsiveValue(mobile: 18, tablet: 20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                      height:
                          responsive.responsiveValue(mobile: 16, tablet: 20)),
                  // Konuşma seçimi
                  if (conversationId == null)
                    DropdownButtonFormField<String>(
                      value: controller.selectedConversation.value.isEmpty
                          ? null
                          : controller.selectedConversation.value,
                      decoration: InputDecoration(
                        labelText: 'Konuşma',
                        labelStyle: TextStyle(
                            fontSize: responsive.responsiveValue(
                                mobile: 14, tablet: 16)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(responsive
                              .responsiveValue(mobile: 8, tablet: 12)),
                        ),
                      ),
                      items: const [], // Konuşma listesi buraya gelecek
                      onChanged: controller.setConversationFilter,
                    ),
                  SizedBox(
                      height:
                          responsive.responsiveValue(mobile: 16, tablet: 20)),
                  // Tarih seçimi
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Tarih',
                      labelStyle: TextStyle(
                          fontSize: responsive.responsiveValue(
                              mobile: 14, tablet: 16)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            responsive.responsiveValue(mobile: 8, tablet: 12)),
                      ),
                      suffixIcon: Icon(Icons.calendar_today,
                          size: responsive.responsiveValue(
                              mobile: 24, tablet: 28)),
                    ),
                    readOnly: true,
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
                  SizedBox(
                      height:
                          responsive.responsiveValue(mobile: 16, tablet: 20)),
                  // Mesaj tipi seçimi
                  DropdownButtonFormField<String>(
                    value: controller.selectedType.value.isEmpty
                        ? null
                        : controller.selectedType.value,
                    decoration: InputDecoration(
                      labelText: 'Mesaj Tipi',
                      labelStyle: TextStyle(
                          fontSize: responsive.responsiveValue(
                              mobile: 14, tablet: 16)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            responsive.responsiveValue(mobile: 8, tablet: 12)),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'text',
                        child: Text('Metin'),
                      ),
                      DropdownMenuItem(
                        value: 'image',
                        child: Text('Görsel'),
                      ),
                      DropdownMenuItem(
                        value: 'file',
                        child: Text('Dosya'),
                      ),
                    ],
                    onChanged: controller.setTypeFilter,
                  ),
                  SizedBox(
                      height:
                          responsive.responsiveValue(mobile: 16, tablet: 20)),
                  // Filtreleri temizle
                  Center(
                    child: TextButton.icon(
                      icon: Icon(Icons.clear_all,
                          size: responsive.responsiveValue(
                              mobile: 24, tablet: 28)),
                      label: Text(
                        'Filtreleri Temizle',
                        style: TextStyle(
                            fontSize: responsive.responsiveValue(
                                mobile: 14, tablet: 16)),
                      ),
                      onPressed: controller.clearFilters,
                    ),
                  ),
                ],
              ),
            );
          }),

          // Arama sonuçları
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.searchQuery.isEmpty) {
                return Center(
                  child: Text(
                    'Aramak istediğiniz mesajı yazın',
                    style: TextStyle(
                        fontSize:
                            responsive.responsiveValue(mobile: 16, tablet: 18)),
                  ),
                );
              }

              if (controller.searchResults.isEmpty) {
                return Center(
                  child: Text(
                    'Sonuç bulunamadı',
                    style: TextStyle(
                        fontSize:
                            responsive.responsiveValue(mobile: 16, tablet: 18)),
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.searchResults.length,
                itemBuilder: (context, index) {
                  final message = controller.searchResults[index];
                  return _buildSearchResultTile(message);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultTile(MessageModel message) {
    final responsive = Get.find<ResponsiveController>();

    return ListTile(
      leading: CircleAvatar(
        radius: responsive.responsiveValue(mobile: 20, tablet: 24),
        child: Text(
          message.senderId[0].toUpperCase(),
          style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 14, tablet: 16)),
        ),
      ),
      title: Text(
        message.content,
        style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 16, tablet: 18)),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _formatTime(message.timestamp),
        style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 12, tablet: 14)),
      ),
      onTap: () {
        // Mesaja git
        Get.toNamed('/chat/${message.id}');
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 7) {
      return '${time.day}/${time.month}/${time.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dk önce';
    } else {
      return 'Şimdi';
    }
  }
}
