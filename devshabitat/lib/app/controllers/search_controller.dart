import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/message_search_service.dart';
import '../models/message_model.dart';

class MessageSearchController extends GetxController {
  final MessageSearchService _searchService = Get.find<MessageSearchService>();
  final GetStorage _storage = GetStorage();

  // Reaktif değişkenler
  final RxList<Message> searchResults = <Message>[].obs;
  final RxList<String> recentSearches = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;

  // Arama gecikmesi için zamanlayıcı
  Timer? _debounceTimer;
  DocumentSnapshot? _lastDocument;

  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 10;
  static const int _debounceTime = 300;

  @override
  void onInit() {
    super.onInit();
    _loadRecentSearches();
  }

  // Gecikmeli arama
  void searchMessages(String searchTerm, Map<String, dynamic> filters) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer =
        Timer(const Duration(milliseconds: _debounceTime), () async {
      if (searchTerm.isEmpty) {
        searchResults.clear();
        return;
      }

      isLoading.value = true;
      try {
        final results = await _searchService.searchMessages(
          searchTerm: searchTerm,
          filters: filters,
        );

        searchResults.assignAll(results);
        _lastDocument = null;
        hasMore.value = results.length >= _searchService.pageSize;

        _addToRecentSearches(searchTerm);
      } finally {
        isLoading.value = false;
      }
    });
  }

  // Kullanıcıya göre arama
  Future<void> searchByUser(String userId) async {
    isLoading.value = true;
    try {
      final docResults = await _searchService.searchByUser(
        userId: userId,
        lastDocument: _lastDocument,
      );

      final messageResults =
          docResults.map((doc) => Message.fromFirestore(doc)).toList();

      if (_lastDocument == null) {
        searchResults.assignAll(messageResults);
      } else {
        searchResults.addAll(messageResults);
      }

      _lastDocument = docResults.isNotEmpty ? docResults.last : null;
      hasMore.value = docResults.length >= _searchService.pageSize;
    } finally {
      isLoading.value = false;
    }
  }

  // Tarihe göre arama
  Future<void> searchByDate(DateTime startDate, DateTime endDate) async {
    isLoading.value = true;
    try {
      final docResults = await _searchService.searchByDate(
        startDate: startDate,
        endDate: endDate,
        lastDocument: _lastDocument,
      );

      final messageResults =
          docResults.map((doc) => Message.fromFirestore(doc)).toList();

      if (_lastDocument == null) {
        searchResults.assignAll(messageResults);
      } else {
        searchResults.addAll(messageResults);
      }

      _lastDocument = docResults.isNotEmpty ? docResults.last : null;
      hasMore.value = docResults.length >= _searchService.pageSize;
    } finally {
      isLoading.value = false;
    }
  }

  // Daha fazla sonuç yükleme
  Future<void> loadMore(String searchTerm, Map<String, dynamic> filters) async {
    if (!hasMore.value || isLoading.value) return;

    isLoading.value = true;
    try {
      final results = await _searchService.searchMessages(
        searchTerm: searchTerm,
        filters: filters,
        lastDocument: _lastDocument,
      );

      searchResults.addAll(results);
      _lastDocument = null;
      hasMore.value = results.length >= _searchService.pageSize;
    } finally {
      isLoading.value = false;
    }
  }

  // Son aramaları yükleme
  void _loadRecentSearches() {
    final searches = _storage.read<List<dynamic>>(_recentSearchesKey) ?? [];
    recentSearches.assignAll(searches.cast<String>());
  }

  // Son aramalara ekleme
  void _addToRecentSearches(String searchTerm) {
    if (searchTerm.isEmpty) return;

    recentSearches.remove(searchTerm);
    recentSearches.insert(0, searchTerm);

    if (recentSearches.length > _maxRecentSearches) {
      recentSearches.removeLast();
    }

    _storage.write(_recentSearchesKey, recentSearches.toList());
  }

  // Son aramaları temizleme
  void clearRecentSearches() {
    recentSearches.clear();
    _storage.remove(_recentSearchesKey);
  }

  // Aramayı sıfırlama
  void resetSearch() {
    searchResults.clear();
    _lastDocument = null;
    hasMore.value = true;
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}
