import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/lazy_loading_service.dart';

class PaginatedListView<T> extends StatefulWidget {
  final Future<List<T>> Function(int page, int pageSize) onFetch;
  final Widget Function(T item) itemBuilder;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final Widget? errorWidget;
  final int pageSize;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;

  const PaginatedListView({
    super.key,
    required this.onFetch,
    required this.itemBuilder,
    this.loadingWidget,
    this.emptyWidget,
    this.errorWidget,
    this.pageSize = LazyLoadingService.defaultPageSize,
    this.padding,
    this.physics,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final _lazyLoadingService = Get.find<LazyLoadingService>();
  final RxList<T> _items = <T>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasMore = true.obs;
  final RxBool _hasError = false.obs;
  late final ScrollController _scrollController;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _scrollController = _lazyLoadingService.createLazyScrollController(
      onLoadMore: _loadMore,
    );
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      await _lazyLoadingService.loadData<T>(
        fetcher: widget.onFetch,
        dataList: _items,
        isLoading: _isLoading,
        hasMore: _hasMore,
        page: _currentPage,
        pageSize: widget.pageSize,
      );
    } catch (e) {
      _hasError.value = true;
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading.value || !_hasMore.value) return;

    _currentPage++;
    try {
      await _lazyLoadingService.loadData<T>(
        fetcher: widget.onFetch,
        dataList: _items,
        isLoading: _isLoading,
        hasMore: _hasMore,
        page: _currentPage,
        pageSize: widget.pageSize,
      );
      _hasError.value = false;
    } catch (e) {
      _hasError.value = true;
      _currentPage--;
    }
  }

  Future<void> refresh() async {
    _currentPage = 1;
    _items.clear();
    _hasMore.value = true;
    _hasError.value = false;
    await _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_isLoading.value && _items.isEmpty) {
        return widget.loadingWidget ??
            const Center(child: CircularProgressIndicator());
      }

      if (_hasError.value && _items.isEmpty) {
        return widget.errorWidget ??
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Bir hata oluştu'),
                  ElevatedButton(
                    onPressed: refresh,
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
      }

      if (_items.isEmpty) {
        return widget.emptyWidget ??
            const Center(child: Text('Veri bulunamadı'));
      }

      return RefreshIndicator(
        onRefresh: refresh,
        child: ListView.builder(
          controller: _scrollController,
          padding: widget.padding,
          physics: widget.physics,
          itemCount: _items.length + (_hasMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _items.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return widget.itemBuilder(_items[index]);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
