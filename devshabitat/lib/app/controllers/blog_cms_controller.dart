import 'dart:io';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../services/blog_management_service.dart';
import '../services/blog_editor_service.dart';
import '../models/blog_model.dart';
import '../models/blog_analytics_model.dart';
import '../models/blog_template_model.dart';

class BlogCMSController extends GetxController {
  final _blogService = Get.find<BlogManagementService>();
  final _editorService = Get.find<BlogEditorService>();

  // Reaktif değişkenler
  final currentBlog = Rx<BlogModel?>(null);
  final isEditing = false.obs;
  final isSaving = false.obs;
  final isPublishing = false.obs;
  final editorContent = ''.obs;
  final previewContent = ''.obs;
  final selectedTemplate = Rx<BlogTemplateModel?>(null);
  final analytics = Rx<BlogAnalyticsModel?>(null);
  final seoSuggestions = <String>[].obs;

  // Markdown önizleme
  void updatePreview(String markdown) {
    previewContent.value = _editorService.markdownToHtml(markdown);
    editorContent.value = markdown;
    _blogService.startAutoSave(currentBlog.value!.id, markdown);
    _updateSEOSuggestions();
  }

  // SEO önerilerini güncelle
  void _updateSEOSuggestions() {
    if (currentBlog.value == null) return;

    final analysis = _editorService.analyzeSEO(
      currentBlog.value!.title,
      editorContent.value,
    );

    seoSuggestions.value = analysis['suggestions'] as List<String>;
  }

  // Resim yükleme
  Future<String> uploadImage(File image) async {
    if (currentBlog.value == null) {
      throw Exception('Blog seçili değil');
    }

    try {
      return await _editorService.uploadOptimizedImage(
        image,
        currentBlog.value!.id,
      );
    } catch (e) {
      throw Exception('Resim yüklenemedi: $e');
    }
  }

  // Blog kaydetme
  Future<void> saveBlog() async {
    if (currentBlog.value == null) return;

    try {
      isSaving.value = true;
      await _blogService.saveDraft(currentBlog.value!.id, editorContent.value);
    } finally {
      isSaving.value = false;
    }
  }

  // Blog yayınlama
  Future<void> publishBlog({DateTime? scheduledDate}) async {
    if (currentBlog.value == null) return;

    try {
      isPublishing.value = true;

      // Son bir kez kaydet
      await saveBlog();

      // Yayınla
      await _blogService.publishBlog(
        currentBlog.value!.id,
        scheduledDate: scheduledDate,
      );
    } finally {
      isPublishing.value = false;
    }
  }

  // Blog düzenlemeye başla
  Future<void> startEditing(String blogId) async {
    try {
      isEditing.value = true;

      // İşbirlikçi düzenleme oturumu başlat
      await _blogService.startCollaborativeSession(
        blogId,
        Get.find<AuthController>().currentUser?.uid ?? '',
      );

      // Otomatik kaydetmeyi başlat
      _blogService.startAutoSave(blogId, editorContent.value);
    } catch (e) {
      isEditing.value = false;
      rethrow;
    }
  }

  // Blog düzenlemeyi bitir
  void stopEditing() {
    if (currentBlog.value == null) return;

    isEditing.value = false;
    _blogService.stopAutoSave();
    _blogService.endCollaborativeSession(
      currentBlog.value!.id,
      Get.find<AuthController>().currentUser?.uid ?? '',
    );
  }

  // Toplu blog işlemleri
  Future<void> bulkUpdateBlogs({
    required List<String> blogIds,
    String? category,
    List<String>? tagsToAdd,
    List<String>? tagsToRemove,
    String? status,
  }) async {
    await _blogService.bulkUpdateBlogs(
      blogIds: blogIds,
      category: category,
      tagsToAdd: tagsToAdd,
      tagsToRemove: tagsToRemove,
      status: status,
    );
  }

  @override
  void onClose() {
    stopEditing();
    super.onClose();
  }
}
