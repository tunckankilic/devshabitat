import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/code_snippet_model.dart';
import '../repositories/auth_repository.dart';
import '../models/code_comment_model.dart';
import 'package:uuid/uuid.dart';

class CodeDiscussionService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // Koleksiyon referansları
  late final CollectionReference _snippetsCollection;
  late final CollectionReference _commentsCollection;
  late final CollectionReference _solutionsCollection;

  @override
  void onInit() {
    super.onInit();
    _snippetsCollection = _firestore.collection('code_snippets');
    _commentsCollection = _firestore.collection('code_comments');
    _solutionsCollection = _firestore.collection('code_solutions');
  }

  // Kod parçası oluşturma
  Future<CodeSnippetModel> createCodeSnippet({
    required String code,
    required String language,
    required String title,
    required String description,
  }) async {
    final String snippetId = _uuid.v4();
    final authRepo = Get.find<AuthRepository>();
    final userId = authRepo.currentUser?.uid;
    final userName = authRepo.currentUser?.displayName;

    if (userId == null) {
      throw Exception('Kullanıcı oturum açmamış');
    }

    final snippet = CodeSnippetModel(
      id: snippetId,
      code: code,
      language: language,
      title: title,
      description: description,
      authorId: userId,
      authorName: userName ?? 'Anonim Kullanıcı',
      createdAt: DateTime.now(),
    );

    await _snippetsCollection.doc(snippetId).set(snippet.toMap());
    return snippet;
  }

  // Yorum ekleme
  Future<void> addComment({
    required String snippetId,
    required String comment,
    String? lineNumber,
  }) async {
    final String commentId = _uuid.v4();
    final authRepo = Get.find<AuthRepository>();
    final userId = authRepo.currentUser?.uid;

    if (userId == null) {
      throw Exception('Kullanıcı oturum açmamış');
    }

    final codeComment = CodeComment(
      id: commentId,
      comment: comment,
      authorId: userId,
      lineNumber: lineNumber != null ? int.parse(lineNumber) : null,
      createdAt: DateTime.now(),
    );

    await _commentsCollection.doc(commentId).set(codeComment.toMap());
    await _snippetsCollection.doc(snippetId).update({
      'comments': FieldValue.arrayUnion([commentId]),
    });
  }

  // Çözüm önerisi ekleme
  Future<void> proposeSolution({
    required String discussionId,
    required String code,
    required String explanation,
  }) async {
    final String solutionId = _uuid.v4();
    final authRepo = Get.find<AuthRepository>();
    final userId = authRepo.currentUser?.uid;

    if (userId == null) {
      throw Exception('Kullanıcı oturum açmamış');
    }

    final solution = CodeSolution(
      id: solutionId,
      code: code,
      explanation: explanation,
      authorId: userId,
      votes: 0,
      createdAt: DateTime.now(),
    );

    await _solutionsCollection.doc(solutionId).set(solution.toMap());
    await _snippetsCollection.doc(discussionId).update({
      'solutions': FieldValue.arrayUnion([solutionId]),
    });
  }

  // Tartışma detaylarını getir
  Future<CodeSnippetModel> getDiscussion(String snippetId) async {
    final doc = await _snippetsCollection.doc(snippetId).get();
    if (!doc.exists) {
      throw Exception('Tartışma bulunamadı');
    }

    return CodeSnippetModel.fromDocument(doc);
  }

  // Çözüm oylaması
  Future<void> voteSolution({
    required String solutionId,
    required bool isUpvote,
  }) async {
    await _solutionsCollection.doc(solutionId).update({
      'votes': FieldValue.increment(isUpvote ? 1 : -1),
    });
  }

  // Tartışmaları listele
  Future<List<CodeSnippetModel>> getDiscussions({
    String? language,
    String? userId,
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = _snippetsCollection.orderBy('createdAt', descending: true);

    if (language != null) {
      query = query.where('language', isEqualTo: language);
    }

    if (userId != null) {
      query = query.where('authorId', isEqualTo: userId);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    query = query.limit(limit);

    final querySnapshot = await query.get();
    return querySnapshot.docs
        .map((doc) => CodeSnippetModel.fromDocument(doc))
        .toList();
  }
}
