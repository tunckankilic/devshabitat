import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/code_snippet_model.dart';
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
    String? description,
  }) async {
    final String snippetId = _uuid.v4();
    final String userId = Get.find<String>(); // Kullanıcı ID'sini al

    final snippet = CodeSnippetModel(
      id: snippetId,
      code: code,
      language: language,
      title: title,
      description: description,
      authorId: userId,
      createdAt: DateTime.now(),
    );

    await _snippetsCollection.doc(snippetId).set(snippet.toJson());
    return snippet;
  }

  // Yorum ekleme
  Future<void> addComment({
    required String snippetId,
    required String comment,
    String? lineNumber,
  }) async {
    final String commentId = _uuid.v4();
    final String userId = Get.find<String>();

    final codeComment = CodeComment(
      id: commentId,
      comment: comment,
      authorId: userId,
      lineNumber: lineNumber,
      createdAt: DateTime.now(),
    );

    await _commentsCollection.doc(commentId).set(codeComment.toJson());
    await _snippetsCollection.doc(snippetId).update({
      'comments': FieldValue.arrayUnion([commentId])
    });
  }

  // Çözüm önerisi ekleme
  Future<void> proposeSolution({
    required String discussionId,
    required String code,
    required String explanation,
  }) async {
    final String solutionId = _uuid.v4();
    final String userId = Get.find<String>();

    final solution = CodeSolution(
      id: solutionId,
      code: code,
      explanation: explanation,
      authorId: userId,
      createdAt: DateTime.now(),
    );

    await _solutionsCollection.doc(solutionId).set(solution.toJson());
    await _snippetsCollection.doc(discussionId).update({
      'solutions': FieldValue.arrayUnion([solutionId])
    });
  }

  // Tartışma detaylarını getir
  Future<CodeSnippetModel> getDiscussion(String snippetId) async {
    final doc = await _snippetsCollection.doc(snippetId).get();
    if (!doc.exists) {
      throw Exception('Tartışma bulunamadı');
    }

    final data = doc.data() as Map<String, dynamic>;
    return CodeSnippetModel.fromJson(data);
  }

  // Çözüm oylaması
  Future<void> voteSolution({
    required String solutionId,
    required bool isUpvote,
  }) async {
    await _solutionsCollection
        .doc(solutionId)
        .update({'votes': FieldValue.increment(isUpvote ? 1 : -1)});
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
        .map((doc) =>
            CodeSnippetModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
