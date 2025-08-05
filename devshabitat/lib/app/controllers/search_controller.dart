import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/search_result_model.dart';
import '../models/user_profile_model.dart';
import '../models/blog_model.dart';
import '../models/community/community_model.dart';
import '../models/event/event_model.dart';
import '../services/search_service.dart';
import '../core/services/error_handler_service.dart';

class SearchController extends GetxController {
  final SearchService _searchService = Get.find<SearchService>();
  final ErrorHandlerService _errorHandler = Get.find<ErrorHandlerService>();

  // Form Controllers
  late TextEditingController searchController;

  // State Management
  final RxBool isLoading = false.obs;
  final RxString query = ''.obs;
  final RxString selectedFilter = 'all'.obs;
  final RxString errorMessage = ''.obs;

  // Search Results
  final Rx<SearchResultModel?> searchResults = Rx<SearchResultModel?>(null);
  final RxList<UserProfile> userResults = <UserProfile>[].obs;
  final RxList<BlogModel> blogResults = <BlogModel>[].obs;
  final RxList<CommunityModel> communityResults = <CommunityModel>[].obs;
  final RxList<EventModel> eventResults = <EventModel>[].obs;

  // Search History
  final RxList<String> searchHistory = <String>[].obs;
  final RxList<String> popularSearches = <String>[].obs;

  // Filter Options
  final List<String> filterOptions = [
    'all',
    'users',
    'blogs',
    'communities',
    'events',
  ];

  // Filter Display Names
  final Map<String, String> filterDisplayNames = {
    'all': 'Tümü',
    'users': 'Kullanıcılar',
    'blogs': 'Blog Yazıları',
    'communities': 'Topluluklar',
    'events': 'Etkinlikler',
  };

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    _loadSearchHistory();
    _loadPopularSearches();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Ana arama fonksiyonu
  Future<void> search(String searchQuery) async {
    if (searchQuery.trim().isEmpty) return;

    isLoading.value = true;
    errorMessage.value = '';
    query.value = searchQuery.trim();

    try {
      // Arama geçmişine ekle
      _addToSearchHistory(query.value);

      List<String> searchTypes;
      if (selectedFilter.value == 'all') {
        searchTypes = ['users', 'blogs', 'communities', 'events'];
      } else {
        searchTypes = [selectedFilter.value];
      }

      final results = await _searchService.globalSearch(
        query.value,
        types: searchTypes,
      );

      searchResults.value = results;
      userResults.value = results.users;
      blogResults.value = results.blogs;
      communityResults.value = results.communities;
      eventResults.value = results.events;
    } catch (e) {
      errorMessage.value = 'Arama işleminde hata oluştu';
      _errorHandler.handleError('Arama hatası: $e', 'SEARCH_ERROR');
    } finally {
      isLoading.value = false;
    }
  }

  // Filtre değiştirme
  void changeFilter(String filter) {
    selectedFilter.value = filter;
    if (query.value.isNotEmpty) {
      search(query.value);
    }
  }

  // Arama temizleme
  void clearSearch() {
    searchController.clear();
    query.value = '';
    searchResults.value = null;
    userResults.clear();
    blogResults.clear();
    communityResults.clear();
    eventResults.clear();
    errorMessage.value = '';
  }

  // Skill bazlı kullanıcı arama
  Future<void> searchUsersBySkills(List<String> skills) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final users = await _searchService.searchUsersBySkills(skills, 20);
      userResults.value = users;
      selectedFilter.value = 'users';
    } catch (e) {
      errorMessage.value = 'Skill arama işleminde hata oluştu';
      _errorHandler.handleError('Skill arama hatası: $e', 'SKILL_SEARCH_ERROR');
    } finally {
      isLoading.value = false;
    }
  }

  // Tag bazlı blog arama
  Future<void> searchBlogsByTags(List<String> tags) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final blogs = await _searchService.searchBlogsByTags(tags, 20);
      blogResults.value = blogs;
      selectedFilter.value = 'blogs';
    } catch (e) {
      errorMessage.value = 'Tag arama işleminde hata oluştu';
      _errorHandler.handleError('Tag arama hatası: $e', 'TAG_SEARCH_ERROR');
    } finally {
      isLoading.value = false;
    }
  }

  // Yakın etkinlik arama
  Future<void> searchNearbyEvents(double lat, double lng, double radius) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final events = await _searchService.searchNearbyEvents(
        lat,
        lng,
        radius,
        20,
      );
      eventResults.value = events;
      selectedFilter.value = 'events';
    } catch (e) {
      errorMessage.value = 'Yakın etkinlik arama işleminde hata oluştu';
      _errorHandler.handleError(
        'Yakın etkinlik arama hatası: $e',
        'NEARBY_SEARCH_ERROR',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Arama geçmişine ekleme
  void _addToSearchHistory(String searchQuery) {
    if (searchQuery.isEmpty) return;

    searchHistory.remove(searchQuery); // Varsa çıkar
    searchHistory.insert(0, searchQuery); // Başa ekle

    // Maksimum 10 arama geçmişi tut
    if (searchHistory.length > 10) {
      searchHistory.removeLast();
    }

    _saveSearchHistory();
  }

  // Arama geçmişi yükleme
  void _loadSearchHistory() {
    // SharedPreferences'tan yükle
    // Şimdilik boş, gerçek implementasyon gerektiğinde eklenecek
    searchHistory.value = [];
  }

  // Arama geçmişi kaydetme
  void _saveSearchHistory() {
    // SharedPreferences'a kaydet
    // Şimdilik boş, gerçek implementasyon gerektiğinde eklenecek
  }

  // Popüler aramalar yükleme
  void _loadPopularSearches() {
    // Veritabanından popüler aramaları yükle
    popularSearches.value = [
      'Flutter',
      'React',
      'Python',
      'JavaScript',
      'Mobile Development',
      'Web Development',
      'AI/ML',
      'Backend',
    ];
  }

  // Arama geçmişi temizleme
  void clearSearchHistory() {
    searchHistory.clear();
    _saveSearchHistory();
  }

  // Arama geçmişinden arama yapma
  void searchFromHistory(String searchQuery) {
    searchController.text = searchQuery;
    search(searchQuery);
  }

  // Popüler aramadan arama yapma
  void searchFromPopular(String searchQuery) {
    searchController.text = searchQuery;
    search(searchQuery);
  }

  // Sonuç sayısı getter'ları
  int get totalResults => searchResults.value?.totalResults ?? 0;
  int get userResultCount => userResults.length;
  int get blogResultCount => blogResults.length;
  int get communityResultCount => communityResults.length;
  int get eventResultCount => eventResults.length;

  bool get hasResults => totalResults > 0;
  bool get hasUserResults => userResults.isNotEmpty;
  bool get hasBlogResults => blogResults.isNotEmpty;
  bool get hasCommunityResults => communityResults.isNotEmpty;
  bool get hasEventResults => eventResults.isNotEmpty;
}
