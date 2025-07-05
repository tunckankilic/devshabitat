import 'package:get/get.dart';
import 'package:logger/logger.dart';

mixin PaginationMixin {
  final Logger _logger = Logger();
  final RxBool isLoading = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxInt currentPage = 1.obs;
  final int defaultPageSize = 20;

  // Sayfalama durumunu sıfırla
  void resetPagination() {
    currentPage.value = 1;
    hasMoreData.value = true;
    isLoading.value = false;
  }

  // Sonraki sayfayı yükle
  Future<List<T>> loadNextPage<T>({
    required Future<List<T>> Function(int page, int pageSize) fetchData,
    int? pageSize,
    bool showLoading = true,
  }) async {
    if (isLoading.value || !hasMoreData.value) {
      return [];
    }

    try {
      isLoading.value = showLoading;
      final items = await fetchData(
        currentPage.value,
        pageSize ?? defaultPageSize,
      );

      // Son sayfa kontrolü
      if (items.isEmpty || items.length < (pageSize ?? defaultPageSize)) {
        hasMoreData.value = false;
      } else {
        currentPage.value++;
      }

      return items;
    } catch (e) {
      _logger.e('Error loading next page: $e');
      hasMoreData.value = false;
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // Belirli bir sayfayı yükle
  Future<List<T>> loadPage<T>({
    required Future<List<T>> Function(int page, int pageSize) fetchData,
    required int page,
    int? pageSize,
    bool showLoading = true,
  }) async {
    if (isLoading.value) {
      return [];
    }

    try {
      isLoading.value = showLoading;
      final items = await fetchData(page, pageSize ?? defaultPageSize);

      // Sayfa durumunu güncelle
      currentPage.value = page;
      hasMoreData.value = items.length >= (pageSize ?? defaultPageSize);

      return items;
    } catch (e) {
      _logger.e('Error loading page $page: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // Yenile
  Future<List<T>> refresh<T>({
    required Future<List<T>> Function(int page, int pageSize) fetchData,
    int? pageSize,
    bool showLoading = true,
  }) async {
    resetPagination();
    return await loadPage(
      fetchData: fetchData,
      page: 1,
      pageSize: pageSize,
      showLoading: showLoading,
    );
  }
}
