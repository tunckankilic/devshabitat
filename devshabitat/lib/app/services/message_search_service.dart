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

  Future<List<Message>> searchMessages({
    required String searchTerm,
    required Map<String, dynamic> filters,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection('messages')
          .where('content', isGreaterThanOrEqualTo: searchTerm)
          .where('content', isLessThan: searchTerm + 'z')
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
      return snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
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
      final List<String> searches = await getRecentSearches();
      searches.remove(query); // Varsa mevcut aramayı kaldır
      searches.insert(0, query); // En başa ekle

      // Maksimum sayıyı aşmayacak şekilde kaydet
      if (searches.length > _maxRecentSearches) {
        searches.removeLast();
      }

      await _prefs.setStringList(_recentSearchesKey, searches);
    } catch (e) {
      print('Son arama eklenirken hata: $e');
    }
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
}
