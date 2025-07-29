import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../controllers/auth_controller.dart';
import '../models/code_snippet_model.dart';

class BlogController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  // Blog creation form state
  final RxString blogTitle = ''.obs;
  final RxString blogDescription = ''.obs;
  final RxString blogCategory = ''.obs;
  final RxString blogTags = ''.obs;
  final RxString blogContent = ''.obs;
  final RxBool isCreatingBlog = false.obs;
  final RxString blogCreationError = ''.obs;

  // Blog list state
  final RxList<Map<String, dynamic>> blogs = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingBlogs = false.obs;
  final RxString blogsError = ''.obs;

  // Code snippets for current blog
  final RxList<CodeSnippetModel> codeSnippets = <CodeSnippetModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserBlogs();
  }

  // Create new blog post
  Future<void> createBlogPost() async {
    try {
      isCreatingBlog.value = true;
      blogCreationError.value = '';

      // Validation
      if (blogTitle.value.trim().isEmpty) {
        throw Exception('Blog başlığı gereklidir');
      }
      if (blogDescription.value.trim().isEmpty) {
        throw Exception('Blog açıklaması gereklidir');
      }
      if (blogContent.value.trim().isEmpty) {
        throw Exception('Blog içeriği gereklidir');
      }

      final currentUser = Get.find<AuthController>().currentUser;
      if (currentUser == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      // Parse tags
      final tags = blogTags.value
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      // Create blog post
      final blogData = {
        'title': blogTitle.value.trim(),
        'description': blogDescription.value.trim(),
        'category': blogCategory.value.trim().isNotEmpty
            ? blogCategory.value.trim()
            : 'Genel',
        'tags': tags,
        'content': blogContent.value.trim(),
        'authorId': currentUser.uid,
        'authorName': currentUser.displayName ?? 'Anonim',
        'authorEmail': currentUser.email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'published',
        'viewCount': 0,
        'likeCount': 0,
        'commentCount': 0,
        'isPublished': true,
        'publishedAt': FieldValue.serverTimestamp(),
        'codeSnippets':
            codeSnippets.map((snippet) => snippet.toJson()).toList(),
      };

      // Add to Firestore
      final docRef = await _firestore.collection('blogs').add(blogData);

      // Add to local list
      final newBlog = {
        'id': docRef.id,
        ...blogData,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'publishedAt': Timestamp.now(),
      };
      blogs.insert(0, newBlog);

      // Clear form
      clearBlogForm();

      Get.snackbar(
        'Başarılı',
        'Blog yazınız başarıyla yayınlandı!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate back
      Get.back();

      _logger.i('Blog post created successfully: ${docRef.id}');
    } catch (e) {
      blogCreationError.value = e.toString();
      _logger.e('Create blog post error: $e');

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

  // Save as draft
  Future<void> saveBlogAsDraft() async {
    try {
      isCreatingBlog.value = true;
      blogCreationError.value = '';

      if (blogTitle.value.trim().isEmpty) {
        throw Exception('En az blog başlığı gereklidir');
      }

      final currentUser = Get.find<AuthController>().currentUser;
      if (currentUser == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      final tags = blogTags.value
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final draftData = {
        'title': blogTitle.value.trim(),
        'description': blogDescription.value.trim(),
        'category': blogCategory.value.trim().isNotEmpty
            ? blogCategory.value.trim()
            : 'Genel',
        'tags': tags,
        'content': blogContent.value.trim(),
        'authorId': currentUser.uid,
        'authorName': currentUser.displayName ?? 'Anonim',
        'authorEmail': currentUser.email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'draft',
        'isPublished': false,
        'codeSnippets':
            codeSnippets.map((snippet) => snippet.toJson()).toList(),
      };

      await _firestore.collection('blogs').add(draftData);

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

  // Load user's blogs
  Future<void> loadUserBlogs() async {
    try {
      isLoadingBlogs.value = true;
      blogsError.value = '';

      final currentUser = Get.find<AuthController>().currentUser;
      if (currentUser == null) return;

      final querySnapshot = await _firestore
          .collection('blogs')
          .where('authorId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .get();

      final userBlogs = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      blogs.value = userBlogs;
      _logger.i('Loaded ${userBlogs.length} user blogs');
    } catch (e) {
      blogsError.value = 'Bloglar yüklenirken hata oluştu: $e';
      _logger.e('Load user blogs error: $e');
    } finally {
      isLoadingBlogs.value = false;
    }
  }

  // Clear blog creation form
  void clearBlogForm() {
    blogTitle.value = '';
    blogDescription.value = '';
    blogCategory.value = '';
    blogTags.value = '';
    blogContent.value = '';
    blogCreationError.value = '';
    codeSnippets.clear();
  }

  // Add code snippet to blog
  void addCodeSnippet({
    required String title,
    required String code,
    required String language,
    String? description,
  }) {
    final snippet = CodeSnippetModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      code: code,
      language: language,
      description: description,
      authorId: Get.find<AuthController>().currentUser?.uid ?? '',
      createdAt: DateTime.now(),
      comments: [],
      solutions: [],
    );

    codeSnippets.add(snippet);
    _logger.i('Code snippet added: ${snippet.title}');
  }

  // Remove code snippet from blog
  void removeCodeSnippet(int index) {
    if (index < codeSnippets.length) {
      final removedSnippet = codeSnippets.removeAt(index);
      _logger.i('Code snippet removed: ${removedSnippet.title}');
    }
  }

  // Validate blog form
  bool isBlogFormValid() {
    return blogTitle.value.trim().isNotEmpty &&
        blogDescription.value.trim().isNotEmpty &&
        blogContent.value.trim().isNotEmpty;
  }

  // Get form validation errors
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
    return null;
  }

  // Delete blog post
  Future<void> deleteBlogPost(String blogId) async {
    try {
      await _firestore.collection('blogs').doc(blogId).delete();
      blogs.removeWhere((blog) => blog['id'] == blogId);

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

  // Get word count for content
  int get contentWordCount {
    if (blogContent.value.trim().isEmpty) return 0;
    return blogContent.value.trim().split(RegExp(r'\s+')).length;
  }

  // Get estimated reading time
  String get estimatedReadingTime {
    final words = contentWordCount;
    final minutes =
        (words / 200).ceil(); // Average reading speed: 200 words/minute
    return minutes <= 1 ? '1 dk okuma' : '$minutes dk okuma';
  }
}
