import 'package:get/get.dart';
import '../services/connection_service.dart';
import '../models/connection_model.dart';
import '../core/services/error_handler_service.dart';

class NetworkingController extends GetxController {
  final ConnectionService _connectionService = Get.find();
  final ErrorHandlerService _errorHandler = Get.find();

  final RxList<ConnectionModel> connections = <ConnectionModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxList<String> selectedSkills = <String>[].obs;
  final RxInt maxDistance = 50.obs;
  final RxBool showOnlineOnly = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool showFilters = false.obs;

  // Available skills for filtering
  final List<String> availableSkills = [
    'Flutter',
    'Dart',
    'Firebase',
    'GetX',
    'UI/UX',
    'Mobile Development',
    'Web Development',
    'Backend Development',
    'Cloud Computing',
    'DevOps',
  ];

  @override
  void onInit() {
    super.onInit();
    loadConnections();
  }

  Future<void> loadConnections() async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final results = await _connectionService.getConnections(
        searchQuery: searchQuery.value,
        skills: selectedSkills,
        maxDistance: maxDistance.value,
        isOnline: showOnlineOnly.value ? true : null,
      );

      connections.value = results;
    } catch (e) {
      _errorHandler.handleError(e, 'loadConnections');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreConnections() async {
    if (isLoading.value || !hasMoreConnections) return;
    isLoading.value = true;

    try {
      final results = await _connectionService.loadMoreConnections(
        searchQuery: searchQuery.value,
        skills: selectedSkills,
        maxDistance: maxDistance.value,
        isOnline: showOnlineOnly.value ? true : null,
      );

      connections.addAll(results);
    } catch (e) {
      _errorHandler.handleError(e, 'loadMoreConnections');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshConnections() async {
    await _connectionService.resetPagination();
    await loadConnections();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    debounce(
      searchQuery,
      (_) => refreshConnections(),
      time: const Duration(milliseconds: 500),
    );
  }

  void updateSkills(List<String> skills) {
    selectedSkills.value = skills;
    refreshConnections();
  }

  void updateMaxDistance(int distance) {
    maxDistance.value = distance;
    refreshConnections();
  }

  void toggleOnlineOnly(bool value) {
    showOnlineOnly.value = value;
    refreshConnections();
  }

  void toggleFilters() {
    showFilters.toggle();
  }

  Future<void> removeConnection(String connectionId) async {
    try {
      isLoading.value = true;
      // Remove from local list first for immediate UI update
      connections.removeWhere((conn) => conn.id == connectionId);

      // Then remove from backend
      await _connectionService.removeConnection(connectionId);

      _errorHandler.showSuccess('Connection removed successfully');
    } catch (e) {
      _errorHandler.handleError(e, 'removeConnection');
      // Reload connections in case of error
      await loadConnections();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addConnection(String connectionId) async {
    try {
      isLoading.value = true;
      await _connectionService.addConnection(connectionId);
      await loadConnections();
      _errorHandler.showSuccess('Connection added successfully');
    } catch (e) {
      _errorHandler.handleError(e, 'addConnection');
    } finally {
      isLoading.value = false;
    }
  }

  bool get hasMoreConnections => _connectionService.hasMoreData;
}
