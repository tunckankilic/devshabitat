import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/mixins/pagination_mixin.dart';

class LazyLoadingList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Future<void> Function() onLoadMore;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final Widget? errorWidget;
  final bool hasMore;
  final bool isLoading;
  final ScrollController? scrollController;
  final EdgeInsets? padding;
  final double loadMoreThreshold;

  const LazyLoadingList({
    Key? key,
    required this.items,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.hasMore,
    required this.isLoading,
    this.loadingWidget,
    this.emptyWidget,
    this.errorWidget,
    this.scrollController,
    this.padding,
    this.loadMoreThreshold = 200.0,
  }) : super(key: key);

  @override
  State<LazyLoadingList<T>> createState() => _LazyLoadingListState<T>();
}

class _LazyLoadingListState<T> extends State<LazyLoadingList<T>> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || !widget.hasMore || widget.isLoading) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final remainingScroll = maxScroll - currentScroll;

    if (remainingScroll <= widget.loadMoreThreshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    _isLoadingMore = true;
    await widget.onLoadMore();
    _isLoadingMore = false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      if (widget.isLoading) {
        return _buildLoadingWidget();
      }
      return widget.emptyWidget ??
          const Center(
            child: Text('Veri bulunamadı'),
          );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.items.length) {
          if (widget.isLoading) {
            return _buildLoadingWidget();
          }
          return const SizedBox.shrink();
        }

        return widget.itemBuilder(context, widget.items[index]);
      },
    );
  }

  Widget _buildLoadingWidget() {
    return widget.loadingWidget ??
        const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        );
  }
}

// GridView versiyonu
class LazyLoadingGrid<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Future<void> Function() onLoadMore;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final Widget? errorWidget;
  final bool hasMore;
  final bool isLoading;
  final ScrollController? scrollController;
  final EdgeInsets? padding;
  final double loadMoreThreshold;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  const LazyLoadingGrid({
    Key? key,
    required this.items,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.hasMore,
    required this.isLoading,
    required this.crossAxisCount,
    this.loadingWidget,
    this.emptyWidget,
    this.errorWidget,
    this.scrollController,
    this.padding,
    this.loadMoreThreshold = 200.0,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
  }) : super(key: key);

  @override
  State<LazyLoadingGrid<T>> createState() => _LazyLoadingGridState<T>();
}

class _LazyLoadingGridState<T> extends State<LazyLoadingGrid<T>> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || !widget.hasMore || widget.isLoading) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final remainingScroll = maxScroll - currentScroll;

    if (remainingScroll <= widget.loadMoreThreshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    _isLoadingMore = true;
    await widget.onLoadMore();
    _isLoadingMore = false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      if (widget.isLoading) {
        return _buildLoadingWidget();
      }
      return widget.emptyWidget ??
          const Center(
            child: Text('Veri bulunamadı'),
          );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: widget.padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.items.length) {
          if (widget.isLoading) {
            return _buildLoadingWidget();
          }
          return const SizedBox.shrink();
        }

        return widget.itemBuilder(context, widget.items[index]);
      },
    );
  }

  Widget _buildLoadingWidget() {
    return widget.loadingWidget ??
        const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        );
  }
}
