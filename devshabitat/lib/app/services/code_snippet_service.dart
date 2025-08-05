import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/code_snippet_model.dart';
import '../models/code_snippet_version.dart';
import '../models/code_snippet_comment.dart';
import '../core/services/error_handler_service.dart';
import '../core/services/cache_service.dart';

class CodeSnippetService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ErrorHandlerService _errorHandler = Get.find();
  final CacheService _cacheService = Get.find();

  static const String CACHE_KEY_PREFIX = 'code_snippet_';
  static const Duration CACHE_DURATION = Duration(minutes: 30);

  // Kod parçacığı CRUD işlemleri
  Future<CodeSnippetModel> createSnippet(CodeSnippetModel snippet) async {
    try {
      final docRef = await _firestore
          .collection('code_snippets')
          .add(snippet.toMap());
      return snippet.copyWith(id: docRef.id);
    } catch (e) {
      _errorHandler.handleError(e, 'createSnippet');
      rethrow;
    }
  }

  Future<void> updateSnippet(CodeSnippetModel snippet) async {
    try {
      await _firestore
          .collection('code_snippets')
          .doc(snippet.id)
          .update(snippet.toMap());

      // Önbelleği güncelle
      final cacheKey = '${CACHE_KEY_PREFIX}${snippet.id}';
      await _cacheService.setData(cacheKey, snippet.toMap());
    } catch (e) {
      _errorHandler.handleError(e, 'updateSnippet');
      rethrow;
    }
  }

  Future<void> deleteSnippet(String snippetId) async {
    try {
      await _firestore.collection('code_snippets').doc(snippetId).delete();

      // Önbelleği temizle
      final cacheKey = '${CACHE_KEY_PREFIX}$snippetId';
      await _cacheService.removeData(cacheKey);
    } catch (e) {
      _errorHandler.handleError(e, 'deleteSnippet');
      rethrow;
    }
  }

  // Versiyon yönetimi
  Future<CodeSnippetVersion> createVersion(CodeSnippetVersion version) async {
    try {
      await _firestore
          .collection('code_snippets')
          .doc(version.snippetId)
          .collection('versions')
          .add(version.toMap());
      return version;
    } catch (e) {
      _errorHandler.handleError(e, 'createVersion');
      rethrow;
    }
  }

  Future<List<CodeSnippetVersion>> getVersions(String snippetId) async {
    try {
      final snapshot = await _firestore
          .collection('code_snippets')
          .doc(snippetId)
          .collection('versions')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CodeSnippetVersion.fromDocument(doc))
          .toList();
    } catch (e) {
      _errorHandler.handleError(e, 'getVersions');
      return [];
    }
  }

  // Yorum yönetimi
  Future<CodeSnippetComment> addComment(CodeSnippetComment comment) async {
    try {
      await _firestore
          .collection('code_snippets')
          .doc(comment.snippetId)
          .collection('comments')
          .add(comment.toMap());
      return comment;
    } catch (e) {
      _errorHandler.handleError(e, 'addComment');
      rethrow;
    }
  }

  Future<void> updateComment(CodeSnippetComment comment) async {
    try {
      await _firestore
          .collection('code_snippets')
          .doc(comment.snippetId)
          .collection('comments')
          .doc(comment.id)
          .update(comment.toMap());
    } catch (e) {
      _errorHandler.handleError(e, 'updateComment');
      rethrow;
    }
  }

  Future<void> deleteComment(String snippetId, String commentId) async {
    try {
      await _firestore
          .collection('code_snippets')
          .doc(snippetId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (e) {
      _errorHandler.handleError(e, 'deleteComment');
      rethrow;
    }
  }

  Future<List<CodeSnippetComment>> getComments(String snippetId) async {
    try {
      final snapshot = await _firestore
          .collection('code_snippets')
          .doc(snippetId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CodeSnippetComment.fromDocument(doc))
          .toList();
    } catch (e) {
      _errorHandler.handleError(e, 'getComments');
      return [];
    }
  }

  // Beğeni yönetimi
  Future<void> toggleLike(
    String snippetId,
    String commentId,
    String userId,
  ) async {
    try {
      final docRef = _firestore
          .collection('code_snippets')
          .doc(snippetId)
          .collection('comments')
          .doc(commentId);

      final doc = await docRef.get();
      final comment = CodeSnippetComment.fromDocument(doc);

      if (comment.likes.contains(userId)) {
        await docRef.update({
          'likes': FieldValue.arrayRemove([userId]),
        });
      } else {
        await docRef.update({
          'likes': FieldValue.arrayUnion([userId]),
        });
      }
    } catch (e) {
      _errorHandler.handleError(e, 'toggleLike');
      rethrow;
    }
  }

  // Kod parçacığı paylaşımı
  Future<String> shareSnippet(CodeSnippetModel snippet) async {
    try {
      final sharedSnippet = await createSnippet(
        snippet.copyWith(
          metadata: {
            ...snippet.metadata ?? {},
            'isShared': true,
            'originalId': snippet.id,
          },
        ),
      );
      return sharedSnippet.id;
    } catch (e) {
      _errorHandler.handleError(e, 'shareSnippet');
      rethrow;
    }
  }

  // Kod parçacığı arama
  Future<List<CodeSnippetModel>> searchSnippets({
    String? query,
    String? language,
    String? authorId,
    int limit = 20,
  }) async {
    try {
      Query snippetsQuery = _firestore.collection('code_snippets');

      if (authorId != null) {
        snippetsQuery = snippetsQuery.where('authorId', isEqualTo: authorId);
      }

      if (language != null) {
        snippetsQuery = snippetsQuery.where('language', isEqualTo: language);
      }

      if (query != null && query.isNotEmpty) {
        snippetsQuery = snippetsQuery.where(
          'searchTerms',
          arrayContains: query.toLowerCase(),
        );
      }

      final snapshot = await snippetsQuery
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => CodeSnippetModel.fromDocument(doc))
          .toList();
    } catch (e) {
      _errorHandler.handleError(e, 'searchSnippets');
      return [];
    }
  }
}
