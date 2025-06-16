import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/models/message_model.dart';
import 'package:devshabitat/app/services/message_search_service.dart';

class MessageSearchController extends GetxController {
  final MessageSearchService _searchService = Get.find<MessageSearchService>();
  final searchController = TextEditingController();

  final RxList<Message> searchResults = <Message>[].obs;
  final RxList<String> recentSearches = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasSearched = false.obs;

  // Filtreler
  final RxBool filterText = false.obs;
  final RxBool filterMedia = false.obs;
  final RxBool filterDocuments = false.obs;
  final RxBool filterLinks = false.obs;

  final RxString selectedSender = ''.obs;
  final Rx<String?> startDate = Rx<String?>(null);
  final Rx<String?> endDate = Rx<String?>(null);

  final RxString searchQuery = ''.obs;

  List<String> get senderList => _searchService.availableSenders;

  @override
  void onInit() {
    super.onInit();
    _loadRecentSearches();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    if (value.isEmpty) {
      clearSearch();
    }
  }

  Future<void> performSearch(String query) async {
    if (query.isEmpty) return;

    isLoading.value = true;
    hasSearched.value = true;
    searchQuery.value = query;

    try {
      final results = await _searchService.searchMessages(
        searchTerm: query,
        filters: _getCurrentFilters(),
      );
      searchResults.value = results
          .map((doc) => Message.fromFirestore(doc as DocumentSnapshot<Object?>))
          .toList();
      _addToRecentSearches(query);
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

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    searchResults.clear();
    hasSearched.value = false;
  }

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
    };
  }

  void applyFilters() {
    if (searchQuery.isNotEmpty) {
      performSearch(searchQuery.value);
    }
  }

  Future<void> _loadRecentSearches() async {
    final searches = await _searchService.getRecentSearches();
    recentSearches.value = searches;
  }

  Future<void> _addToRecentSearches(String query) async {
    await _searchService.addRecentSearch(query);
    await _loadRecentSearches();
  }

  Future<void> removeRecentSearch(String query) async {
    await _searchService.removeRecentSearch(query);
    await _loadRecentSearches();
  }

  void navigateToMessage(Message message) {
    Get.toNamed(
      '/conversation/${message.conversationId}',
      arguments: {'messageId': message.id},
    );
  }
}
