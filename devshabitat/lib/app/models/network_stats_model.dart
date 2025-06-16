import 'package:cloud_firestore/cloud_firestore.dart';

class NetworkStatsModel {
  final int totalConnections;
  final double weeklyGrowth;
  final double acceptanceRate;
  final List<String> topSkills;
  final DateTime lastUpdated;
  final Map<String, int> skillDistribution;
  final Map<String, double> growthTrends;

  NetworkStatsModel({
    required this.totalConnections,
    required this.weeklyGrowth,
    required this.acceptanceRate,
    required this.topSkills,
    required this.lastUpdated,
    this.skillDistribution = const {},
    this.growthTrends = const {},
  });

  // Firestore'dan model oluştur
  factory NetworkStatsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NetworkStatsModel.fromMap(data);
  }

  // Map'ten model oluştur
  factory NetworkStatsModel.fromMap(Map<String, dynamic> map) {
    return NetworkStatsModel(
      totalConnections: map['totalConnections'] as int? ?? 0,
      weeklyGrowth: (map['weeklyGrowth'] as num?)?.toDouble() ?? 0.0,
      acceptanceRate: (map['acceptanceRate'] as num?)?.toDouble() ?? 0.0,
      topSkills: List<String>.from(map['topSkills'] ?? []),
      lastUpdated:
          (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      skillDistribution: Map<String, int>.from(map['skillDistribution'] ?? {}),
      growthTrends: Map<String, double>.from(map['growthTrends'] ?? {}),
    );
  }

  // Model'i Map'e dönüştür
  Map<String, dynamic> toMap() {
    return {
      'totalConnections': totalConnections,
      'weeklyGrowth': weeklyGrowth,
      'acceptanceRate': acceptanceRate,
      'topSkills': topSkills,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'skillDistribution': skillDistribution,
      'growthTrends': growthTrends,
    };
  }

  // Firestore için Map'e dönüştür
  Map<String, dynamic> toFirestore() {
    return toMap();
  }

  // Yeni bir kopya oluştur
  NetworkStatsModel copyWith({
    int? totalConnections,
    double? weeklyGrowth,
    double? acceptanceRate,
    List<String>? topSkills,
    DateTime? lastUpdated,
    Map<String, int>? skillDistribution,
    Map<String, double>? growthTrends,
  }) {
    return NetworkStatsModel(
      totalConnections: totalConnections ?? this.totalConnections,
      weeklyGrowth: weeklyGrowth ?? this.weeklyGrowth,
      acceptanceRate: acceptanceRate ?? this.acceptanceRate,
      topSkills: topSkills ?? List.from(this.topSkills),
      lastUpdated: lastUpdated ?? this.lastUpdated,
      skillDistribution: skillDistribution ?? Map.from(this.skillDistribution),
      growthTrends: growthTrends ?? Map.from(this.growthTrends),
    );
  }

  // Özet bilgi
  @override
  String toString() {
    return '''NetworkStatsModel(
      totalConnections: $totalConnections,
      weeklyGrowth: $weeklyGrowth%,
      acceptanceRate: $acceptanceRate%,
      topSkills: $topSkills,
      lastUpdated: $lastUpdated,
      skillDistribution: $skillDistribution,
      growthTrends: $growthTrends
    )''';
  }

  // Eşitlik kontrolü
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NetworkStatsModel &&
        other.totalConnections == totalConnections &&
        other.weeklyGrowth == weeklyGrowth &&
        other.acceptanceRate == acceptanceRate &&
        other.lastUpdated == lastUpdated &&
        _listEquals(other.topSkills, topSkills) &&
        _mapEquals(other.skillDistribution, skillDistribution) &&
        _mapEquals(other.growthTrends, growthTrends);
  }

  @override
  int get hashCode {
    return Object.hash(
      totalConnections,
      weeklyGrowth,
      acceptanceRate,
      lastUpdated,
      Object.hashAll(topSkills),
      Object.hashAll(skillDistribution.entries),
      Object.hashAll(growthTrends.entries),
    );
  }

  // Yardımcı metodlar
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    return a.entries.every((e) => b[e.key] == e.value);
  }

  // Factory metodlar
  factory NetworkStatsModel.empty() {
    return NetworkStatsModel(
      totalConnections: 0,
      weeklyGrowth: 0.0,
      acceptanceRate: 0.0,
      topSkills: [],
      lastUpdated: DateTime.now(),
    );
  }

  factory NetworkStatsModel.initial() {
    return NetworkStatsModel(
      totalConnections: 0,
      weeklyGrowth: 0.0,
      acceptanceRate: 0.0,
      topSkills: [],
      lastUpdated: DateTime.now(),
      skillDistribution: {},
      growthTrends: {
        'daily': 0.0,
        'weekly': 0.0,
        'monthly': 0.0,
      },
    );
  }
}
