import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/code_snippet_model.dart';
import '../models/code_snippet_version.dart';
import '../models/code_snippet_comment.dart';
import '../services/code_snippet_service.dart';
import '../controllers/auth_controller.dart';

class CodeSnippetController extends GetxController {
  final CodeSnippetService _snippetService = Get.find();
  final AuthController _authController = Get.find();

  // Durum yönetimi
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxList<CodeSnippetModel> snippets = <CodeSnippetModel>[].obs;
  final RxList<CodeSnippetVersion> versions = <CodeSnippetVersion>[].obs;
  final RxList<CodeSnippetComment> comments = <CodeSnippetComment>[].obs;

  // Form kontrolcüleri
  late TextEditingController codeController;
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController commentController;

  // Seçili öğeler
  final Rx<CodeSnippetModel?> selectedSnippet = Rx<CodeSnippetModel?>(null);
  final Rx<CodeSnippetVersion?> selectedVersion = Rx<CodeSnippetVersion?>(null);

  // Filtreler
  final RxString searchQuery = ''.obs;
  final RxString selectedLanguage = ''.obs;
  final RxBool showOnlyMine = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  void _initializeControllers() {
    codeController = TextEditingController();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    commentController = TextEditingController();
  }

  void _disposeControllers() {
    codeController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    commentController.dispose();
  }

  // Kod parçacığı işlemleri
  Future<void> createSnippet() async {
    if (!_validateSnippet()) return;

    try {
      isLoading.value = true;
      error.value = '';

      final snippet = CodeSnippetModel(
        id: '',
        title: titleController.text.trim(),
        code: codeController.text.trim(),
        language: selectedLanguage.value,
        description: descriptionController.text.trim(),
        authorId: _authController.currentUser!.uid,
        authorName: _authController.currentUser!.displayName ?? 'Anonim',
        createdAt: DateTime.now(),
        comments: [],
        solutions: [],
      );

      final createdSnippet = await _snippetService.createSnippet(snippet);
      snippets.insert(0, createdSnippet);
      _clearForm();

      Get.snackbar(
        'Başarılı',
        'Kod parçacığı oluşturuldu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Hata',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSnippet(CodeSnippetModel snippet) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _snippetService.updateSnippet(snippet);
      final index = snippets.indexWhere((s) => s.id == snippet.id);
      if (index != -1) {
        snippets[index] = snippet;
      }

      Get.snackbar(
        'Başarılı',
        'Kod parçacığı güncellendi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Hata',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSnippet(String snippetId) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _snippetService.deleteSnippet(snippetId);
      snippets.removeWhere((s) => s.id == snippetId);

      Get.snackbar(
        'Başarılı',
        'Kod parçacığı silindi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Hata',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Versiyon yönetimi
  Future<void> createVersion(String snippetId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final version = CodeSnippetVersion(
        id: '',
        snippetId: snippetId,
        code: codeController.text.trim(),
        authorId: _authController.currentUser!.uid,
        createdAt: DateTime.now(),
        description: descriptionController.text.trim(),
      );

      await _snippetService.createVersion(version);
      await loadVersions(snippetId);

      Get.snackbar(
        'Başarılı',
        'Yeni versiyon oluşturuldu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Hata',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadVersions(String snippetId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final loadedVersions = await _snippetService.getVersions(snippetId);
      versions.value = loadedVersions;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Yorum yönetimi
  Future<void> addComment(String snippetId, {String? codeReference}) async {
    if (commentController.text.trim().isEmpty) return;

    try {
      isLoading.value = true;
      error.value = '';

      final comment = CodeSnippetComment(
        id: '',
        snippetId: snippetId,
        authorId: _authController.currentUser!.uid,
        authorName: _authController.currentUser!.displayName ?? 'Anonim',
        authorPhotoUrl: _authController.currentUser!.photoURL,
        content: commentController.text.trim(),
        createdAt: DateTime.now(),
        codeReference: codeReference,
      );

      await _snippetService.addComment(comment);
      await loadComments(snippetId);
      commentController.clear();

      Get.snackbar(
        'Başarılı',
        'Yorum eklendi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Hata',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadComments(String snippetId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final loadedComments = await _snippetService.getComments(snippetId);
      comments.value = loadedComments;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleLike(String snippetId, String commentId) async {
    try {
      await _snippetService.toggleLike(
        snippetId,
        commentId,
        _authController.currentUser!.uid,
      );
      await loadComments(snippetId);
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Hata',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Paylaşım
  Future<void> shareSnippet(CodeSnippetModel snippet) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _snippetService.shareSnippet(snippet);

      Get.snackbar(
        'Başarılı',
        'Kod parçacığı paylaşıldı',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Hata',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Arama ve filtreleme
  Future<void> searchSnippets() async {
    try {
      isLoading.value = true;
      error.value = '';

      final results = await _snippetService.searchSnippets(
        query: searchQuery.value,
        language: selectedLanguage.value.isNotEmpty
            ? selectedLanguage.value
            : null,
        authorId: showOnlyMine.value ? _authController.currentUser?.uid : null,
      );

      snippets.value = results;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Yardımcı metodlar
  bool _validateSnippet() {
    if (titleController.text.trim().isEmpty) {
      error.value = 'Başlık gereklidir';
      return false;
    }
    if (codeController.text.trim().isEmpty) {
      error.value = 'Kod gereklidir';
      return false;
    }
    if (selectedLanguage.value.isEmpty) {
      error.value = 'Programlama dili seçilmelidir';
      return false;
    }
    return true;
  }

  void _clearForm() {
    titleController.clear();
    codeController.clear();
    descriptionController.clear();
    selectedLanguage.value = '';
  }
}
