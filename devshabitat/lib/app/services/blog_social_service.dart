import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/blog_interaction_model.dart';
import '../repositories/auth_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';

class BlogSocialService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // Koleksiyon referansları
  late final CollectionReference _interactionsCollection;
  late final CollectionReference _commentsCollection;
  late final CollectionReference _seriesCollection;
  late final CollectionReference _readingListsCollection;
  late final CollectionReference _followersCollection;

  @override
  void onInit() {
    super.onInit();
    _interactionsCollection = _firestore.collection('blog_interactions');
    _commentsCollection = _firestore.collection('blog_comments');
    _seriesCollection = _firestore.collection('blog_series');
    _readingListsCollection = _firestore.collection('reading_lists');
    _followersCollection = _firestore.collection('followers');
  }

  // Blog beğenme/beğenmeme
  Future<void> toggleBlogReaction(String blogId, String type) async {
    final authRepo = Get.find<AuthRepository>();
    final userId = authRepo.currentUser?.uid;

    if (userId == null) {
      throw Exception('Kullanıcı oturum açmamış');
    }

    final query = await _interactionsCollection
        .where('blogId', isEqualTo: blogId)
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: type)
        .get();

    if (query.docs.isEmpty) {
      final interaction = BlogInteractionModel(
        id: _uuid.v4(),
        blogId: blogId,
        userId: userId,
        type: type,
        createdAt: DateTime.now(),
      );

      await _interactionsCollection
          .doc(interaction.id)
          .set(interaction.toMap());
    } else {
      await _interactionsCollection.doc(query.docs.first.id).delete();
    }
  }

  // Yorum ekleme
  Future<BlogCommentModel> addComment({
    required String blogId,
    required String content,
    String? parentCommentId,
  }) async {
    final authRepo = Get.find<AuthRepository>();
    final userId = authRepo.currentUser?.uid;
    final userName = authRepo.currentUser?.displayName;
    final userPhoto = authRepo.currentUser?.photoURL;

    if (userId == null) {
      throw Exception('Kullanıcı oturum açmamış');
    }

    final comment = BlogCommentModel(
      id: _uuid.v4(),
      blogId: blogId,
      userId: userId,
      userName: userName ?? 'Anonim',
      userPhotoUrl: userPhoto,
      content: content,
      parentCommentId: parentCommentId,
      createdAt: DateTime.now(),
    );

    await _commentsCollection.doc(comment.id).set(comment.toMap());

    if (parentCommentId != null) {
      await _commentsCollection.doc(parentCommentId).update({
        'replies': FieldValue.arrayUnion([comment.id]),
      });
    }

    return comment;
  }

  // Blog paylaşma
  Future<void> shareBlog(String blogId, String title, String url) async {
    await Share.share(
      'Şu blogu okumanı öneririm: $title\n$url',
      subject: title,
    );
  }

  // Yazar takip etme
  Future<void> toggleFollowAuthor(String authorId) async {
    final authRepo = Get.find<AuthRepository>();
    final userId = authRepo.currentUser?.uid;

    if (userId == null) {
      throw Exception('Kullanıcı oturum açmamış');
    }

    final followDoc = _followersCollection.doc('${authorId}_$userId');
    final doc = await followDoc.get();

    if (!doc.exists) {
      await followDoc.set({
        'authorId': authorId,
        'followerId': userId,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });
    } else {
      await followDoc.delete();
    }
  }

  // Blog serisi oluşturma
  Future<BlogSeriesModel> createBlogSeries({
    required String title,
    required String description,
    required List<String> blogIds,
    required String coverImageUrl,
  }) async {
    final authRepo = Get.find<AuthRepository>();
    final userId = authRepo.currentUser?.uid;

    if (userId == null) {
      throw Exception('Kullanıcı oturum açmamış');
    }

    final now = DateTime.now();
    final series = BlogSeriesModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      authorId: userId,
      blogIds: blogIds,
      createdAt: now,
      updatedAt: now,
      coverImageUrl: coverImageUrl,
    );

    await _seriesCollection.doc(series.id).set(series.toMap());
    return series;
  }

  // Okuma listesi oluşturma
  Future<UserReadingListModel> createReadingList({
    required String title,
    String? description,
    bool isPublic = false,
  }) async {
    final authRepo = Get.find<AuthRepository>();
    final userId = authRepo.currentUser?.uid;

    if (userId == null) {
      throw Exception('Kullanıcı oturum açmamış');
    }

    final now = DateTime.now();
    final readingList = UserReadingListModel(
      id: _uuid.v4(),
      userId: userId,
      title: title,
      description: description,
      blogIds: [],
      isPublic: isPublic,
      createdAt: now,
      updatedAt: now,
    );

    await _readingListsCollection.doc(readingList.id).set(readingList.toMap());
    return readingList;
  }

  // Okuma listesine blog ekleme/çıkarma
  Future<void> toggleBlogInReadingList(
    String readingListId,
    String blogId,
  ) async {
    final doc = await _readingListsCollection.doc(readingListId).get();

    if (!doc.exists) {
      throw Exception('Okuma listesi bulunamadı');
    }

    final currentBlogIds = List<String>.from(
      (doc.data() as Map<String, dynamic>)['blogIds'] ?? [],
    );

    if (currentBlogIds.contains(blogId)) {
      currentBlogIds.remove(blogId);
    } else {
      currentBlogIds.add(blogId);
    }

    await _readingListsCollection.doc(readingListId).update({
      'blogIds': currentBlogIds,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Blog önerileri alma
  Future<List<String>> getRecommendedBlogs(String userId) async {
    // Kullanıcının etkileşimde bulunduğu blogları al
    final interactions = await _interactionsCollection
        .where('userId', isEqualTo: userId)
        .get();

    final interactedBlogIds = interactions.docs
        .map((doc) => doc['blogId'] as String)
        .toList();

    // Etkileşimde bulunulan blogların kategorilerini al
    final blogs = await _firestore
        .collection('blogs')
        .where(FieldPath.documentId, whereIn: interactedBlogIds)
        .get();

    final categories = blogs.docs
        .map((doc) => doc['category'] as String)
        .toSet()
        .toList();

    // Benzer kategorilerdeki diğer blogları öner
    final recommendations = await _firestore
        .collection('blogs')
        .where('category', whereIn: categories)
        .where(FieldPath.documentId, whereNotIn: interactedBlogIds)
        .orderBy('viewCount', descending: true)
        .limit(10)
        .get();

    return recommendations.docs.map((doc) => doc.id).toList();
  }

  // Öne çıkan blogları güncelleme
  Future<void> updateFeaturedStatus(String blogId, bool isFeatured) async {
    await _firestore.collection('blogs').doc(blogId).update({
      'isFeatured': isFeatured,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Okuma süresi takibi
  Future<void> trackReadingTime(String blogId, Duration readingTime) async {
    final authRepo = Get.find<AuthRepository>();
    final userId = authRepo.currentUser?.uid;

    if (userId == null) return;

    await _firestore.collection('reading_stats').add({
      'blogId': blogId,
      'userId': userId,
      'readingTime': readingTime.inSeconds,
      'timestamp': Timestamp.fromDate(DateTime.now()),
    });
  }
}
