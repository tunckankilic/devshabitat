import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:devshabitat/app/models/message_model.dart';
import 'package:devshabitat/app/services/message_search_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';

enum SortOrder { ascending, descending }

enum SearchCategory { all, messages, media, documents, links }

class SearchStatistics {
  final String term;
  final int count;
  final DateTime lastSearched;

  SearchStatistics({
    required this.term,
    required this.count,
    required this.lastSearched,
  });

  Map<String, dynamic> toJson() => {
        'term': term,
        'count': count,
        'lastSearched': lastSearched.toIso8601String(),
      };

  factory SearchStatistics.fromJson(Map<String, dynamic> json) {
    return SearchStatistics(
      term: json['term'],
      count: json['count'],
      lastSearched: DateTime.parse(json['lastSearched']),
    );
  }
}

class MessageSearchController extends GetxController {
  final MessageSearchService _searchService = Get.find<MessageSearchService>();
  final GetStorage _storage = GetStorage();
  final TextEditingController searchController = TextEditingController();

  // Reaktif değişkenler
  final RxList<MessageModel> searchResults = <MessageModel>[].obs;
  final RxList<String> recentSearches = <String>[].obs;
  final RxList<String> searchSuggestions = <String>[].obs;
  final RxMap<SearchCategory, RxList<MessageModel>> categorizedResults = {
    SearchCategory.messages: <MessageModel>[].obs,
    SearchCategory.media: <MessageModel>[].obs,
    SearchCategory.documents: <MessageModel>[].obs,
    SearchCategory.links: <MessageModel>[].obs,
  }.obs;
  final RxMap<String, SearchStatistics> searchStats =
      <String, SearchStatistics>{}.obs;

  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxBool hasSearched = false.obs;
  final RxBool showSuggestions = false.obs;

  // Filtreler
  final RxBool filterText = false.obs;
  final RxBool filterMedia = false.obs;
  final RxBool filterDocuments = false.obs;
  final RxBool filterLinks = false.obs;
  final RxString selectedSender = ''.obs;
  final Rx<String?> startDate = Rx<String?>(null);
  final Rx<String?> endDate = Rx<String?>(null);
  final RxString searchQuery = ''.obs;

  // Gelişmiş Filtreler
  final Rx<SortOrder> sortOrder = SortOrder.descending.obs;
  final RxBool showPriority = false.obs;
  final RxInt minPriority = 0.obs;
  final RxString selectedCategory = SearchCategory.all.toString().obs;

  // Pagination ve Debounce için değişkenler
  Timer? _debounceTimer;
  Timer? _suggestionTimer;
  DocumentSnapshot? _lastDocument;

  // Sabitler
  static const String _recentSearchesKey = 'recent_searches';
  static const String _searchStatsKey = 'search_stats';
  static const int _maxRecentSearches = 10;
  static const int _debounceTime = 300;
  static const int _suggestionDelay = 500;
  static const int _pageSize = 20;

  List<String> get senderList => _searchService.availableSenders;

  @override
  void onInit() {
    super.onInit();
    _loadRecentSearches();
    _loadSearchStats();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    _suggestionTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }

  // UI Events
  void onSearchChanged(String value) {
    searchQuery.value = value;
    if (value.isEmpty) {
      clearSearch();
      return;
    }
    _updateSearchSuggestions(value);
    _debounceSearch(value);
  }

  void _updateSearchSuggestions(String value) {
    if (_suggestionTimer?.isActive ?? false) _suggestionTimer!.cancel();

    _suggestionTimer = Timer(
      const Duration(milliseconds: _suggestionDelay),
      () async {
        if (value.isEmpty) {
          searchSuggestions.clear();
          showSuggestions.value = false;
          return;
        }

        final suggestions = await _searchService.getSearchSuggestions(value);
        searchSuggestions.assignAll(suggestions);
        showSuggestions.value = suggestions.isNotEmpty;
      },
    );
  }

  void _debounceSearch(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(
      const Duration(milliseconds: _debounceTime),
      () => performSearch(value),
    );
  }

  // Ana Arama Fonksiyonu
  Future<void> performSearch(String query) async {
    if (query.isEmpty) return;

    isLoading.value = true;
    hasSearched.value = true;
    searchQuery.value = query;

    try {
      final List<MessageModel> results = await _searchService.searchMessages(
        searchTerm: query,
        filters: _getCurrentFilters(),
        lastDocument: _lastDocument,
      );

      if (_lastDocument == null) {
        searchResults.clear();
        _clearCategorizedResults();
      }

      searchResults.addAll(results);
      _categorizePosts(results);
      hasMore.value = results.length >= _pageSize;

      await _addToRecentSearches(query);
      await _updateSearchStats(query);
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Arama sırasında bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _clearCategorizedResults() {
    for (var category in SearchCategory.values) {
      categorizedResults[category]?.clear();
    }
  }

  void _categorizePosts(List<MessageModel> messages) {
    for (var message in messages) {
      if (message.hasMedia) {
        categorizedResults[SearchCategory.media]?.add(message);
      } else if (message.hasDocument) {
        categorizedResults[SearchCategory.documents]?.add(message);
      } else if (message.hasLinks) {
        categorizedResults[SearchCategory.links]?.add(message);
      } else {
        categorizedResults[SearchCategory.messages]?.add(message);
      }
    }
  }

  // İstatistik İşlemleri
  Future<void> _loadSearchStats() async {
    final stats = _storage.read<String>(_searchStatsKey);
    if (stats != null) {
      final Map<String, dynamic> decoded = json.decode(stats);
      searchStats.assignAll(
        Map.fromEntries(
          decoded.entries.map(
            (e) => MapEntry(
              e.key,
              SearchStatistics.fromJson(e.value as Map<String, dynamic>),
            ),
          ),
        ),
      );
    }
  }

  Future<void> _updateSearchStats(String query) async {
    final stats = searchStats[query];
    final newStats = SearchStatistics(
      term: query,
      count: (stats?.count ?? 0) + 1,
      lastSearched: DateTime.now(),
    );
    searchStats[query] = newStats;
    await _storage.write(_searchStatsKey, json.encode(searchStats));
  }

  Map<String, dynamic> getSearchAnalytics() {
    final totalSearches =
        searchStats.values.fold(0, (sum, stat) => sum + stat.count);
    final mostSearched = searchStats.values.reduce(
      (curr, next) => curr.count > next.count ? curr : next,
    );
    final recentSearches = searchStats.values.toList()
      ..sort((a, b) => b.lastSearched.compareTo(a.lastSearched));

    return {
      'totalSearches': totalSearches,
      'mostSearched': mostSearched,
      'recentSearches': recentSearches.take(5).toList(),
    };
  }

  // Paylaşım İşlemleri
  Future<void> shareSearchResults(List<MessageModel> messages) async {
    final text = messages.map((msg) => '''
${msg.senderName} - ${_formatDate(msg.timestamp)}
${msg.content}
''').join('\n---\n');

    await Share.share(
      'Arama Sonuçları:\n\n$text',
      subject: 'Arama Sonuçları',
    );
  }

  Future<void> shareSelectedResults(List<MessageModel> selected) async {
    if (selected.isEmpty) return;
    await shareSearchResults(selected);
  }

  // Kullanıcıya göre arama
  Future<void> searchByUser(String userId) async {
    isLoading.value = true;
    try {
      final List<DocumentSnapshot> results = await _searchService.searchByUser(
        userId: userId,
        lastDocument: _lastDocument,
      );

      if (_lastDocument == null) {
        searchResults.clear();
      }

      final messageResults = results.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return MessageModel.fromMap({...data, 'id': doc.id});
      }).toList();

      searchResults.addAll(messageResults);
      _lastDocument = results.isNotEmpty ? results.last : null;
      hasMore.value = messageResults.length >= _pageSize;
    } finally {
      isLoading.value = false;
    }
  }

  // Tarihe göre arama
  Future<void> searchByDate(DateTime startDate, DateTime endDate) async {
    isLoading.value = true;
    try {
      final List<DocumentSnapshot> results = await _searchService.searchByDate(
        startDate: startDate,
        endDate: endDate,
        lastDocument: _lastDocument,
      );

      if (_lastDocument == null) {
        searchResults.clear();
      }

      final messageResults = results.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return MessageModel.fromMap({...data, 'id': doc.id});
      }).toList();

      searchResults.addAll(messageResults);
      _lastDocument = results.isNotEmpty ? results.last : null;
      hasMore.value = messageResults.length >= _pageSize;
    } finally {
      isLoading.value = false;
    }
  }

  // Daha fazla sonuç yükleme
  Future<void> loadMore() async {
    if (!hasMore.value || isLoading.value || searchQuery.isEmpty) return;
    await performSearch(searchQuery.value);
  }

  // Filtre İşlemleri
  void toggleTextFilter(bool value) => filterText.value = value;
  void toggleMediaFilter(bool value) => filterMedia.value = value;
  void toggleDocumentsFilter(bool value) => filterDocuments.value = value;
  void toggleLinksFilter(bool value) => filterLinks.value = value;
  void setSender(String? sender) => selectedSender.value = sender ?? '';

  Future<void> selectStartDate() async {
    final date = await _selectDate(
      initialDate: startDate.value != null
          ? DateTime.parse(startDate.value!)
          : DateTime.now(),
    );
    if (date != null) {
      startDate.value = date.toIso8601String();
      if (searchQuery.isNotEmpty) performSearch(searchQuery.value);
    }
  }

  Future<void> selectEndDate() async {
    final date = await _selectDate(
      initialDate: endDate.value != null
          ? DateTime.parse(endDate.value!)
          : DateTime.now(),
    );
    if (date != null) {
      endDate.value = date.toIso8601String();
      if (searchQuery.isNotEmpty) performSearch(searchQuery.value);
    }
  }

  Future<DateTime?> _selectDate({required DateTime initialDate}) async {
    return await showDatePicker(
      context: Get.context!,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
  }

  Map<String, dynamic> _getCurrentFilters() {
    final List<MessageType> types = [];
    if (filterText.value) types.add(MessageType.text);
    if (filterMedia.value) types.add(MessageType.image);
    if (filterDocuments.value) types.add(MessageType.document);
    if (filterLinks.value) types.add(MessageType.link);

    return {
      'types': types,
      'sender': selectedSender.value,
      'startDate': startDate.value,
      'endDate': endDate.value,
      'sortOrder': sortOrder.value,
      'minPriority': showPriority.value ? minPriority.value : null,
    };
  }

  void applyFilters() {
    if (searchQuery.isNotEmpty) {
      _lastDocument = null;
      performSearch(searchQuery.value);
    }
  }

  // Son Aramalar İşlemleri
  Future<void> _loadRecentSearches() async {
    final searches = _storage.read<List<dynamic>>(_recentSearchesKey) ?? [];
    recentSearches.assignAll(searches.cast<String>());
  }

  Future<void> _addToRecentSearches(String query) async {
    if (query.isEmpty) return;

    recentSearches.remove(query);
    recentSearches.insert(0, query);

    if (recentSearches.length > _maxRecentSearches) {
      recentSearches.removeLast();
    }

    await _storage.write(_recentSearchesKey, recentSearches.toList());
  }

  Future<void> removeRecentSearch(String query) async {
    recentSearches.remove(query);
    await _storage.write(_recentSearchesKey, recentSearches.toList());
  }

  // Temizleme İşlemleri
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    searchResults.clear();
    hasSearched.value = false;
    _lastDocument = null;
    hasMore.value = true;
  }

  void clearRecentSearches() {
    recentSearches.clear();
    _storage.remove(_recentSearchesKey);
  }

  // Navigasyon
  void navigateToMessage(MessageModel message) {
    Get.toNamed(
      '/conversation/${message.conversationId}',
      arguments: {'messageId': message.id},
    );
  }

  // Gelişmiş Filtre İşlemleri
  void toggleSortOrder() {
    sortOrder.value = sortOrder.value == SortOrder.ascending
        ? SortOrder.descending
        : SortOrder.ascending;
    _reorderResults();
  }

  void _reorderResults() {
    searchResults.sort((a, b) {
      final comparison = a.timestamp.compareTo(b.timestamp);
      return sortOrder.value == SortOrder.ascending ? comparison : -comparison;
    });
  }

  void setMinPriority(int value) {
    minPriority.value = value;
    if (searchQuery.isNotEmpty) {
      _lastDocument = null;
      performSearch(searchQuery.value);
    }
  }

  void setSelectedCategory(String category) {
    selectedCategory.value = category;
    // Kategoriye göre sonuçları filtrele
    if (category == SearchCategory.all.toString()) {
      searchResults.assignAll(
        categorizedResults.values.expand((list) => list).toList(),
      );
    } else {
      final selectedEnum = SearchCategory.values.firstWhere(
        (e) => e.toString() == category,
      );
      searchResults.assignAll(categorizedResults[selectedEnum] ?? []);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
