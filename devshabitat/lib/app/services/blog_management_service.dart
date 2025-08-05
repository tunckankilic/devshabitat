import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/blog_model.dart';
import '../models/blog_version_model.dart';
import '../models/blog_template_model.dart';
import '../models/blog_analytics_model.dart';
import '../repositories/auth_repository.dart';
import 'package:uuid/uuid.dart';

class BlogManagementService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();
  Timer? _autoSaveTimer;

  // Koleksiyon referansları
  late final CollectionReference _blogsCollection;
  late final CollectionReference _versionsCollection;
  late final CollectionReference _templatesCollection;
  late final CollectionReference _analyticsCollection;

  // Aktif düzenleme oturumları
  final Map<String, Set<String>> _activeSessions = {};

  @override
  void onInit() {
    super.onInit();
    _blogsCollection = _firestore.collection('blogs');
    _versionsCollection = _firestore.collection('blog_versions');
    _templatesCollection = _firestore.collection('blog_templates');
    _analyticsCollection = _firestore.collection('blog_analytics');
  }

  // Blog oluşturma
  Future<BlogModel> createBlog({
    required String title,
    required String description,
    required String category,
    required List<String> tags,
    String? templateId,
  }) async {
    final authRepo = Get.find<AuthRepository>();
    final userId = authRepo.currentUser?.uid;
    final userName = authRepo.currentUser?.displayName;
    final userEmail = authRepo.currentUser?.email;

    if (userId == null) {
      throw Exception('Kullanıcı oturum açmamış');
    }

    String content = '';
    if (templateId != null) {
      final template = await _templatesCollection.doc(templateId).get();
      if (template.exists) {
        content = (template.data() as Map<String, dynamic>)['content'] ?? '';
      }
    }

    final blog = BlogModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      summary: description.length > 150
          ? '${description.substring(0, 147)}...'
          : description,
      category: category,
      tags: tags,
      content: content,
      authorId: userId,
      authorName: userName ?? 'Anonim',
      authorEmail: userEmail ?? '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: 'draft',
      isPublished: false,
      publishDate: DateTime.now().toIso8601String(),
      viewCount: 0,
      estimatedReadingTime:
          '${(content.split(' ').length / 200).ceil()} dakika',
    );

    await _blogsCollection.doc(blog.id).set(blog.toMap());
    return blog;
  }

  // Otomatik kaydetme
  void startAutoSave(String blogId, String content) {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await saveDraft(blogId, content);
    });
  }

  void stopAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }

  // Taslak kaydetme
  Future<void> saveDraft(String blogId, String content) async {
    final authRepo = Get.find<AuthRepository>();
    final userId = authRepo.currentUser?.uid;
    final userName = authRepo.currentUser?.displayName;

    if (userId == null) {
      throw Exception('Kullanıcı oturum açmamış');
    }

    final version = BlogVersionModel(
      id: _uuid.v4(),
      blogId: blogId,
      content: content,
      editorId: userId,
      editorName: userName ?? 'Anonim',
      createdAt: DateTime.now(),
    );

    await _versionsCollection.doc(version.id).set(version.toMap());
    await _blogsCollection.doc(blogId).update({
      'content': content,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Blog yayınlama
  Future<void> publishBlog(String blogId, {DateTime? scheduledDate}) async {
    final now = DateTime.now();
    await _blogsCollection.doc(blogId).update({
      'status': 'published',
      'isPublished': true,
      'publishedAt': scheduledDate != null && scheduledDate.isAfter(now)
          ? Timestamp.fromDate(scheduledDate)
          : Timestamp.fromDate(now),
    });
  }

  // Blog analitiği başlatma/güncelleme
  Future<void> trackAnalytics(
    String blogId, {
    required String country,
    required String device,
    required String referrer,
    required double readTime,
  }) async {
    final doc = await _analyticsCollection.doc(blogId).get();

    if (!doc.exists) {
      final analytics = BlogAnalyticsModel(
        blogId: blogId,
        viewCount: 1,
        uniqueViewCount: 1,
        viewsByCountry: {country: 1},
        viewsByDevice: {device: 1},
        viewsByReferrer: {referrer: 1},
        lastUpdated: DateTime.now(),
      );
      await _analyticsCollection.doc(blogId).set(analytics.toMap());
    } else {
      await _analyticsCollection.doc(blogId).update({
        'viewCount': FieldValue.increment(1),
        'viewsByCountry.$country': FieldValue.increment(1),
        'viewsByDevice.$device': FieldValue.increment(1),
        'viewsByReferrer.$referrer': FieldValue.increment(1),
        'averageReadTime': readTime,
        'lastUpdated': Timestamp.fromDate(DateTime.now()),
      });
    }
  }

  // İşbirlikçi düzenleme oturumu başlatma
  Future<void> startCollaborativeSession(String blogId, String userId) async {
    if (!_activeSessions.containsKey(blogId)) {
      _activeSessions[blogId] = {};
    }
    _activeSessions[blogId]!.add(userId);
  }

  // İşbirlikçi düzenleme oturumu sonlandırma
  void endCollaborativeSession(String blogId, String userId) {
    _activeSessions[blogId]?.remove(userId);
    if (_activeSessions[blogId]?.isEmpty ?? false) {
      _activeSessions.remove(blogId);
    }
  }

  // Blog şablonu oluşturma
  Future<BlogTemplateModel> createTemplate({
    required String name,
    required String description,
    required String content,
    required String category,
    required List<String> tags,
    bool isPublic = false,
  }) async {
    final authRepo = Get.find<AuthRepository>();
    final userId = authRepo.currentUser?.uid;

    if (userId == null) {
      throw Exception('Kullanıcı oturum açmamış');
    }

    final template = BlogTemplateModel(
      id: _uuid.v4(),
      name: name,
      description: description,
      content: content,
      category: category,
      tags: tags,
      creatorId: userId,
      createdAt: DateTime.now(),
      isPublic: isPublic,
    );

    await _templatesCollection.doc(template.id).set(template.toMap());
    return template;
  }

  // Toplu blog işlemleri
  Future<void> bulkUpdateBlogs({
    required List<String> blogIds,
    String? category,
    List<String>? tagsToAdd,
    List<String>? tagsToRemove,
    String? status,
  }) async {
    final batch = _firestore.batch();

    for (final blogId in blogIds) {
      final docRef = _blogsCollection.doc(blogId);
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (category != null) updates['category'] = category;
      if (status != null) updates['status'] = status;

      if (tagsToAdd != null || tagsToRemove != null) {
        final doc = await docRef.get();
        if (doc.exists) {
          final currentTags = List<String>.from(
            (doc.data() as Map<String, dynamic>)['tags'] ?? [],
          );

          if (tagsToAdd != null) currentTags.addAll(tagsToAdd);
          if (tagsToRemove != null) {
            currentTags.removeWhere((tag) => tagsToRemove.contains(tag));
          }

          updates['tags'] = currentTags;
        }
      }

      batch.update(docRef, updates);
    }

    await batch.commit();
  }

  // Blog detaylarını getir
  Future<BlogModel?> getBlogById(String blogId) async {
    final doc = await _blogsCollection.doc(blogId).get();
    if (!doc.exists) return null;
    return BlogModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  void onClose() {
    stopAutoSave();
    super.onClose();
  }
}
