import 'package:devshabitat/app/repositories/auth_repository.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/network_stats_model.dart';
import '../models/user_profile_model.dart';
import '../services/network_analytics_service.dart';
import '../core/services/api_optimization_service.dart';

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
