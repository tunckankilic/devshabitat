import 'package:get/get.dart';
import '../models/code_snippet_model.dart';
import '../services/code_discussion_service.dart';
import '../core/services/error_handler_service.dart';

class CodeDiscussionController extends GetxController {
  final CodeDiscussionService _discussionService = Get.find();
  final ErrorHandlerService _errorHandler = Get.find();

  final RxList<CodeSnippetModel> codeSnippets = <CodeSnippetModel>[].obs;
  final Rx<CodeSnippetModel?> currentDiscussion = Rx<CodeSnippetModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Kod parçası paylaşımı
  Future<void> shareCodeSnippet({
    required String code,
    required String language,
    required String title,
    String? description,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final snippet = await _discussionService.createCodeSnippet(
        code: code,
        language: language,
        title: title,
        description: description,
      );

      codeSnippets.add(snippet);
      Get.snackbar('Başarılı', 'Kod parçası başarıyla paylaşıldı');
    } catch (e) {
      error.value = 'Kod paylaşılırken bir hata oluştu: $e';
      _errorHandler.handleError(e, ErrorHandlerService.DISCUSSION_ERROR);
    } finally {
      isLoading.value = false;
    }
  }

  // Kod üzerinde yorum ve açıklama
  Future<void> addCodeComment({
    required String snippetId,
    required String comment,
    String? lineNumber,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _discussionService.addComment(
        snippetId: snippetId,
        comment: comment,
        lineNumber: lineNumber,
      );

      await loadDiscussion(snippetId);
      Get.snackbar('Başarılı', 'Yorum başarıyla eklendi');
    } catch (e) {
      error.value = 'Yorum eklenirken bir hata oluştu: $e';
      _errorHandler.handleError(e, ErrorHandlerService.DISCUSSION_ERROR);
    } finally {
      isLoading.value = false;
    }
  }

  // Çözüm önerisi paylaşma
  Future<void> proposeSolution({
    required String discussionId,
    required String code,
    required String explanation,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _discussionService.proposeSolution(
        discussionId: discussionId,
        code: code,
        explanation: explanation,
      );

      await loadDiscussion(discussionId);
      Get.snackbar('Başarılı', 'Çözüm önerisi başarıyla paylaşıldı');
    } catch (e) {
      error.value = 'Çözüm önerisi paylaşılırken bir hata oluştu: $e';
      _errorHandler.handleError(e, ErrorHandlerService.DISCUSSION_ERROR);
    } finally {
      isLoading.value = false;
    }
  }

  // Tartışma yükleme
  Future<void> loadDiscussion(String snippetId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final discussion = await _discussionService.getDiscussion(snippetId);
      currentDiscussion.value = discussion;
    } catch (e) {
      error.value = 'Tartışma yüklenirken bir hata oluştu: $e';
      _errorHandler.handleError(e, ErrorHandlerService.DISCUSSION_ERROR);
    } finally {
      isLoading.value = false;
    }
  }
}
