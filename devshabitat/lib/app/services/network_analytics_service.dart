import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:get/get.dart';
import '../models/connection_model.dart';
import '../models/skill_model.dart';

class NetworkStats {
  final int totalConnections;
  final int pendingConnections;
  final int acceptedConnections;
  final int declinedConnections;
  final double connectionSuccessRate;
  final int networkReach;
  final List<String> topSkills;
  final Map<String, int> skillDistribution;
  final List<String> commonInterests;
  final double networkGrowthRate;

  NetworkStats({
    required this.totalConnections,
    required this.pendingConnections,
    required this.acceptedConnections,
    required this.declinedConnections,
    required this.connectionSuccessRate,
    required this.networkReach,
    required this.topSkills,
    required this.skillDistribution,
    required this.commonInterests,
    required this.networkGrowthRate,
  });
}

class ConnectionGrowthData {
  final String period;
  final int connections;
  final DateTime date;

  ConnectionGrowthData({
    required this.period,
    required this.connections,
    required this.date,
  });
}

class SkillPopularityData {
  final String skill;
  final int userCount;
  final double percentage;
  final SkillCategory category;

  SkillPopularityData({
    required this.skill,
    required this.userCount,
    required this.percentage,
    required this.category,
  });
}

class NetworkInsight {
  final String title;
  final String description;
  final String type;
  final double score;
  final List<String> recommendations;

  NetworkInsight({
    required this.title,
    required this.description,
    required this.type,
    required this.score,
    required this.recommendations,
  });
}

class NetworkAnalyticsService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Get.find<Logger>();

  // Basit network istatistikleri hesapla
  Future<NetworkStats> calculateNetworkStats(String userId) async {
    try {
      // Kullanıcının bağlantılarını getir
      final connectionsQuery = await _firestore
          .collection('connections')
          .where('fromUserId', isEqualTo: userId)
          .get();

      final incomingConnectionsQuery = await _firestore
          .collection('connections')
          .where('toUserId', isEqualTo: userId)
          .get();

      // Temel sayıları hesapla
      final allConnections = [
        ...connectionsQuery.docs,
        ...incomingConnectionsQuery.docs
      ];
      final totalConnections = allConnections.length;

      int pendingCount = 0;
      int acceptedCount = 0;
      int declinedCount = 0;

      for (final doc in allConnections) {
        final connection = ConnectionModel.fromFirestore(doc);
        switch (connection.status) {
          case ConnectionStatus.pending:
            pendingCount++;
            break;
          case ConnectionStatus.accepted:
            acceptedCount++;
            break;
          case ConnectionStatus.declined:
            declinedCount++;
            break;
          case ConnectionStatus.blocked:
            declinedCount++;
            break;
        }
      }

      // Başarı oranını hesapla
      final connectionSuccessRate =
          totalConnections > 0 ? (acceptedCount / totalConnections) * 100 : 0.0;

      // Network reach hesapla (ikinci derece bağlantılar)
      final networkReach = await _calculateNetworkReach(userId);

      // Top skills hesapla
      final topSkills = await _getTopSkillsForUser(userId);

      // Skill dağılımını hesapla
      final skillDistribution = await _calculateSkillDistribution(userId);

      // Ortak ilgileri bul
      final commonInterests = await _getCommonInterests(userId);

      // Growth rate hesapla
      final networkGrowthRate = await _calculateNetworkGrowthRate(userId);

      return NetworkStats(
        totalConnections: totalConnections,
        pendingConnections: pendingCount,
        acceptedConnections: acceptedCount,
        declinedConnections: declinedCount,
        connectionSuccessRate: connectionSuccessRate,
        networkReach: networkReach,
        topSkills: topSkills,
        skillDistribution: skillDistribution,
        commonInterests: commonInterests,
        networkGrowthRate: networkGrowthRate,
      );
    } catch (e) {
      _logger.e('Network istatistikleri hesaplanırken hata: $e');
      throw Exception('Network istatistikleri hesaplanamadı');
    }
  }

  // Bağlantı büyüme verilerini getir
  Future<List<ConnectionGrowthData>> getConnectionGrowthData({
    String? userId,
    int daysBack = 30,
  }) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: daysBack));

      final queryBuilder = _firestore
          .collection('connections')
          .where('status', isEqualTo: 'accepted')
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

      // Kullanıcı belirtilmişse filtrele
      final query = userId != null
          ? queryBuilder.where('fromUserId', isEqualTo: userId)
          : queryBuilder;

      final connections = await query.get();

      // Günlük bazda grupla
      final Map<String, int> dailyCounts = {};

      for (final doc in connections.docs) {
        final connection = ConnectionModel.fromFirestore(doc);
        final dateKey = _formatDateKey(connection.createdAt);
        dailyCounts[dateKey] = (dailyCounts[dateKey] ?? 0) + 1;
      }

      // Sonuçları sırala ve döndür
      final result = dailyCounts.entries
          .map((entry) => ConnectionGrowthData(
                period: entry.key,
                connections: entry.value,
                date: DateTime.parse(entry.key),
              ))
          .toList();

      result.sort((a, b) => a.date.compareTo(b.date));
      return result;
    } catch (e) {
      _logger.e('Bağlantı büyüme verileri alınırken hata: $e');
      return [];
    }
  }

  // Skill popülerliğini hesapla
  Future<List<SkillPopularityData>> getSkillPopularity() async {
    try {
      final usersQuery = await _firestore.collection('users').get();
      final Map<String, int> skillCounts = {};
      final Map<String, SkillCategory> skillCategories = {};
      int totalUsers = usersQuery.docs.length;

      // Tüm kullanıcıların skilllerini say
      for (final doc in usersQuery.docs) {
        final userData = doc.data();
        final skills = List<String>.from(userData['skills'] ?? []);

        for (final skill in skills) {
          skillCounts[skill] = (skillCounts[skill] ?? 0) + 1;
          // Skill kategorisini tahmin et
          skillCategories[skill] ??= _guessSkillCategory(skill);
        }
      }

      // Yüzdelik hesapla ve sırala
      final skillPopularity = skillCounts.entries
          .map((entry) => SkillPopularityData(
                skill: entry.key,
                userCount: entry.value,
                percentage: (entry.value / totalUsers) * 100,
                category: skillCategories[entry.key] ?? SkillCategory.other,
              ))
          .toList();

      // Popülerliğe göre sırala
      skillPopularity.sort((a, b) => b.userCount.compareTo(a.userCount));

      return skillPopularity.take(20).toList(); // Top 20 skill
    } catch (e) {
      _logger.e('Skill popülerliği hesaplanırken hata: $e');
      return [];
    }
  }

  // Network içgörüleri üret
  Future<List<NetworkInsight>> generateNetworkInsights(String userId) async {
    try {
      final stats = await calculateNetworkStats(userId);
      final insights = <NetworkInsight>[];

      // Bağlantı başarı oranı analizi
      if (stats.connectionSuccessRate > 80) {
        insights.add(NetworkInsight(
          title: 'Mükemmel Bağlantı Başarısı',
          description:
              'Bağlantı taleplerinin %${stats.connectionSuccessRate.toInt()}\'i kabul ediliyor.',
          type: 'success',
          score: stats.connectionSuccessRate,
          recommendations: [
            'Bu başarıyı sürdürmek için profil kalitenizi koruyun',
            'Daha fazla bağlantı kurmaya devam edin'
          ],
        ));
      } else if (stats.connectionSuccessRate < 50) {
        insights.add(NetworkInsight(
          title: 'Bağlantı Başarısını Artırın',
          description:
              'Bağlantı başarı oranınız %${stats.connectionSuccessRate.toInt()}. İyileştirme gerekli.',
          type: 'warning',
          score: stats.connectionSuccessRate,
          recommendations: [
            'Profil fotoğrafınızı güncelleyin',
            'Bio kısmınızı daha detaylandırın',
            'Ortak projelerinizi paylaşın'
          ],
        ));
      }

      // Network büyüklüğü analizi
      if (stats.totalConnections < 10) {
        insights.add(NetworkInsight(
          title: 'Network Genişletme Fırsatı',
          description:
              'Sadece ${stats.totalConnections} bağlantınız var. Network\'ünüzü genişletin.',
          type: 'suggestion',
          score: stats.totalConnections.toDouble(),
          recommendations: [
            'Discovery özelliğini daha sık kullanın',
            'Alakalı projeler paylaşın',
            'Aktif olarak bağlantı kurun'
          ],
        ));
      } else if (stats.totalConnections > 100) {
        insights.add(NetworkInsight(
          title: 'Güçlü Network',
          description:
              '${stats.totalConnections} bağlantı ile güçlü bir network\'ünüz var.',
          type: 'success',
          score: stats.totalConnections.toDouble(),
          recommendations: [
            'Bağlantılarınızla etkileşimi artırın',
            'Mentorship fırsatları arayın'
          ],
        ));
      }

      // Skill çeşitliliği analizi
      if (stats.topSkills.length > 5) {
        insights.add(NetworkInsight(
          title: 'Çeşitli Skill Seti',
          description:
              '${stats.topSkills.length} farklı alanda yetenekleriniz var.',
          type: 'success',
          score: stats.topSkills.length.toDouble(),
          recommendations: [
            'Skill\'lerinizi projektelerinizde gösterin',
            'Cross-functional ekiplerde yer alın'
          ],
        ));
      }

      // Growth rate analizi
      if (stats.networkGrowthRate > 20) {
        insights.add(NetworkInsight(
          title: 'Hızlı Büyüyen Network',
          description:
              'Network\'ünüz %${stats.networkGrowthRate.toInt()} oranında büyüyor.',
          type: 'success',
          score: stats.networkGrowthRate,
          recommendations: [
            'Bu momentum\'u sürdürün',
            'Kaliteli bağlantılara odaklanın'
          ],
        ));
      } else if (stats.networkGrowthRate < 5) {
        insights.add(NetworkInsight(
          title: 'Network Büyümesi Yavaş',
          description:
              'Network büyüme hızınız %${stats.networkGrowthRate.toInt()}. Daha aktif olun.',
          type: 'warning',
          score: stats.networkGrowthRate,
          recommendations: [
            'Haftalık bağlantı hedefi koyun',
            'Etkinliklere katılın',
            'Profilinizdeki bilgileri güncelleyin'
          ],
        ));
      }

      return insights;
    } catch (e) {
      _logger.e('Network içgörüleri oluşturulurken hata: $e');
      return [];
    }
  }

  // Yardımcı metodlar
  Future<int> _calculateNetworkReach(String userId) async {
    try {
      // Direkt bağlantıları al
      final directConnections = await _firestore
          .collection('connections')
          .where('fromUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'accepted')
          .get();

      final Set<String> secondDegreeConnections = {};

      // Her direkt bağlantının bağlantılarını al
      for (final doc in directConnections.docs) {
        final connection = ConnectionModel.fromFirestore(doc);
        final friendConnections = await _firestore
            .collection('connections')
            .where('fromUserId', isEqualTo: connection.toUserId)
            .where('status', isEqualTo: 'accepted')
            .get();

        for (final friendDoc in friendConnections.docs) {
          final friendConnection = ConnectionModel.fromFirestore(friendDoc);
          if (friendConnection.toUserId != userId) {
            secondDegreeConnections.add(friendConnection.toUserId);
          }
        }
      }

      return directConnections.docs.length + secondDegreeConnections.length;
    } catch (e) {
      _logger.e('Network reach hesaplanırken hata: $e');
      return 0;
    }
  }

  Future<List<String>> _getTopSkillsForUser(String userId) async {
    try {
      // Kullanıcının bağlantılarının en çok kullandığı skill'leri bul
      final connections = await _firestore
          .collection('connections')
          .where('fromUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'accepted')
          .get();

      final Map<String, int> skillCounts = {};

      for (final doc in connections.docs) {
        final connection = ConnectionModel.fromFirestore(doc);
        final userDoc =
            await _firestore.collection('users').doc(connection.toUserId).get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final skills = List<String>.from(userData['skills'] ?? []);

          for (final skill in skills) {
            skillCounts[skill] = (skillCounts[skill] ?? 0) + 1;
          }
        }
      }

      // En popüler 5 skill'i döndür
      final sortedSkills = skillCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedSkills.take(5).map((e) => e.key).toList();
    } catch (e) {
      _logger.e('Top skills hesaplanırken hata: $e');
      return [];
    }
  }

  Future<Map<String, int>> _calculateSkillDistribution(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return {};

      final userData = userDoc.data()!;
      final skills = List<String>.from(userData['skills'] ?? []);

      final Map<String, int> distribution = {};

      for (final skill in skills) {
        final category = _guessSkillCategory(skill);
        final categoryName = category.toString().split('.').last;
        distribution[categoryName] = (distribution[categoryName] ?? 0) + 1;
      }

      return distribution;
    } catch (e) {
      _logger.e('Skill dağılımı hesaplanırken hata: $e');
      return {};
    }
  }

  Future<List<String>> _getCommonInterests(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return [];

      final userData = userDoc.data()!;
      final userInterests = List<String>.from(userData['interests'] ?? []);

      if (userInterests.isEmpty) return [];

      // Kullanıcının bağlantılarının ilgilerini al
      final connections = await _firestore
          .collection('connections')
          .where('fromUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'accepted')
          .limit(20) // Performans için sınırla
          .get();

      final Map<String, int> interestCounts = {};

      for (final doc in connections.docs) {
        final connection = ConnectionModel.fromFirestore(doc);
        final connectionUserDoc =
            await _firestore.collection('users').doc(connection.toUserId).get();

        if (connectionUserDoc.exists) {
          final connectionUserData = connectionUserDoc.data()!;
          final connectionInterests =
              List<String>.from(connectionUserData['interests'] ?? []);

          // Ortak ilgileri say
          for (final interest in connectionInterests) {
            if (userInterests.contains(interest)) {
              interestCounts[interest] = (interestCounts[interest] ?? 0) + 1;
            }
          }
        }
      }

      // En yaygın ortak ilgileri döndür
      final sortedInterests = interestCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedInterests.take(5).map((e) => e.key).toList();
    } catch (e) {
      _logger.e('Ortak ilgiler hesaplanırken hata: $e');
      return [];
    }
  }

  Future<double> _calculateNetworkGrowthRate(String userId) async {
    try {
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      final sixtyDaysAgo = now.subtract(const Duration(days: 60));

      // Son 30 günün bağlantıları
      final recentConnections = await _firestore
          .collection('connections')
          .where('fromUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'accepted')
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      // Önceki 30 günün bağlantıları
      final previousConnections = await _firestore
          .collection('connections')
          .where('fromUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'accepted')
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(sixtyDaysAgo))
          .where('createdAt', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      final recentCount = recentConnections.docs.length;
      final previousCount = previousConnections.docs.length;

      if (previousCount == 0) {
        return recentCount > 0 ? 100.0 : 0.0;
      }

      return ((recentCount - previousCount) / previousCount) * 100;
    } catch (e) {
      _logger.e('Network growth rate hesaplanırken hata: $e');
      return 0.0;
    }
  }

  SkillCategory _guessSkillCategory(String skill) {
    final skillLower = skill.toLowerCase();

    // Programming languages
    if ([
      'dart',
      'flutter',
      'python',
      'javascript',
      'java',
      'c++',
      'c#',
      'go',
      'rust',
      'kotlin',
      'swift'
    ].contains(skillLower)) {
      return SkillCategory.programming;
    }

    // Frameworks
    if ([
      'react',
      'angular',
      'vue',
      'express',
      'spring',
      'django',
      'fastapi',
      'nestjs'
    ].contains(skillLower)) {
      return SkillCategory.framework;
    }

    // Databases
    if (['mysql', 'postgresql', 'mongodb', 'redis', 'firebase', 'supabase']
        .contains(skillLower)) {
      return SkillCategory.database;
    }

    // Cloud
    if (['aws', 'gcp', 'azure', 'docker', 'kubernetes'].contains(skillLower)) {
      return SkillCategory.cloud;
    }

    // DevOps
    if (['jenkins', 'github actions', 'gitlab ci', 'terraform']
        .contains(skillLower)) {
      return SkillCategory.devops;
    }

    // Design
    if (['figma', 'photoshop', 'sketch', 'ui/ux', 'design']
        .contains(skillLower)) {
      return SkillCategory.design;
    }

    return SkillCategory.other;
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
