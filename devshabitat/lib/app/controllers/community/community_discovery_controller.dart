import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devshabitat/app/models/community/community_model.dart';
import 'package:devshabitat/app/services/community/community_service.dart';
import 'package:devshabitat/app/services/community/membership_service.dart';
import 'package:devshabitat/app/services/auth_service.dart';

class CommunityDiscoveryController extends GetxController {
  final CommunityService _communityService = Get.find<CommunityService>();
  final MembershipService _membershipService = MembershipService();
  final AuthService _authService = Get.find<AuthService>();

  final communities = <CommunityModel>[].obs;
  final trendingCommunities = <CommunityModel>[].obs;
  final userCommunities = <CommunityModel>[].obs;
  final selectedType = Rx<CommunityType?>(null);
  final selectedCategory = Rx<CommunityCategory?>(null);
  final searchTerm = ''.obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  DocumentSnapshot? _lastDocument;
  bool _hasMoreData = true;

  // Filtre durumları
  final searchQuery = ''.obs;
  final selectedCategories = <String>[].obs;
  final selectedSortOption = 'newest'.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  // Load initial data
  Future<void> loadInitialData() async {
    await Future.wait([
      loadTrendingCommunities(),
      loadUserCommunities(),
      loadCommunities(),
    ]);
  }

  // Load communities with filters
  Future<void> loadCommunities({bool refresh = false}) async {
    if (!_hasMoreData && !refresh) return;

    try {
      isLoading.value = true;
      hasError.value = false;

      if (refresh) {
        communities.clear();
        _lastDocument = null;
        _hasMoreData = true;
      }

      final results = await _communityService.getCommunities(
        type: selectedType.value,
        category: selectedCategory.value,
        startAfter: _lastDocument,
      );

      if (results.isEmpty) {
        _hasMoreData = false;
      } else {
        _lastDocument = results.last as DocumentSnapshot?;
        communities.addAll(results);
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Load trending communities
  Future<void> loadTrendingCommunities() async {
    try {
      final results = await _communityService.getTrendingCommunities();
      trendingCommunities.value = results;
    } catch (e) {
      print('Error loading trending communities: $e');
    }
  }

  // Load user's communities
  Future<void> loadUserCommunities() async {
    try {
      final userId = Get.find<String>();
      final communityIds = await _membershipService.getUserCommunities(
        userId: userId,
      );

      final communities = await Future.wait(
        communityIds.map((id) => _communityService.getCommunity(id)),
      );

      userCommunities.value = communities.whereType<CommunityModel>().toList();
    } catch (e) {
      print('Error loading user communities: $e');
    }
  }

  // Search communities
  Future<void> searchCommunities(String term) async {
    if (term.isEmpty) {
      await loadCommunities(refresh: true);
      return;
    }

    try {
      isLoading.value = true;
      hasError.value = false;

      final results = await _communityService.searchCommunities(term);
      communities.value = results;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Update filters
  void updateType(CommunityType? type) {
    selectedType.value = type;
    loadCommunities(refresh: true);
  }

  void updateCategory(CommunityCategory? category) {
    selectedCategory.value = category;
    loadCommunities(refresh: true);
  }

  // Load more data (pagination)
  Future<void> loadMore() async {
    if (!isLoading.value && _hasMoreData) {
      await loadCommunities();
    }
  }

  // Reset filters
  void resetFilters() {
    selectedType.value = null;
    selectedCategory.value = null;
    loadCommunities(refresh: true);
  }

  Future<void> refreshCommunities() async {
    await loadCommunities();
  }

  void showFilters() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtreler',
              style: Get.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Sıralama seçenekleri
            DropdownButtonFormField<String>(
              value: selectedSortOption.value,
              decoration: const InputDecoration(
                labelText: 'Sıralama',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'newest',
                  child: Text('En Yeni'),
                ),
                DropdownMenuItem(
                  value: 'popular',
                  child: Text('En Popüler'),
                ),
                DropdownMenuItem(
                  value: 'active',
                  child: Text('En Aktif'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  selectedSortOption.value = value;
                  loadCommunities();
                }
              },
            ),
            const SizedBox(height: 16),
            // Kategori seçimi
            Wrap(
              spacing: 8,
              children: _communityService.getCategories().map((category) {
                return FilterChip(
                  label: Text(category),
                  selected: selectedCategories.contains(category),
                  onSelected: (selected) {
                    if (selected) {
                      selectedCategories.add(category);
                    } else {
                      selectedCategories.remove(category);
                    }
                    loadCommunities();
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void showSearch() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) {
                searchQuery.value = value;
                loadCommunities();
              },
              decoration: const InputDecoration(
                labelText: 'Topluluk Ara',
                hintText: 'Topluluk adı veya açıklaması...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isUserModerator(CommunityModel community) {
    final currentUser = _authService.currentUser.value;
    if (currentUser == null) return false;
    return community.isModerator(currentUser.uid);
  }
}
