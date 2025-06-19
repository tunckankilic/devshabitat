import 'package:get/get.dart';
import 'package:flutter/material.dart';

class LazyLoadingService extends GetxService {
  static const int defaultPageSize = 10;
  static const double defaultThreshold = 200.0;

  /// Generic lazy loading fonksiyonu
  Future<List<T>> loadData<T>({
    required Future<List<T>> Function(int page, int pageSize) fetcher,
    required RxList<T> dataList,
    required RxBool isLoading,
    required RxBool hasMore,
    int page = 1,
    int pageSize = defaultPageSize,
  }) async {
    if (isLoading.value || !hasMore.value) return dataList;

    try {
      isLoading.value = true;
      final newItems = await fetcher(page, pageSize);

      if (newItems.isEmpty) {
        hasMore.value = false;
      } else {
        dataList.addAll(newItems);
      }

      return dataList;
    } catch (e) {
      hasMore.value = false;
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// ScrollController için lazy loading listener
  ScrollController createLazyScrollController({
    required Function() onLoadMore,
    double threshold = defaultThreshold,
  }) {
    final controller = ScrollController();

    controller.addListener(() {
      final maxScroll = controller.position.maxScrollExtent;
      final currentScroll = controller.position.pixels;

      if (maxScroll - currentScroll <= threshold) {
        onLoadMore();
      }
    });

    return controller;
  }
}
