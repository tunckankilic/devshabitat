import 'package:get/get.dart';
import '../models/user_profile_model.dart';

class SkillGapAnalysis {
  final String skill;
  final double currentLevel;
  final double requiredLevel;
  final String recommendation;

  SkillGapAnalysis({
    required this.skill,
    required this.currentLevel,
    required this.requiredLevel,
    required this.recommendation,
  });
}

class CareerSuggestion {
  final String title;
  final String description;
  final List<String> requiredSkills;
  final double matchScore;
  final String nextStep;

  CareerSuggestion({
    required this.title,
    required this.description,
    required this.requiredSkills,
    required this.matchScore,
    required this.nextStep,
  });
}

class NetworkROI {
  final double connectionGrowthRate;
  final double engagementScore;
  final int newOpportunities;
  final Map<String, double> categoryDistribution;

  NetworkROI({
    required this.connectionGrowthRate,
    required this.engagementScore,
    required this.newOpportunities,
    required this.categoryDistribution,
  });
}

class ProfessionalInsightsService extends GetxService {
  // Yetenek boşluklarını analiz et
  List<SkillGapAnalysis> analyzeSkillGaps(
    UserProfile userProfile,
    Map<String, double> industryBenchmarks,
  ) {
    final List<SkillGapAnalysis> gaps = [];

    for (final benchmark in industryBenchmarks.entries) {
      final skill = benchmark.key;
      final requiredLevel = benchmark.value;

      // Kullanıcının yetenek seviyesini kontrol et
      final hasSkill = userProfile.skills.contains(skill);
      final currentLevel = hasSkill ? 0.6 : 0.0; // Basit seviye tahmini

      if (currentLevel < requiredLevel) {
        gaps.add(
          SkillGapAnalysis(
            skill: skill,
            currentLevel: currentLevel,
            requiredLevel: requiredLevel,
            recommendation: _generateSkillRecommendation(
              skill,
              currentLevel,
              requiredLevel,
            ),
          ),
        );
      }
    }

    return gaps;
  }

  // Kariyer önerileri oluştur
  List<CareerSuggestion> generateCareerSuggestions(UserProfile userProfile) {
    final suggestions = <CareerSuggestion>[];

    // Yazılım geliştirme rolleri için öneriler
    if (userProfile.skills
        .any((s) => s.toLowerCase().contains('programlama'))) {
      suggestions.add(
        CareerSuggestion(
          title: 'Senior Yazılım Geliştirici',
          description: 'Teknik liderlik ve mimari tasarım sorumlulukları',
          requiredSkills: ['Sistem Tasarımı', 'Kod İnceleme', 'Mentorluk'],
          matchScore: 0.8,
          nextStep: 'Sistem tasarımı ve mimari konularında deneyim kazanın',
        ),
      );
    }

    // Yönetim rolleri için öneriler
    if (userProfile.yearsOfExperience >= 5) {
      suggestions.add(
        CareerSuggestion(
          title: 'Teknik Takım Lideri',
          description: 'Teknik ekip yönetimi ve proje koordinasyonu',
          requiredSkills: ['Liderlik', 'Proje Yönetimi', 'İletişim'],
          matchScore: 0.7,
          nextStep: 'Küçük ekip yönetimi deneyimi kazanın',
        ),
      );
    }

    return suggestions;
  }

  // Network ROI hesapla
  NetworkROI calculateNetworkingROI(
    UserProfile userProfile,
    List<String> recentConnections,
    Map<String, int> opportunities,
  ) {
    // Bağlantı büyüme oranı
    final initialConnections = userProfile.skills.length;
    final newConnections = recentConnections.length;
    final growthRate = initialConnections > 0
        ? (newConnections / initialConnections) * 100
        : 0.0;

    // Kategori dağılımı
    final categoryDist = <String, double>{
      'Teknoloji': 0.4,
      'Yönetim': 0.3,
      'İş Geliştirme': 0.2,
      'Diğer': 0.1,
    };

    return NetworkROI(
      connectionGrowthRate: growthRate,
      engagementScore: _calculateEngagementScore(userProfile),
      newOpportunities: opportunities.length,
      categoryDistribution: categoryDist,
    );
  }

  // Network ipuçları al
  List<String> getNetworkingTips(UserProfile userProfile) {
    final tips = <String>[
      'Haftalık en az bir network etkinliğine katılın',
      'LinkedIn profilinizi güncel tutun ve düzenli içerik paylaşın',
      'Mevcut bağlantılarınızla düzenli olarak iletişimde kalın',
      'Sektör konferanslarını takip edin ve katılım sağlayın',
      'Mentorluk programlarına katılın veya mentor olun',
    ];

    // Deneyim seviyesine göre özel ipuçları
    if (userProfile.yearsOfExperience < 3) {
      tips.add('Junior toplulukları ve etkinlikleri takip edin');
      tips.add('Online eğitim platformlarında aktif olun');
    } else if (userProfile.yearsOfExperience >= 5) {
      tips.add('Konferanslarda konuşmacı olarak yer almayı düşünün');
      tips.add('Teknik blog yazıları yazın ve deneyimlerinizi paylaşın');
    }

    return tips;
  }

  // YARDIMCI METODLAR

  String _generateSkillRecommendation(
    String skill,
    double currentLevel,
    double requiredLevel,
  ) {
    final gap = requiredLevel - currentLevel;

    if (gap > 0.7) {
      return '$skill konusunda temel eğitimlerle başlayın';
    } else if (gap > 0.4) {
      return '$skill konusunda pratik projeler geliştirin';
    } else {
      return '$skill konusunda ileri seviye konulara odaklanın';
    }
  }

  double _calculateEngagementScore(UserProfile userProfile) {
    var score = 0.0;

    // Profil tamamlama puanı
    if (userProfile.bio?.isNotEmpty ?? false) score += 0.2;
    if (userProfile.skills.isNotEmpty) score += 0.2;
    if (userProfile.title?.isNotEmpty ?? false) score += 0.1;
    if (userProfile.company?.isNotEmpty ?? false) score += 0.1;
    if (userProfile.location != null) score += 0.1;
    if (userProfile.isAvailableForWork) score += 0.1;
    if (userProfile.lastActive != null) {
      final daysSinceLastActive =
          DateTime.now().difference(userProfile.lastActive!).inDays;
      if (daysSinceLastActive < 7) score += 0.2;
    }

    return score;
  }
}
