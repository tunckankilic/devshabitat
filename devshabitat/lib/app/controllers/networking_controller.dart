import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/network_stats_model.dart';
import '../models/user_profile_model.dart';
import '../services/network_analytics_service.dart';
import '../core/services/api_optimization_service.dart';
import 'package:flutter/material.dart'; // Added for Get.snackbar

class NetworkingController extends GetxController {
  // Servisler
  final NetworkAnalyticsService _analyticsService =
      Get.find<NetworkAnalyticsService>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final ApiOptimizationService _apiOptimizer =
      Get.find<ApiOptimizationService>();
  final Logger _logger = Get.find<Logger>();

  // Observable State
  final RxList<UserProfile> connections = <UserProfile>[].obs;
  final Rx<NetworkStatsModel> networkStats = NetworkStatsModel.empty().obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Filtreleme ve Sıralama State
  final RxString searchQuery = ''.obs;
  final RxString sortBy = 'name'.obs;
  final RxBool isAscending = true.obs;

  // Pagination State
  final RxInt currentPage = 1.obs;
  final int pageSize = 20;
  final RxBool hasMoreData = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadNetworkData();
  }

  // Ana veri yükleme metodu
  Future<void> loadNetworkData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Kullanıcı ID'sini al
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Kullanıcı oturum açmamış');
      }

      // Batch API çağrıları ile optimize edilmiş veri yükleme
      final results = await _apiOptimizer.batchApiCalls(
        calls: {
          'connections': () => _loadConnections(),
          'networkStats': () => _loadNetworkStats(currentUser.uid),
        },
        cacheDuration: const Duration(minutes: 5),
      );

      // Sonuçları işle
      if (results.containsKey('connections')) {
        connections.value = results['connections'] as List<UserProfile>;
      }
      if (results.containsKey('networkStats')) {
        networkStats.value = results['networkStats'] as NetworkStatsModel;
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Veriler yüklenirken hata oluştu: $e';
      _logger.e('Network verisi yüklenirken hata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Bağlantıları yükle
  Future<void> _loadConnections() async {
    try {
      final userConnections = await _authRepository.getUserConnections();
      final connectionProfiles = <UserProfile>[];

      for (final userId in userConnections) {
        try {
          final profile = await _authRepository.getUserProfile(userId);
          connectionProfiles.add(profile as UserProfile);
        } catch (e) {
          _logger.w('Bağlantı profili yüklenemedi: $userId, Hata: $e');
        }
      }

      connections.value = connectionProfiles;
    } catch (e) {
      _logger.e('Bağlantılar yüklenirken hata: $e');
      rethrow;
    }
  }

  // Network istatistiklerini yükle
  Future<void> _loadNetworkStats(String userId) async {
    try {
      final stats = await _analyticsService.calculateNetworkStats(userId);
      networkStats.value = NetworkStatsModel(
        totalConnections: stats.totalConnections,
        weeklyGrowth: stats.networkGrowthRate,
        acceptanceRate: stats.connectionSuccessRate,
        topSkills: stats.topSkills,
        lastUpdated: DateTime.now(),
        skillDistribution: stats.skillDistribution,
        growthTrends: {
          'daily': 0.0,
          'weekly': stats.networkGrowthRate,
          'monthly': 0.0,
        },
      );
    } catch (e) {
      _logger.e('Network istatistikleri yüklenirken hata: $e');
      rethrow;
    }
  }

  // Analytics verilerini yenile
  Future<void> refreshAnalytics() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      await _loadNetworkStats(currentUser.uid);
    } catch (e) {
      _logger.e('Analytics yenilenirken hata: $e');
    }
  }

  // Bağlantıları filtrele
  List<UserProfile> get filteredConnections {
    return connections.where((connection) {
      if (searchQuery.isEmpty) return true;

      final query = searchQuery.value.toLowerCase();
      final name = connection.fullName.toLowerCase();
      final title = connection.title?.toLowerCase() ?? '';
      final company = connection.company?.toLowerCase() ?? '';

      return name.contains(query) ||
          title.contains(query) ||
          company.contains(query);
    }).toList();
  }

  // Bağlantıları sırala
  void sortConnections(String field) {
    if (sortBy.value == field) {
      isAscending.toggle();
    } else {
      sortBy.value = field;
      isAscending.value = true;
    }

    connections.sort((a, b) {
      int compare;
      switch (field) {
        case 'name':
          compare = a.fullName.compareTo(b.fullName);
          break;
        case 'company':
          compare = (a.company ?? '').compareTo(b.company ?? '');
          break;
        case 'title':
          compare = (a.title ?? '').compareTo(b.title ?? '');
          break;
        case 'lastActive':
          compare = (a.lastActive ?? DateTime(1970))
              .compareTo(b.lastActive ?? DateTime(1970));
          break;
        default:
          compare = 0;
      }
      return isAscending.value ? compare : -compare;
    });
  }

  // Daha fazla bağlantı yükle (pagination)
  Future<void> loadMoreConnections() async {
    if (!hasMoreData.value || isLoading.value) return;

    try {
      isLoading.value = true;

      // Pagination mantığı burada implement edilecek
      // Şimdilik mock data
      await Future.delayed(const Duration(seconds: 1));
      currentPage.value++;

      // Son sayfaya gelindiyse
      if (currentPage.value > 5) {
        hasMoreData.value = false;
      }
    } catch (e) {
      _logger.e('Daha fazla bağlantı yüklenirken hata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Arama sorgusunu güncelle
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Bağlantı ekle
  Future<void> addConnection(String userId) async {
    try {
      await _authRepository.addConnection(userId);
      await loadNetworkData();
    } catch (e) {
      _logger.e('Bağlantı eklenirken hata: $e');
      rethrow;
    }
  }

  // Bağlantı kaldır
  Future<void> removeConnection(String userId) async {
    try {
      await _authRepository.removeConnection(userId);
      connections.removeWhere((connection) => connection.id == userId);
      await refreshAnalytics();
    } catch (e) {
      _logger.e('Bağlantı kaldırılırken hata: $e');
      rethrow;
    }
  }

  // Suggested connections state
  final RxList<UserProfile> suggestedConnections = <UserProfile>[].obs;
  final RxBool isLoadingSuggestions = false.obs;
  final RxString suggestionsError = ''.obs;
  final RxList<String> pendingRequests = <String>[].obs;

  // Load suggested connections
  Future<void> loadSuggestedConnections() async {
    try {
      isLoadingSuggestions.value = true;
      suggestionsError.value = '';

      // Mock data for now - in real app, this would be API call
      await Future.delayed(Duration(milliseconds: 500));

      final suggestions = [
        UserProfile(
          id: 'user1',
          fullName: 'Ahmet Yılmaz',
          email: 'ahmet@example.com',
          bio: 'Flutter Developer | 5 yıl deneyim',
          locationName: 'Istanbul, Turkey',
          skills: ['Flutter', 'Dart', 'Firebase'],
          interests: ['Mobile Development', 'UI/UX'],
          githubUsername: 'ahmetyilmaz',
          yearsOfExperience: 5,
        ),
        UserProfile(
          id: 'user2',
          fullName: 'Elif Özkan',
          email: 'elif@example.com',
          bio: 'Backend Developer | Node.js & Python',
          locationName: 'Ankara, Turkey',
          skills: ['Node.js', 'Python', 'MongoDB'],
          interests: ['Backend Development', 'API Design'],
          githubUsername: 'elifozkan',
          yearsOfExperience: 3,
        ),
        UserProfile(
          id: 'user3',
          fullName: 'Mehmet Demir',
          email: 'mehmet@example.com',
          bio: 'UI/UX Designer | Digital Product Design',
          locationName: 'Izmir, Turkey',
          skills: ['Figma', 'Sketch', 'Adobe XD'],
          interests: ['Design Systems', 'User Research'],
          githubUsername: 'mehmetdemir',
          yearsOfExperience: 4,
        ),
      ];

      suggestedConnections.value = suggestions;
      _logger.i('Suggested connections loaded: ${suggestions.length}');
    } catch (e) {
      suggestionsError.value =
          'Önerilen bağlantılar yüklenirken hata oluştu: $e';
      _logger.e('Load suggested connections error: $e');
    } finally {
      isLoadingSuggestions.value = false;
    }
  }

  // Send connection request
  Future<void> sendConnectionRequest(String userId) async {
    try {
      // Add to pending requests immediately for UI feedback
      pendingRequests.add(userId);

      // Mock API call - in real app, this would be actual request
      await Future.delayed(Duration(milliseconds: 300));

      Get.snackbar(
        'Bağlantı Talebi',
        'Bağlantı talebi başarıyla gönderildi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      _logger.i('Connection request sent to user: $userId');
    } catch (e) {
      // Remove from pending if failed
      pendingRequests.remove(userId);

      Get.snackbar(
        'Hata',
        'Bağlantı talebi gönderilirken hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      _logger.e('Send connection request error: $e');
      rethrow;
    }
  }

  // Check if connection request is pending
  bool isRequestPending(String userId) {
    return pendingRequests.contains(userId);
  }

  // Search suggested connections
  List<UserProfile> get filteredSuggestedConnections {
    if (searchQuery.value.isEmpty) {
      return suggestedConnections.toList();
    }

    final query = searchQuery.value.toLowerCase();
    return suggestedConnections.where((user) {
      return user.fullName.toLowerCase().contains(query) ||
          (user.bio?.toLowerCase().contains(query) ?? false) ||
          user.skills.any((skill) => skill.toLowerCase().contains(query)) ||
          (user.locationName?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  // Refresh suggested connections
  Future<void> refreshSuggestedConnections() async {
    suggestedConnections.clear();
    await loadSuggestedConnections();
  }

  // Controller dispose edildiğinde
  @override
  void onClose() {
    searchQuery.close();
    sortBy.close();
    isAscending.close();
    currentPage.close();
    hasMoreData.close();
    super.onClose();
  }
}
