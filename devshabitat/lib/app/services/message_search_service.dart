import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:devshabitat/app/models/message_model.dart';

class MessageSearchService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SharedPreferences _prefs = Get.find<SharedPreferences>();
  final String _recentSearchesKey = 'recent_searches';
  final int _maxRecentSearches = 10;
  final int pageSize = 20;

  List<String> get availableSenders => _availableSenders;
  final List<String> _availableSenders = [];

  Future<void> initialize() async {
    await _loadAvailableSenders();
  }

  Future<void> _loadAvailableSenders() async {
    try {
      final QuerySnapshot usersSnapshot =
          await _firestore.collection('users').get();
      _availableSenders.clear();
      _availableSenders.addAll(
        usersSnapshot.docs.map((doc) => doc.get('name') as String),
      );
    } catch (e) {
      print('Kullanıcı listesi yüklenirken hata: $e');
    }
  }

  Future<List<MessageModel>> searchMessages({
    required String searchTerm,
    required Map<String, dynamic> filters,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      // Input validation and sanitization
      final sanitizedTerm = _sanitizeSearchTerm(searchTerm);
      if (sanitizedTerm.isEmpty || sanitizedTerm.length > 100) {
        throw Exception('Geçersiz arama terimi');
      }

      Query query = _firestore
          .collection('messages')
          .where('content', isGreaterThanOrEqualTo: sanitizedTerm)
          .where('content', isLessThan: '${sanitizedTerm}z')
          .limit(pageSize);

      // Filtreleri uygula
      filters.forEach((key, value) {
        if (value != null) {
          query = query.where(key, isEqualTo: value);
        }
      });

      // Sayfalama için son dokümanı kullan
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final QuerySnapshot snapshot = await query.get();
      return snapshot.docs
          .map((doc) => MessageModel.fromMap({
                ...(doc.data() as Map<String, dynamic>),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      print('Mesaj araması sırasında hata: $e');
      return [];
    }
  }

  Future<List<String>> getRecentSearches() async {
    try {
      return _prefs.getStringList(_recentSearchesKey) ?? [];
    } catch (e) {
      print('Son aramaları getirirken hata: $e');
      return [];
    }
  }

  Future<void> addRecentSearch(String query) async {
    try {
      // Input validation
      final sanitizedQuery = _sanitizeSearchTerm(query);
      if (sanitizedQuery.isEmpty || sanitizedQuery.length > 100) {
        return; // Don't save invalid searches
      }

      final List<String> searches = await getRecentSearches();
      searches.remove(sanitizedQuery); // Varsa mevcut aramayı kaldır
      searches.insert(0, sanitizedQuery); // En başa ekle

      // Maksimum sayıyı aşmayacak şekilde kaydet
      if (searches.length > _maxRecentSearches) {
        searches.removeLast();
      }

      await _prefs.setStringList(_recentSearchesKey, searches);
    } catch (e) {
      print('Son arama eklenirken hata: $e');
    }
  }

  String _sanitizeSearchTerm(String term) {
    return term
        .replaceAll(RegExp(r'[<>"();]'), '')
        .replaceAll("'", '')
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('{', '')
        .replaceAll('}', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .trim();
  }

  Future<void> removeRecentSearch(String query) async {
    try {
      final List<String> searches = await getRecentSearches();
      searches.remove(query);
      await _prefs.setStringList(_recentSearchesKey, searches);
    } catch (e) {
      print('Son arama silinirken hata: $e');
    }
  }

  Future<List<DocumentSnapshot>> searchByUser({
    required String userId,
    DocumentSnapshot? lastDocument,
  }) async {
    Query query = _firestore
        .collection('messages')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(pageSize);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> searchByDate({
    required DateTime startDate,
    required DateTime endDate,
    DocumentSnapshot? lastDocument,
  }) async {
    Query query = _firestore
        .collection('messages')
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .where('timestamp', isLessThanOrEqualTo: endDate)
        .orderBy('timestamp', descending: true)
        .limit(pageSize);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    return snapshot.docs;
  }

  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('messages')
          .where('content', isGreaterThanOrEqualTo: query)
          .where('content', isLessThan: query + 'z')
          .limit(5)
          .get();

      return snapshot.docs
          .map((doc) =>
              (doc.data() as Map<String, dynamic>)['content'] as String)
          .where(
              (content) => content.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      print('Öneri getirme hatası: $e');
      return [];
    }
  }
}
