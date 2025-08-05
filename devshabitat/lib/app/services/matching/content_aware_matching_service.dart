import 'dart:math' show max;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/blog_model.dart';
import '../../models/user_profile_model.dart';
import '../github_service.dart';

class ContentAwareMatchingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GithubService _githubService;

  ContentAwareMatchingService(this._githubService);

  // İçerik tabanlı geliştirici eşleştirme skoru hesaplama
  Future<double> calculateContentMatchScore(
    UserProfile developer1,
    UserProfile developer2,
  ) async {
    double score = 0.0;

    // Blog içeriği benzerliği
    final blogs1 = await getUserBlogs(developer1.id);
    final blogs2 = await getUserBlogs(developer2.id);

    // Blog kategorileri ve etiketleri karşılaştırma
    final categories1 = blogs1.map((b) => b.category).toSet();
    final categories2 = blogs2.map((b) => b.category).toSet();
    final commonCategories = categories1.intersection(categories2);

    final tags1 = blogs1.expand((b) => b.tags).toSet();
    final tags2 = blogs2.expand((b) => b.tags).toSet();
    final commonTags = tags1.intersection(tags2);

    // Kategori ve etiket benzerlik skoru (30%)
    score +=
        (commonCategories.length / (categories1.length + categories2.length)) *
        0.15;
    score += (commonTags.length / (tags1.length + tags2.length)) * 0.15;

    // GitHub projeleri benzerliği (40%)
    final repos1 = await _githubService.getUserRepos(
      developer1.githubUsername!,
    );
    final repos2 = await _githubService.getUserRepos(
      developer2.githubUsername!,
    );

    final topics1 = repos1
        .expand((r) => (r['topics'] as List? ?? []).cast<String>())
        .toSet();
    final topics2 = repos2
        .expand((r) => (r['topics'] as List? ?? []).cast<String>())
        .toSet();
    final commonTopics = topics1.intersection(topics2);

    score += (commonTopics.length / (topics1.length + topics2.length)) * 0.4;

    // İçerik etkileşim benzerliği (30%)
    final interactionScore = await calculateInteractionSimilarity(
      developer1.id,
      developer2.id,
    );
    score += interactionScore * 0.3;

    return score.clamp(0.0, 1.0);
  }

  // Kullanıcının bloglarını getirme
  Future<List<BlogModel>> getUserBlogs(String userId) async {
    final snapshot = await _firestore
        .collection('blogs')
        .where('authorId', isEqualTo: userId)
        .where('isPublished', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) => BlogModel.fromDocument(doc)).toList();
  }

  // İçerik etkileşim benzerliği hesaplama
  Future<double> calculateInteractionSimilarity(
    String userId1,
    String userId2,
  ) async {
    // Her iki kullanıcının da etkileşimde bulunduğu içerikleri bul
    final interactions1 = await getUserInteractions(userId1);
    final interactions2 = await getUserInteractions(userId2);

    // Ortak etkileşimde bulunulan içerik sayısı
    final commonInteractions = interactions1.keys.toSet().intersection(
      interactions2.keys.toSet(),
    );

    if (commonInteractions.isEmpty) return 0.0;

    // Etkileşim benzerliği hesaplama
    double similaritySum = 0.0;
    for (final contentId in commonInteractions) {
      final score1 = interactions1[contentId]!;
      final score2 = interactions2[contentId]!;
      similaritySum +=
          1 - ((score1 - score2).abs() / 5.0); // 5.0 maksimum skor farkı
    }

    return similaritySum / commonInteractions.length;
  }

  // Kullanıcının içerik etkileşimlerini getirme
  Future<Map<String, double>> getUserInteractions(String userId) async {
    final snapshot = await _firestore
        .collection('user_interactions')
        .where('userId', isEqualTo: userId)
        .get();

    final interactions = <String, double>{};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final contentId = data['contentId'] as String;
      double score = 0.0;

      // Like, yorum ve görüntüleme etkileşimlerini puanla
      if (data['liked'] == true) score += 2.0;
      if (data['commented'] == true) score += 2.0;
      if (data['viewed'] == true) score += 1.0;

      interactions[contentId] = score;
    }

    return interactions;
  }

  // İçerik tabanlı geliştirici önerileri
  Future<List<UserProfile>> getSimilarContentCreators(
    String userId, {
    int limit = 10,
  }) async {
    final userProfile = await getUserProfile(userId);
    if (userProfile == null) return [];

    final allDevelopers = await getAllDevelopers();
    final scoredDevelopers = await Future.wait(
      allDevelopers.where((dev) => dev.id != userId).map((dev) async {
        final score = await calculateContentMatchScore(userProfile, dev);
        return MapEntry(dev, score);
      }),
    );

    // Skora göre sırala ve en iyi eşleşmeleri döndür
    scoredDevelopers.sort((a, b) => b.value.compareTo(a.value));
    return scoredDevelopers.take(limit).map((e) => e.key).toList();
  }

  // Kullanıcı profilini getirme
  Future<UserProfile?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return UserProfile.fromDocument(doc);
  }

  // Tüm geliştiricileri getirme
  Future<List<UserProfile>> getAllDevelopers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => UserProfile.fromDocument(doc)).toList();
  }

  // İçerik işbirliği önerileri
  Future<List<Map<String, dynamic>>> suggestContentCollaborations(
    String userId,
  ) async {
    final userProfile = await getUserProfile(userId);
    if (userProfile == null) return [];

    final userBlogs = await getUserBlogs(userId);
    final userRepos = await _githubService.getUserRepos(
      userProfile.githubUsername!,
    );

    final suggestions = <Map<String, dynamic>>[];

    // Blog tabanlı işbirliği önerileri
    for (final blog in userBlogs) {
      final similarBlogs = await findSimilarBlogs(blog);
      for (final similarBlog in similarBlogs) {
        if (similarBlog.authorId == userId) continue;

        suggestions.add({
          'type': 'blog',
          'title': 'Blog İşbirliği Önerisi',
          'description':
              '${similarBlog.authorName} ile "${blog.title}" konusunda ortak bir blog yazısı yazabilirsiniz.',
          'matchedBlog': similarBlog.toJson(),
          'score': await calculateBlogSimilarity(blog, similarBlog),
        });
      }
    }

    // GitHub projesi tabanlı işbirliği önerileri
    for (final repo in userRepos) {
      final similarRepos = await _githubService.getUserRepos(
        repo['owner']['login'] as String,
      );
      for (final similarRepo in similarRepos) {
        if (similarRepo['owner'] == userProfile.githubUsername) continue;

        suggestions.add({
          'type': 'github',
          'title': 'Proje İşbirliği Önerisi',
          'description':
              '${similarRepo['owner']} ile "${repo['name']}" projesine benzer bir projede işbirliği yapabilirsiniz.',
          'matchedRepo': similarRepo,
          'score': await calculateRepoSimilarity(repo, similarRepo),
        });
      }
    }

    // Skorlara göre sırala
    suggestions.sort((a, b) => b['score'].compareTo(a['score']));
    return suggestions.take(5).toList();
  }

  // Benzer blogları bulma
  Future<List<BlogModel>> findSimilarBlogs(BlogModel blog) async {
    final snapshot = await _firestore
        .collection('blogs')
        .where('category', isEqualTo: blog.category)
        .where('isPublished', isEqualTo: true)
        .where('authorId', isNotEqualTo: blog.authorId)
        .get();

    final blogs = snapshot.docs
        .map((doc) => BlogModel.fromDocument(doc))
        .toList();

    // Etiket benzerliğine göre filtrele
    blogs.sort((a, b) {
      final tagsA = a.tags.toSet();
      final tagsB = b.tags.toSet();
      final blogTags = blog.tags.toSet();

      final commonTagsA = tagsA.intersection(blogTags).length;
      final commonTagsB = tagsB.intersection(blogTags).length;

      return commonTagsB.compareTo(commonTagsA);
    });

    return blogs.take(5).toList();
  }

  // Blog benzerlik skoru hesaplama
  Future<double> calculateBlogSimilarity(
    BlogModel blog1,
    BlogModel blog2,
  ) async {
    double score = 0.0;

    // Kategori eşleşmesi
    if (blog1.category == blog2.category) score += 0.3;

    // Etiket benzerliği
    final tags1 = blog1.tags.toSet();
    final tags2 = blog2.tags.toSet();
    final commonTags = tags1.intersection(tags2);
    score += (commonTags.length / (tags1.length + tags2.length)) * 0.4;

    // İçerik etkileşimi benzerliği
    final interactions1 = await getBlogInteractions(blog1.id);
    final interactions2 = await getBlogInteractions(blog2.id);
    score += calculateInteractionScore(interactions1, interactions2) * 0.3;

    return score.clamp(0.0, 1.0);
  }

  // Blog etkileşimlerini getirme
  Future<Map<String, int>> getBlogInteractions(String blogId) async {
    final doc = await _firestore.collection('blog_analytics').doc(blogId).get();
    if (!doc.exists) return {};

    final data = doc.data()!;
    return {
      'views': data['viewCount'] ?? 0,
      'likes': data['likeCount'] ?? 0,
      'comments': data['commentCount'] ?? 0,
    };
  }

  // Etkileşim skoru hesaplama
  double calculateInteractionScore(
    Map<String, int> interactions1,
    Map<String, int> interactions2,
  ) {
    if (interactions1.isEmpty || interactions2.isEmpty) return 0.0;

    double score = 0.0;
    final metrics = ['views', 'likes', 'comments'];

    for (final metric in metrics) {
      final value1 = interactions1[metric] ?? 0;
      final value2 = interactions2[metric] ?? 0;
      final maxValue = [value1, value2].reduce((max));

      if (maxValue > 0) {
        score += 1 - ((value1 - value2).abs() / maxValue);
      }
    }

    return (score / metrics.length).clamp(0.0, 1.0);
  }

  // GitHub repo benzerlik skoru hesaplama
  Future<double> calculateRepoSimilarity(dynamic repo1, dynamic repo2) async {
    double score = 0.0;

    // Programlama dili eşleşmesi
    if (repo1['language'] == repo2['language']) score += 0.3;

    // Konu etiketleri benzerliği
    final topics1 = ((repo1['topics'] as List?) ?? []).cast<String>().toSet();
    final topics2 = ((repo2['topics'] as List?) ?? []).cast<String>().toSet();
    final commonTopics = topics1.intersection(topics2);
    score += (commonTopics.length / (topics1.length + topics2.length)) * 0.4;

    // Star ve fork benzerliği
    final stats1 = <String, int>{
      'stars': repo1['stargazers_count'] ?? 0,
      'forks': repo1['forks_count'] ?? 0,
    };
    final stats2 = <String, int>{
      'stars': repo2['stargazers_count'] ?? 0,
      'forks': repo2['forks_count'] ?? 0,
    };
    score += calculateInteractionScore(stats1, stats2) * 0.3;

    return score.clamp(0.0, 1.0);
  }
}
