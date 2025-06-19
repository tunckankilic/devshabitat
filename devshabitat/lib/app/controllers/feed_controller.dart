import 'package:devshabitat/app/core/services/error_handler_service.dart';
import 'package:get/get.dart';
import '../models/feed_item.dart';
import '../services/feed_repository.dart';

class FeedController extends GetxController {
  final FeedRepository _repository;
  final ErrorHandlerService _errorHandler;

  FeedController({
    required FeedRepository repository,
    required ErrorHandlerService errorHandler,
  })  : _repository = repository,
        _errorHandler = errorHandler;

  final RxList<FeedItem> _feedItems = <FeedItem>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;
  final RxInt _currentPage = 1.obs;

  List<FeedItem> get feedItems => _feedItems;
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;

  @override
  void onInit() {
    super.onInit();
    refreshFeed();
  }

  Future<List<FeedItem>> fetchFeedItems(int page, int pageSize) async {
    try {
      final items = await _repository.getFeedItems(
        page: page,
        pageSize: pageSize,
      );
      return items;
    } catch (e) {
      _errorHandler.handleError(e);
      return [];
    }
  }

  Future<void> refreshFeed() async {
    _currentPage.value = 1;
    _feedItems.clear();
    try {
      final items = await fetchFeedItems(_currentPage.value, 10);
      _feedItems.addAll(items);
      _hasError.value = false;
    } catch (e) {
      _hasError.value = true;
      _errorHandler.handleError(e);
    }
  }

  Future<void> likeFeedItem(String itemId) async {
    try {
      await _repository.likeFeedItem(itemId);
      final index = _feedItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        final updatedItem = _feedItems[index].copyWith(
          likesCount: _feedItems[index].likesCount + 1,
          isLiked: true,
        );
        _feedItems[index] = updatedItem;
      }
    } catch (e) {
      _errorHandler.handleError(e);
    }
  }

  Future<void> commentOnFeedItem(String itemId) async {
    try {
      // Yorum yapma işlemi
      Get.toNamed('/comments', arguments: itemId);
    } catch (e) {
      _errorHandler.handleError(e);
    }
  }

  Future<void> shareFeedItem(String itemId) async {
    try {
      await _repository.shareFeedItem(itemId);
      final index = _feedItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        final updatedItem = _feedItems[index].copyWith(
          sharesCount: _feedItems[index].sharesCount + 1,
        );
        _feedItems[index] = updatedItem;
      }
    } catch (e) {
      _errorHandler.handleError(e);
    }
  }
}
