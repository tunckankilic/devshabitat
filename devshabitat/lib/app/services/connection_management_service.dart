import 'package:get/get.dart';
import '../models/user_profile_model.dart';

enum ConnectionCategory { colleague, industryPeer, mentor, local, other }

class ConnectionNote {
  final String userId;
  final String note;
  final DateTime createdAt;

  ConnectionNote({
    required this.userId,
    required this.note,
    required this.createdAt,
  });
}

class ConnectionManagementService extends GetxService {
  // Bağlantı kategorileri için storage
  final Map<String, ConnectionCategory> _connectionCategories = {};

  // Bağlantı notları için storage
  final Map<String, List<ConnectionNote>> _connectionNotes = {};

  // Bağlantı kategorisini güncelle
  Future<void> updateConnectionCategory(
    String userId,
    ConnectionCategory category,
  ) async {
    _connectionCategories[userId] = category;
  }

  // Bağlantıya not ekle
  Future<void> addConnectionNote(String userId, String note) async {
    if (!_connectionNotes.containsKey(userId)) {
      _connectionNotes[userId] = [];
    }

    final newNote = ConnectionNote(
      userId: userId,
      note: note,
      createdAt: DateTime.now(),
    );

    _connectionNotes[userId]!.add(newNote);
  }

  // Bağlantının notlarını getir
  List<ConnectionNote> getConnectionNotes(String userId) {
    return _connectionNotes[userId] ?? [];
  }

  // Bağlantıyı otomatik kategorize et
  ConnectionCategory categorizeConnection(UserProfile connection) {
    // Aynı şirketten çalışanları belirle
    if (_isColleague(connection)) {
      return ConnectionCategory.colleague;
    }

    // Mentorları belirle (deneyim ve pozisyona göre)
    if (_isMentor(connection)) {
      return ConnectionCategory.mentor;
    }

    // Aynı sektörden kişileri belirle
    if (_isIndustryPeer(connection)) {
      return ConnectionCategory.industryPeer;
    }

    // Aynı lokasyondaki kişileri belirle
    if (_isLocal(connection)) {
      return ConnectionCategory.local;
    }

    return ConnectionCategory.other;
  }

  // Aynı şirkette çalışanları belirle
  bool _isColleague(UserProfile connection) {
    final currentUserCompany = Get.find<UserProfile>().company?.toLowerCase();
    final connectionCompany = connection.company?.toLowerCase();

    return currentUserCompany != null &&
        connectionCompany != null &&
        currentUserCompany == connectionCompany;
  }

  // Mentor olabilecek kişileri belirle
  bool _isMentor(UserProfile connection) {
    // Kıdemli pozisyonları kontrol et
    final seniorTitles = [
      'senior',
      'lead',
      'manager',
      'director',
      'cto',
      'ceo',
      'head',
      'principal',
    ];

    final title = connection.title?.toLowerCase() ?? '';
    final yearsOfExperience = connection.yearsOfExperience;

    // Kıdemli pozisyon veya 5+ yıl deneyim
    return seniorTitles.any((t) => title.contains(t)) || yearsOfExperience >= 5;
  }

  // Aynı sektörden kişileri belirle
  bool _isIndustryPeer(UserProfile connection) {
    final currentUserSkills = Get.find<UserProfile>().skills;
    final connectionSkills = connection.skills;

    // Ortak skill sayısına göre sektör benzerliği hesapla
    final commonSkills =
        currentUserSkills.toSet().intersection(connectionSkills.toSet());
    return commonSkills.length >=
        3; // En az 3 ortak skill varsa aynı sektör kabul et
  }

  // Aynı lokasyondaki kişileri belirle
  bool _isLocal(UserProfile connection) {
    final currentUserLocation =
        Get.find<UserProfile>().locationName?.toLowerCase();
    final connectionLocation = connection.locationName?.toLowerCase();

    return currentUserLocation != null &&
        connectionLocation != null &&
        currentUserLocation == connectionLocation;
  }

  // Belirli bir kategorideki tüm bağlantıları getir
  List<String> getConnectionsByCategory(ConnectionCategory category) {
    return _connectionCategories.entries
        .where((entry) => entry.value == category)
        .map((entry) => entry.key)
        .toList();
  }
}
