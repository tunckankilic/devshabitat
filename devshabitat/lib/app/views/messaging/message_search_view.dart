import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/message/message_search_controller.dart';
import '../../models/message_model.dart';
import '../base/base_view.dart';

class MessageSearchView extends BaseView<MessageSearchController> {
  final String? conversationId = Get.parameters['id'];

  MessageSearchView({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          style: TextStyle(fontSize: 16.sp),
          decoration: InputDecoration(
            hintText: 'Mesajlarda ara...',
            hintStyle: TextStyle(fontSize: 16.sp),
            border: InputBorder.none,
          ),
          onChanged: controller.setSearchQuery,
        ),
        actions: [
          Obx(() {
            if (!controller.isAdvancedSearch.value) {
              return IconButton(
                icon: Icon(Icons.filter_list, size: 24.sp),
                onPressed: controller.toggleAdvancedSearch,
              );
            }
            return IconButton(
              icon: Icon(Icons.filter_list_off, size: 24.sp),
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
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtreler',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Konuşma seçimi
                  if (conversationId == null)
                    DropdownButtonFormField<String>(
                      value: controller.selectedConversation.value.isEmpty
                          ? null
                          : controller.selectedConversation.value,
                      decoration: InputDecoration(
                        labelText: 'Konuşma',
                        labelStyle: TextStyle(fontSize: 14.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      items: const [], // Konuşma listesi buraya gelecek
                      onChanged: controller.setConversationFilter,
                    ),
                  SizedBox(height: 16.h),
                  // Tarih seçimi
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Tarih',
                      labelStyle: TextStyle(fontSize: 14.sp),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      suffixIcon: Icon(Icons.calendar_today, size: 24.sp),
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
                  SizedBox(height: 16.h),
                  // Mesaj tipi seçimi
                  DropdownButtonFormField<String>(
                    value: controller.selectedType.value.isEmpty
                        ? null
                        : controller.selectedType.value,
                    decoration: InputDecoration(
                      labelText: 'Mesaj Tipi',
                      labelStyle: TextStyle(fontSize: 14.sp),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
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
                  SizedBox(height: 16.h),
                  // Filtreleri temizle
                  Center(
                    child: TextButton.icon(
                      icon: Icon(Icons.clear_all, size: 24.sp),
                      label: Text(
                        'Filtreleri Temizle',
                        style: TextStyle(fontSize: 14.sp),
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
                    style: TextStyle(fontSize: 16.sp),
                  ),
                );
              }

              if (controller.searchResults.isEmpty) {
                return Center(
                  child: Text(
                    'Sonuç bulunamadı',
                    style: TextStyle(fontSize: 16.sp),
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
    return ListTile(
      leading: CircleAvatar(
        radius: 20.r,
        child: Text(
          message.senderId[0].toUpperCase(),
          style: TextStyle(fontSize: 14.sp),
        ),
      ),
      title: Text(
        message.content,
        style: TextStyle(fontSize: 16.sp),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _formatTime(message.timestamp),
        style: TextStyle(fontSize: 12.sp),
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
