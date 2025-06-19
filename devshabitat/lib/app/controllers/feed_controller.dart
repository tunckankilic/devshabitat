import 'package:get/get.dart';
import '../services/feed_service.dart';
import '../models/post.dart';

enum FeedType { forYou, popular }

class FeedController extends GetxController {
  final FeedService _feedService;

  final RxList<Post> forYouPosts = <Post>[].obs;
  final RxList<Post> popularPosts = <Post>[].obs;
  final Rx<FeedType> currentFeedType = FeedType.forYou.obs;
  final RxBool isLoading = false.obs;
  final RxString selectedTag = ''.obs;

  FeedController({
    required FeedService feedService,
  }) : _feedService = feedService;

  @override
  void onInit() {
    super.onInit();
    _subscribeToPosts();
  }

  void _subscribeToPosts() {
    // For You feed'ini dinle (kendi ve bağlantıların)
    _feedService.getForYouFeedStream().listen(
      (updatedPosts) {
        forYouPosts.value = updatedPosts;
      },
      onError: (error) {
        // Hata durumunda işlem yap
      },
    );

    // Popular feed'i dinle (tüm kullanıcılardan en popüler olanlar)
    _feedService.getPopularFeedStream().listen(
      (updatedPosts) {
        popularPosts.value = updatedPosts;
      },
      onError: (error) {
        // Hata durumunda işlem yap
      },
    );
  }

  // Feed tipini değiştir
  void changeFeedType(FeedType type) {
    currentFeedType.value = type;
  }

  // Aktif feed'deki postları getir
  List<Post> get currentPosts {
    return currentFeedType.value == FeedType.forYou
        ? forYouPosts
        : popularPosts;
  }

  // Feed'i yenile
  Future<void> refreshPosts() async {
    isLoading.value = true;
    try {
      if (selectedTag.isNotEmpty) {
        final tagPosts =
            await _feedService.getTagFeedStream(selectedTag.value).first;
        forYouPosts.value = tagPosts;
      } else if (currentFeedType.value == FeedType.forYou) {
        final posts = await _feedService.getForYouFeedStream().first;
        forYouPosts.value = posts;
      } else {
        final posts = await _feedService.getPopularFeedStream().first;
        popularPosts.value = posts;
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Etiket seç
  void selectTag(String tag) {
    if (selectedTag.value == tag) {
      selectedTag.value = '';
      _subscribeToPosts(); // Normal feed'e geri dön
    } else {
      selectedTag.value = tag;
      _feedService.getTagFeedStream(tag).listen(
        (tagPosts) {
          // Etiket seçiliyken For You feed'ini güncelle
          forYouPosts.value = tagPosts;
        },
        onError: (error) {
          // Hata durumunda işlem yap
        },
      );
    }
  }

  // Profil feed'ini getir
  Stream<List<Post>> getProfilePosts(String userId) {
    return _feedService.getProfileFeedStream(userId);
  }
}
