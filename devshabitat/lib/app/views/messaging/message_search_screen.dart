import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/widgets/search_result_tile.dart';
import 'package:devshabitat/app/controllers/message_search_controller.dart';

class MessageSearchScreen extends GetView<MessageSearchController> {
  const MessageSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchBar(),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterPanel(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.searchResults.isEmpty &&
                  !controller.hasSearched.value) {
                return _buildRecentSearches();
              }

              if (controller.searchResults.isEmpty) {
                return _buildEmptyState();
              }

              return _buildSearchResults();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return SearchBar(
      controller: controller.searchController,
      hintText: 'Mesajlarda ara...',
      leading: const Icon(Icons.search),
      trailing: [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: controller.clearSearch,
        ),
      ],
      onSubmitted: controller.performSearch,
      onChanged: controller.onSearchChanged,
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(() => Row(
            children: [
              FilterChip(
                label: const Text('Medya'),
                selected: controller.filterMedia.value,
                onSelected: controller.toggleMediaFilter,
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Belgeler'),
                selected: controller.filterDocuments.value,
                onSelected: controller.toggleDocumentsFilter,
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Bağlantılar'),
                selected: controller.filterLinks.value,
                onSelected: controller.toggleLinksFilter,
              ),
            ],
          )),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        final result = controller.searchResults[index];
        return SearchResultTile(
          searchResult: result,
          onTap: () => controller.navigateToMessage(result),
          highlightText: controller.searchQuery.value,
        );
      },
    );
  }

  Widget _buildRecentSearches() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Son Aramalar',
            style: Get.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Obx(() => ListView.builder(
                shrinkWrap: true,
                itemCount: controller.recentSearches.length,
                itemBuilder: (context, index) {
                  final search = controller.recentSearches[index];
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(search),
                    onTap: () => controller.performSearch(search),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => controller.removeRecentSearch(search),
                    ),
                  );
                },
              )),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Get.theme.colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Sonuç bulunamadı',
            style: Get.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Farklı anahtar kelimeler deneyebilir veya\nfiltreleri değiştirebilirsiniz',
            textAlign: TextAlign.center,
            style: Get.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _showFilterPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gelişmiş Filtreler',
              style: Get.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildDateRangeFilter(),
            const SizedBox(height: 16),
            _buildSenderFilter(),
            const SizedBox(height: 16),
            _buildTypeFilter(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.applyFilters();
                  Get.back();
                },
                child: const Text('Filtreleri Uygula'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tarih Aralığı'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Obx(() => OutlinedButton(
                    onPressed: controller.selectStartDate,
                    child: Text(controller.startDate.value ?? 'Başlangıç'),
                  )),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Obx(() => OutlinedButton(
                    onPressed: controller.selectEndDate,
                    child: Text(controller.endDate.value ?? 'Bitiş'),
                  )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSenderFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gönderen'),
        const SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedSender.value,
              items: controller.senderList.map((sender) {
                return DropdownMenuItem(
                  value: sender,
                  child: Text(sender),
                );
              }).toList(),
              onChanged: controller.setSender,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            )),
      ],
    );
  }

  Widget _buildTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mesaj Tipi'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            Obx(() => ChoiceChip(
                  label: const Text('Metin'),
                  selected: controller.filterText.value,
                  onSelected: controller.toggleTextFilter,
                )),
            Obx(() => ChoiceChip(
                  label: const Text('Medya'),
                  selected: controller.filterMedia.value,
                  onSelected: controller.toggleMediaFilter,
                )),
            Obx(() => ChoiceChip(
                  label: const Text('Belge'),
                  selected: controller.filterDocuments.value,
                  onSelected: controller.toggleDocumentsFilter,
                )),
            Obx(() => ChoiceChip(
                  label: const Text('Bağlantı'),
                  selected: controller.filterLinks.value,
                  onSelected: controller.toggleLinksFilter,
                )),
          ],
        ),
      ],
    );
  }
}
