import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/blog_model.dart';
import '../models/code_snippet_model.dart';
import '../controllers/auth_controller.dart';
import '../core/services/cache_service.dart';

class BlogController extends GetxController {
  static const int CACHE_DURATION_MINUTES = 30;
  static const int ITEMS_PER_PAGE = 10;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();
  final CacheService _cacheService = Get.find<CacheService>();

  // Form Controllers
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController contentController;
  late TextEditingController tagsController;
  late TextEditingController categoryController;

  // Blog creation form state
  final RxString blogTitle = ''.obs;
  final RxString blogDescription = ''.obs;
  final RxString blogCategory = ''.obs;
  final RxString blogTags = ''.obs;
  final RxString blogContent = ''.obs;
  final RxBool isCreatingBlog = false.obs;
  final RxString blogCreationError = ''.obs;

  // Search and filter state
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = ''.obs;
  final RxList<String> availableCategories = <String>[].obs;

  // Blog list state with pagination
  final RxList<BlogModel> blogs = <BlogModel>[].obs;
  final RxBool isLoadingBlogs = false.obs;
  final RxString blogsError = ''.obs;
  final RxBool hasMoreBlogs = true.obs;
  final RxInt currentPage = 1.obs;

  // Code snippets for current blog
  final RxList<CodeSnippetModel> codeSnippets = <CodeSnippetModel>[].obs;

  // Auto-save timer
  Timer? _autoSaveTimer;
  final RxBool isDirty = false.obs;

  // Cache keys
  static const String BLOGS_CACHE_KEY = 'user_blogs_cache';
  static const String DRAFT_CACHE_KEY = 'blog_draft_';

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _setupAutoSave();
    loadUserBlogs();
  }

  @override
  void onClose() {
    _disposeControllers();
    _autoSaveTimer?.cancel();
    super.onClose();
  }

  void _initializeControllers() {
    titleController = TextEditingController()
      ..addListener(() {
        blogTitle.value = titleController.text;
        _markAsDirty();
      });

    descriptionController = TextEditingController()
      ..addListener(() {
        blogDescription.value = descriptionController.text;
        _markAsDirty();
      });

    contentController = TextEditingController()
      ..addListener(() {
        blogContent.value = contentController.text;
        _markAsDirty();
      });

    tagsController = TextEditingController()
      ..addListener(() {
        blogTags.value = tagsController.text;
        _markAsDirty();
      });

    categoryController = TextEditingController()
      ..addListener(() {
        blogCategory.value = categoryController.text;
        _markAsDirty();
      });
  }

  void _disposeControllers() {
    titleController.dispose();
    descriptionController.dispose();
    contentController.dispose();
    tagsController.dispose();
    categoryController.dispose();
  }

  void _setupAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (isDirty.value) {
        _autoSaveDraft();
      }
    });
  }

  void _markAsDirty() {
    isDirty.value = true;
  }

  Future<void> _autoSaveDraft() async {
    if (!isBlogFormValid()) return;

    try {
      final currentUser = Get.find<AuthController>().currentUser;
      if (currentUser == null) return;

      final draftKey = '$DRAFT_CACHE_KEY${currentUser.uid}';
      final draftData = {
        'title': blogTitle.value,
        'description': blogDescription.value,
        'category': blogCategory.value,
        'tags': blogTags.value,
        'content': blogContent.value,
        'lastSaved': DateTime.now().toIso8601String(),
      };

      await _cacheService.setData(draftKey, draftData);
      isDirty.value = false;
      _logger.i('Auto-saved blog draft');
    } catch (e) {
      _logger.e('Auto-save draft error: $e');
    }
  }

  Future<void> loadDraft() async {
    try {
      final currentUser = Get.find<AuthController>().currentUser;
      if (currentUser == null) return;

      final draftKey = '$DRAFT_CACHE_KEY${currentUser.uid}';
      final draftData = await _cacheService.getData(draftKey);

      if (draftData != null) {
        titleController.text = draftData['title'] ?? '';
        descriptionController.text = draftData['description'] ?? '';
        categoryController.text = draftData['category'] ?? '';
        tagsController.text = draftData['tags'] ?? '';
        contentController.text = draftData['content'] ?? '';

        blogTitle.value = draftData['title'] ?? '';
        blogDescription.value = draftData['description'] ?? '';
        blogCategory.value = draftData['category'] ?? '';
        blogTags.value = draftData['tags'] ?? '';
        blogContent.value = draftData['content'] ?? '';
      }
    } catch (e) {
      _logger.e('Load draft error: $e');
    }
  }

  Future<void> createBlogPost() async {
    try {
      if (!isBlogFormValid()) {
        throw Exception(getBlogFormError());
      }

      isCreatingBlog.value = true;
      blogCreationError.value = '';

      final currentUser = Get.find<AuthController>().currentUser;
      if (currentUser == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      final blog = await _prepareBlogData(currentUser, true);
      final docRef = await _firestore.collection('blogs').add(blog.toMap());

      final newBlog = blog.copyWith(id: docRef.id);
      blogs.insert(0, newBlog);

      // Clear draft after successful publish
      final draftKey = '$DRAFT_CACHE_KEY${currentUser.uid}';
      await _cacheService.removeData(draftKey);

      clearBlogForm();
      Get.back();

      Get.snackbar(
        'Başarılı',
        'Blog yazınız yayınlandı',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      _logger.i('Blog created successfully: ${docRef.id}');
    } catch (e) {
      blogCreationError.value = e.toString();
      _logger.e('Create blog error: $e');

      Get.snackbar(
        'Hata',
        blogCreationError.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isCreatingBlog.value = false;
    }
  }

  Future<void> saveBlogAsDraft() async {
    try {
      if (blogTitle.value.trim().isEmpty) {
        throw Exception('En az blog başlığı gereklidir');
      }

      isCreatingBlog.value = true;
      blogCreationError.value = '';

      final currentUser = Get.find<AuthController>().currentUser;
      if (currentUser == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      final blog = await _prepareBlogData(currentUser, false);
      final docRef = await _firestore.collection('blogs').add(blog.toMap());

      final newBlog = blog.copyWith(id: docRef.id);
      blogs.insert(0, newBlog);

      clearBlogForm();

      Get.snackbar(
        'Başarılı',
        'Blog yazınız taslak olarak kaydedildi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );

      Get.back();
      _logger.i('Blog saved as draft successfully');
    } catch (e) {
      blogCreationError.value = e.toString();
      _logger.e('Save blog as draft error: $e');

      Get.snackbar(
        'Hata',
        blogCreationError.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isCreatingBlog.value = false;
    }
  }

  Future<BlogModel> _prepareBlogData(user, bool isPublished) async {
    final tags = blogTags.value
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final now = DateTime.now();
    final content = blogContent.value.trim();
    final words = content.split(RegExp(r'\s+')).length;
    final readingTime = '${(words / 200).ceil()} dk okuma';

    return BlogModel(
      id: '',
      title: blogTitle.value.trim(),
      content: content,
      summary: blogDescription.value.trim().split('.').first,
      description: blogDescription.value.trim(),
      publishDate: now.toIso8601String(),
      category: blogCategory.value.trim().isNotEmpty
          ? blogCategory.value.trim()
          : 'Genel',
      tags: tags,
      authorId: user.uid,
      authorName: user.displayName ?? 'Anonim',
      authorEmail: user.email,
      createdAt: now,
      updatedAt: now,
      publishedAt: isPublished ? now : null,
      status: isPublished ? 'published' : 'draft',
      isPublished: isPublished,
      viewCount: 0,
      estimatedReadingTime: readingTime,
      codeSnippets: codeSnippets.toList(),
    );
  }

  Future<void> loadUserBlogs() async {
    if (isLoadingBlogs.value) return;

    try {
      isLoadingBlogs.value = true;
      blogsError.value = '';

      final currentUser = Get.find<AuthController>().currentUser;
      if (currentUser == null) return;

      // Try to get from cache first
      final cachedBlogs = await _getCachedBlogs();
      if (cachedBlogs != null) {
        blogs.value = cachedBlogs;
        _logger.i('Loaded ${cachedBlogs.length} blogs from cache');
        return;
      }

      // If not in cache, load from Firestore
      final querySnapshot = await _firestore
          .collection('blogs')
          .where('authorId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .limit(ITEMS_PER_PAGE)
          .get();

      final userBlogs = querySnapshot.docs
          .map((doc) => BlogModel.fromDocument(doc))
          .toList();

      blogs.value = userBlogs;
      hasMoreBlogs.value = userBlogs.length >= ITEMS_PER_PAGE;

      // Cache the results
      await _cacheBlogs(userBlogs);

      _logger.i('Loaded ${userBlogs.length} user blogs from Firestore');
    } catch (e) {
      blogsError.value = 'Bloglar yüklenirken hata oluştu: $e';
      _logger.e('Load user blogs error: $e');
    } finally {
      isLoadingBlogs.value = false;
    }
  }

  Future<void> loadMoreBlogs() async {
    if (isLoadingBlogs.value || !hasMoreBlogs.value) return;

    try {
      isLoadingBlogs.value = true;

      final currentUser = Get.find<AuthController>().currentUser;
      if (currentUser == null) return;

      final lastBlog = blogs.last;

      final querySnapshot = await _firestore
          .collection('blogs')
          .where('authorId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .startAfter([lastBlog.createdAt])
          .limit(ITEMS_PER_PAGE)
          .get();

      final moreBlogs = querySnapshot.docs
          .map((doc) => BlogModel.fromDocument(doc))
          .toList();

      blogs.addAll(moreBlogs);
      hasMoreBlogs.value = moreBlogs.length >= ITEMS_PER_PAGE;
      currentPage.value++;

      _logger.i('Loaded ${moreBlogs.length} more blogs');
    } catch (e) {
      _logger.e('Load more blogs error: $e');
      Get.snackbar(
        'Hata',
        'Daha fazla blog yüklenirken hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingBlogs.value = false;
    }
  }

  Future<List<BlogModel>?> _getCachedBlogs() async {
    final currentUser = Get.find<AuthController>().currentUser;
    if (currentUser == null) return null;

    final cacheKey = '${BLOGS_CACHE_KEY}_${currentUser.uid}';
    final cachedData = await _cacheService.getData(cacheKey);

    if (cachedData != null) {
      final cacheTimestamp = DateTime.parse(cachedData['timestamp']);
      if (DateTime.now().difference(cacheTimestamp).inMinutes <
          CACHE_DURATION_MINUTES) {
        return (cachedData['blogs'] as List)
            .map((blogData) => BlogModel.fromMap(blogData))
            .toList();
      }
    }
    return null;
  }

  Future<void> _cacheBlogs(List<BlogModel> blogsToCache) async {
    final currentUser = Get.find<AuthController>().currentUser;
    if (currentUser == null) return;

    final cacheKey = '${BLOGS_CACHE_KEY}_${currentUser.uid}';
    final cacheData = {
      'timestamp': DateTime.now().toIso8601String(),
      'blogs': blogsToCache.map((blog) => blog.toJson()).toList(),
    };

    await _cacheService.setData(cacheKey, cacheData);
  }

  void clearBlogForm() {
    titleController.clear();
    descriptionController.clear();
    contentController.clear();
    tagsController.clear();
    categoryController.clear();

    blogTitle.value = '';
    blogDescription.value = '';
    blogCategory.value = '';
    blogTags.value = '';
    blogContent.value = '';
    blogCreationError.value = '';
    codeSnippets.clear();
    isDirty.value = false;
  }

  void addCodeSnippet({
    required String title,
    required String code,
    required String language,
    String? description,
  }) {
    if (title.trim().isEmpty || code.trim().isEmpty) {
      Get.snackbar(
        'Hata',
        'Kod parçası başlığı ve içeriği gereklidir',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final snippet = CodeSnippetModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      code: code.trim(),
      language: language.trim(),
      description: description?.trim() ?? '',
      authorId: Get.find<AuthController>().currentUser?.uid ?? '',
      authorName:
          Get.find<AuthController>().currentUser?.displayName ?? 'Anonim',
      createdAt: DateTime.now(),
      comments: [],
      solutions: [],
    );

    codeSnippets.add(snippet);
    _markAsDirty();
    _logger.i('Code snippet added: ${snippet.title}');
  }

  void removeCodeSnippet(String snippetId) {
    final index = codeSnippets.indexWhere((snippet) => snippet.id == snippetId);
    if (index != -1) {
      final removedSnippet = codeSnippets.removeAt(index);
      _markAsDirty();
      _logger.i('Code snippet removed: ${removedSnippet.title}');
    }
  }

  bool isBlogFormValid() {
    return blogTitle.value.trim().isNotEmpty &&
        blogDescription.value.trim().isNotEmpty &&
        blogContent.value.trim().isNotEmpty &&
        _isContentLengthValid();
  }

  bool _isContentLengthValid() {
    final wordCount = this.wordCount;
    return wordCount >= 100 && wordCount <= 5000;
  }

  String? getBlogFormError() {
    if (blogTitle.value.trim().isEmpty) {
      return 'Blog başlığı gereklidir';
    }
    if (blogDescription.value.trim().isEmpty) {
      return 'Blog açıklaması gereklidir';
    }
    if (blogContent.value.trim().isEmpty) {
      return 'Blog içeriği gereklidir';
    }
    if (!_isContentLengthValid()) {
      return 'Blog içeriği 100-5000 kelime arasında olmalıdır';
    }
    return null;
  }

  Future<void> deleteBlogPost(String blogId) async {
    try {
      await _firestore.collection('blogs').doc(blogId).delete();
      blogs.removeWhere((blog) => blog.id == blogId);

      // Update cache
      final currentUser = Get.find<AuthController>().currentUser;
      if (currentUser != null) {
        await _cacheBlogs(blogs);
      }

      Get.snackbar(
        'Başarılı',
        'Blog yazısı silindi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      _logger.i('Blog post deleted: $blogId');
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Blog silinirken hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      _logger.e('Delete blog post error: $e');
    }
  }

  int get wordCount {
    if (blogContent.value.trim().isEmpty) return 0;
    return blogContent.value.trim().split(RegExp(r'\s+')).length;
  }

  String get estimatedReadingTime {
    final words = wordCount;
    final minutes = (words / 200)
        .ceil(); // Average reading speed: 200 words/minute
    return minutes <= 1 ? '1 dk okuma' : '$minutes dk okuma';
  }

  Future<void> refreshBlogs() async {
    currentPage.value = 1;
    blogs.clear();
    hasMoreBlogs.value = true;
    await loadUserBlogs();
  }
}
