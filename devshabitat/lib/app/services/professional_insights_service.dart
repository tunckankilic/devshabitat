import 'package:get/get.dart';
import '../models/user_profile_model.dart';

// Additional model classes for portfolio controller
class NetworkingStrategy {
  final String title;
  final String description;
  final List<String> platforms;
  final List<String> targetGroups;
  final String timeCommitment;
  final double expectedROI;

  NetworkingStrategy({
    required this.title,
    required this.description,
    required this.platforms,
    required this.targetGroups,
    required this.timeCommitment,
    required this.expectedROI,
  });
}

class CourseRecommendation {
  final String title;
  final String provider;
  final String difficulty;
  final int durationHours;
  final double rating;
  final String url;
  final List<String> skillsGained;

  CourseRecommendation({
    required this.title,
    required this.provider,
    required this.difficulty,
    required this.durationHours,
    required this.rating,
    required this.url,
    required this.skillsGained,
  });
}

class ProjectIdea {
  final String title;
  final String description;
  final List<String> technologies;
  final String difficulty;
  final int estimatedDays;

  ProjectIdea({
    required this.title,
    required this.description,
    required this.technologies,
    required this.difficulty,
    required this.estimatedDays,
  });
}

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
  final String category;
  final String level;
  final Map<String, dynamic> salaryRange;
  final double marketDemand;
  final List<String> learningPath;
  final int timeToAchieve; // months
  final List<String> companies;

  CareerSuggestion({
    required this.title,
    required this.description,
    required this.requiredSkills,
    required this.matchScore,
    required this.nextStep,
    required this.category,
    required this.level,
    required this.salaryRange,
    required this.marketDemand,
    required this.learningPath,
    required this.timeToAchieve,
    required this.companies,
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

// New models for enhanced insights
class CertificationRecommendation {
  final String name;
  final String provider;
  final String difficulty;
  final int estimatedHours;
  final double costRange;
  final double careerImpact;
  final List<String> prerequisites;
  final String validityPeriod;
  final List<String> skillsGained;

  CertificationRecommendation({
    required this.name,
    required this.provider,
    required this.difficulty,
    required this.estimatedHours,
    required this.costRange,
    required this.careerImpact,
    required this.prerequisites,
    required this.validityPeriod,
    required this.skillsGained,
  });
}

class IndustryTrend {
  final String technology;
  final String trendType; // 'rising', 'stable', 'declining'
  final double growthRate;
  final int demandScore;
  final List<String> keyDrivers;
  final Map<String, double> salaryTrends;
  final List<String> topCompanies;

  IndustryTrend({
    required this.technology,
    required this.trendType,
    required this.growthRate,
    required this.demandScore,
    required this.keyDrivers,
    required this.salaryTrends,
    required this.topCompanies,
  });
}

class PortfolioRecommendation {
  final String projectType;
  final String title;
  final String description;
  final List<String> technologies;
  final String difficulty;
  final int estimatedDays;
  final double careerBoost;
  final List<String> learningObjectives;
  final List<String> showcasePoints;

  PortfolioRecommendation({
    required this.projectType,
    required this.title,
    required this.description,
    required this.technologies,
    required this.difficulty,
    required this.estimatedDays,
    required this.careerBoost,
    required this.learningObjectives,
    required this.showcasePoints,
  });
}

class InterviewPreparation {
  final String role;
  final List<String> technicalTopics;
  final List<String> behavioralQuestions;
  final List<String> codingChallenges;
  final Map<String, List<String>> companySpecificPrep;
  final List<String> portfolioHighlights;

  InterviewPreparation({
    required this.role,
    required this.technicalTopics,
    required this.behavioralQuestions,
    required this.codingChallenges,
    required this.companySpecificPrep,
    required this.portfolioHighlights,
  });
}

class MarketAnalytics {
  final String region;
  final Map<String, double> averageSalaries;
  final Map<String, int> jobOpenings;
  final Map<String, double> salaryGrowth;
  final List<String> hotSkills;
  final Map<String, double> skillPremium;

  MarketAnalytics({
    required this.region,
    required this.averageSalaries,
    required this.jobOpenings,
    required this.salaryGrowth,
    required this.hotSkills,
    required this.skillPremium,
  });
}

class NetworkingRecommendation {
  final String strategy;
  final List<String> targetCompanies;
  final List<String> relevantEvents;
  final List<String> onlineCommunities;
  final List<String> keyPeople;
  final List<String> contentTopics;

  NetworkingRecommendation({
    required this.strategy,
    required this.targetCompanies,
    required this.relevantEvents,
    required this.onlineCommunities,
    required this.keyPeople,
    required this.contentTopics,
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

  // Kariyer önerileri oluştur - AI Enhanced
  List<CareerSuggestion> generateCareerSuggestions(UserProfile userProfile) {
    final suggestions = <CareerSuggestion>[];
    final skillSet = userProfile.skills.map((s) => s.toLowerCase()).toSet();
    final experience = userProfile.yearsOfExperience;

    // 1. Frontend Development Path
    if (_hasSkills(
        skillSet, ['react', 'javascript', 'typescript', 'frontend'])) {
      suggestions.addAll(_getFrontendCareerPath(skillSet, experience));
    }

    // 2. Backend Development Path
    if (_hasSkills(skillSet, ['backend', 'api', 'database', 'server'])) {
      suggestions.addAll(_getBackendCareerPath(skillSet, experience));
    }

    // 3. Mobile Development Path
    if (_hasSkills(
        skillSet, ['flutter', 'react native', 'ios', 'android', 'mobile'])) {
      suggestions.addAll(_getMobileCareerPath(skillSet, experience));
    }

    // 4. DevOps/Cloud Path
    if (_hasSkills(
        skillSet, ['docker', 'kubernetes', 'aws', 'cloud', 'devops'])) {
      suggestions.addAll(_getDevOpsCareerPath(skillSet, experience));
    }

    // 5. Data Science/AI Path
    if (_hasSkills(skillSet, ['python', 'machine learning', 'data', 'ai'])) {
      suggestions.addAll(_getDataScienceCareerPath(skillSet, experience));
    }

    // 6. Management/Leadership Path
    if (experience >= 3) {
      suggestions.addAll(_getLeadershipCareerPath(skillSet, experience));
    }

    // 7. Emerging Tech Paths
    suggestions.addAll(_getEmergingTechCareerPath(skillSet, experience));

    // Sort by match score and return top suggestions
    suggestions.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return suggestions.take(8).toList();
  }

  // NEW: Certification Roadmap
  List<CertificationRecommendation> generateCertificationRoadmap(
      UserProfile userProfile) {
    final recommendations = <CertificationRecommendation>[];
    final skills = userProfile.skills.map((s) => s.toLowerCase()).toSet();
    final experience = userProfile.yearsOfExperience;

    // Frontend Certifications
    if (_hasSkills(skills, ['react', 'javascript', 'frontend'])) {
      recommendations.addAll(_getFrontendCertifications(experience));
    }

    // Backend Certifications
    if (_hasSkills(skills, ['backend', 'node', 'python', 'java'])) {
      recommendations.addAll(_getBackendCertifications(experience));
    }

    // Cloud Certifications
    if (_hasSkills(skills, ['aws', 'azure', 'cloud', 'devops'])) {
      recommendations.addAll(_getCloudCertifications(experience));
    }

    // Mobile Certifications
    if (_hasSkills(skills, ['flutter', 'mobile', 'android', 'ios'])) {
      recommendations.addAll(_getMobileCertifications(experience));
    }

    return recommendations
      ..sort((a, b) => b.careerImpact.compareTo(a.careerImpact));
  }

  // NEW: Industry Trends Analysis
  List<IndustryTrend> analyzeIndustryTrends() {
    return [
      IndustryTrend(
        technology: 'Flutter',
        trendType: 'rising',
        growthRate: 0.35,
        demandScore: 85,
        keyDrivers: [
          'Cross-platform efficiency',
          'Google backing',
          'Performance improvements'
        ],
        salaryTrends: {'2024': 75000, '2025': 85000, '2026': 95000},
        topCompanies: ['Google', 'Alibaba', 'Tencent', 'BMW'],
      ),
      IndustryTrend(
        technology: 'AI/Machine Learning',
        trendType: 'rising',
        growthRate: 0.42,
        demandScore: 95,
        keyDrivers: [
          'ChatGPT revolution',
          'Enterprise AI adoption',
          'Automation needs'
        ],
        salaryTrends: {'2024': 90000, '2025': 110000, '2026': 130000},
        topCompanies: ['OpenAI', 'Google', 'Microsoft', 'Meta'],
      ),
      IndustryTrend(
        technology: 'React/Next.js',
        trendType: 'stable',
        growthRate: 0.15,
        demandScore: 90,
        keyDrivers: [
          'Mature ecosystem',
          'Enterprise adoption',
          'Performance optimization'
        ],
        salaryTrends: {'2024': 70000, '2025': 75000, '2026': 80000},
        topCompanies: ['Meta', 'Netflix', 'Airbnb', 'Uber'],
      ),
      IndustryTrend(
        technology: 'Blockchain/Web3',
        trendType: 'declining',
        growthRate: -0.20,
        demandScore: 60,
        keyDrivers: [
          'Market consolidation',
          'Regulatory uncertainty',
          'Focus shift'
        ],
        salaryTrends: {'2024': 95000, '2025': 85000, '2026': 80000},
        topCompanies: ['Coinbase', 'Binance', 'ConsenSys', 'Chainlink'],
      ),
    ];
  }

  // NEW: Portfolio Project Recommendations
  List<PortfolioRecommendation> generatePortfolioRecommendations(
      UserProfile userProfile) {
    final recommendations = <PortfolioRecommendation>[];
    final skills = userProfile.skills.map((s) => s.toLowerCase()).toSet();
    final experience = userProfile.yearsOfExperience;

    if (_hasSkills(skills, ['flutter', 'mobile'])) {
      recommendations.addAll(_getFlutterPortfolioProjects(experience));
    }

    if (_hasSkills(skills, ['react', 'frontend'])) {
      recommendations.addAll(_getReactPortfolioProjects(experience));
    }

    if (_hasSkills(skills, ['backend', 'api'])) {
      recommendations.addAll(_getBackendPortfolioProjects(experience));
    }

    if (_hasSkills(skills, ['ai', 'machine learning', 'python'])) {
      recommendations.addAll(_getAIPortfolioProjects(experience));
    }

    return recommendations
      ..sort((a, b) => b.careerBoost.compareTo(a.careerBoost));
  }

  // NEW: Interview Preparation Guide
  InterviewPreparation generateInterviewPrep(String targetRole) {
    final prepGuides = {
      'Flutter Developer': InterviewPreparation(
        role: 'Flutter Developer',
        technicalTopics: [
          'Dart language fundamentals',
          'Widget lifecycle and state management',
          'Performance optimization',
          'Platform channels and native integration',
          'Testing strategies',
        ],
        behavioralQuestions: [
          'Describe a challenging Flutter project you worked on',
          'How do you handle state management in large apps?',
          'Experience with cross-platform development challenges',
        ],
        codingChallenges: [
          'Build a responsive UI with custom widgets',
          'Implement state management pattern',
          'Create custom animations',
          'Handle API integration and error states',
        ],
        companySpecificPrep: {
          'Google': [
            'Material Design principles',
            'Large-scale app architecture'
          ],
          'Startup': ['Rapid prototyping', 'Lean development practices'],
          'Enterprise': ['Security considerations', 'Scalability planning'],
        },
        portfolioHighlights: [
          'Cross-platform app with native features',
          'Complex state management implementation',
          'Performance-optimized applications',
        ],
      ),
      'Senior Frontend Developer': InterviewPreparation(
        role: 'Senior Frontend Developer',
        technicalTopics: [
          'Advanced React patterns and hooks',
          'Performance optimization techniques',
          'Bundle optimization and lazy loading',
          'Accessibility and web standards',
          'Testing strategies and frameworks',
        ],
        behavioralQuestions: [
          'How do you mentor junior developers?',
          'Describe your approach to code reviews',
          'Experience leading technical discussions',
        ],
        codingChallenges: [
          'Build a complex component with performance considerations',
          'Implement advanced state management',
          'Create accessible UI components',
          'Design system architecture',
        ],
        companySpecificPrep: {
          'Big Tech': ['System design', 'Scalability challenges'],
          'Fintech': ['Security practices', 'Compliance considerations'],
          'E-commerce': ['Performance optimization', 'Conversion optimization'],
        },
        portfolioHighlights: [
          'Large-scale applications with complex state',
          'Performance optimization case studies',
          'Open source contributions',
        ],
      ),
    };

    return prepGuides[targetRole] ?? prepGuides['Flutter Developer']!;
  }

  // NEW: Market Analytics
  MarketAnalytics getMarketAnalytics(String region) {
    final marketData = {
      'Turkey': MarketAnalytics(
        region: 'Turkey',
        averageSalaries: {
          'Flutter Developer': 75000,
          'React Developer': 70000,
          'Backend Developer': 80000,
          'DevOps Engineer': 95000,
          'Data Scientist': 85000,
        },
        jobOpenings: {
          'Flutter Developer': 150,
          'React Developer': 300,
          'Backend Developer': 400,
          'DevOps Engineer': 200,
          'Data Scientist': 120,
        },
        salaryGrowth: {
          'Flutter Developer': 0.15,
          'React Developer': 0.10,
          'Backend Developer': 0.12,
          'DevOps Engineer': 0.20,
          'Data Scientist': 0.18,
        },
        hotSkills: [
          'Flutter',
          'React',
          'Python',
          'AWS',
          'Machine Learning',
          'TypeScript'
        ],
        skillPremium: {
          'Flutter': 0.20,
          'Machine Learning': 0.25,
          'AWS': 0.18,
          'TypeScript': 0.15,
          'Docker': 0.12,
        },
      ),
    };

    return marketData[region] ?? marketData['Turkey']!;
  }

  // NEW: Networking Recommendations
  NetworkingRecommendation generateNetworkingStrategy(UserProfile userProfile) {
    final skills = userProfile.skills.map((s) => s.toLowerCase()).toSet();

    if (_hasSkills(skills, ['flutter', 'mobile'])) {
      return NetworkingRecommendation(
        strategy: 'Flutter Community Leadership',
        targetCompanies: ['Google', 'Trendyol', 'Getir', 'BiTaksi'],
        relevantEvents: ['Flutter Festival', 'Mobile DevFest', 'GDG Istanbul'],
        onlineCommunities: [
          'Flutter Turkey',
          'Flutter Discord',
          'r/FlutterDev'
        ],
        keyPeople: [
          'Flutter team members',
          'Google Developer Experts',
          'Tech leads'
        ],
        contentTopics: [
          'Flutter tutorials',
          'Performance tips',
          'Architecture patterns'
        ],
      );
    }

    return NetworkingRecommendation(
      strategy: 'General Tech Community',
      targetCompanies: ['Technology companies in Turkey'],
      relevantEvents: ['Tech meetups', 'Conferences', 'Hackathons'],
      onlineCommunities: ['Dev communities', 'LinkedIn groups'],
      keyPeople: ['Industry leaders', 'Senior developers'],
      contentTopics: ['Technical insights', 'Industry trends'],
    );
  }

  bool _hasSkills(Set<String> userSkills, List<String> requiredSkills) {
    return requiredSkills.any((skill) =>
        userSkills.any((userSkill) => userSkill.contains(skill.toLowerCase())));
  }

  List<CareerSuggestion> _getFrontendCareerPath(
      Set<String> skills, int experience) {
    final suggestions = <CareerSuggestion>[];

    if (experience < 2) {
      suggestions.add(CareerSuggestion(
        title: 'Junior Frontend Developer',
        description:
            'Modern web uygulamaları geliştiren başlangıç seviyesi geliştirici',
        requiredSkills: ['React/Vue.js', 'JavaScript', 'CSS', 'HTML'],
        matchScore: 0.85,
        nextStep: 'React.js ve modern CSS framework\'leri öğrenin',
        category: 'Frontend Development',
        level: 'Junior',
        salaryRange: {'min': 45000, 'max': 65000, 'currency': 'TL'},
        marketDemand: 0.9,
        learningPath: [
          'JavaScript ES6+',
          'React.js',
          'TypeScript',
          'CSS Grid/Flexbox'
        ],
        timeToAchieve: 6,
        companies: ['Trendyol', 'Hepsiburada', 'GittiGidiyor', 'N11'],
      ));
    } else if (experience >= 2 && experience < 5) {
      suggestions.add(CareerSuggestion(
        title: 'Frontend Developer',
        description:
            'Kullanıcı deneyimi odaklı web uygulamaları geliştiren orta seviye geliştirici',
        requiredSkills: [
          'React/Angular/Vue',
          'TypeScript',
          'Testing',
          'Performance Optimization'
        ],
        matchScore: 0.88,
        nextStep: 'Performance optimization ve testing konularında uzmanlaşın',
        category: 'Frontend Development',
        level: 'Mid-Level',
        salaryRange: {'min': 65000, 'max': 95000, 'currency': 'TL'},
        marketDemand: 0.85,
        learningPath: [
          'Advanced React',
          'Testing (Jest/Cypress)',
          'Webpack/Vite',
          'Web Performance'
        ],
        timeToAchieve: 12,
        companies: ['Turkcell', 'Vodafone', 'Aselsan', 'Havelsan'],
      ));
    } else {
      suggestions.add(CareerSuggestion(
        title: 'Senior Frontend Developer / Frontend Architect',
        description:
            'Frontend mimarisi tasarlayan ve ekipleri yönlendiren uzman geliştirici',
        requiredSkills: [
          'System Design',
          'Mentoring',
          'Architecture',
          'Advanced Performance'
        ],
        matchScore: 0.82,
        nextStep: 'Frontend mimari tasarımı ve ekip liderliği deneyimi kazanın',
        category: 'Frontend Development',
        level: 'Senior',
        salaryRange: {'min': 95000, 'max': 150000, 'currency': 'TL'},
        marketDemand: 0.75,
        learningPath: [
          'Micro-frontends',
          'Architecture Patterns',
          'Team Leadership',
          'Code Review'
        ],
        timeToAchieve: 18,
        companies: ['Microsoft Turkey', 'Google Istanbul', 'Amazon', 'Siemens'],
      ));
    }

    return suggestions;
  }

  List<CareerSuggestion> _getBackendCareerPath(
      Set<String> skills, int experience) {
    final suggestions = <CareerSuggestion>[];

    if (experience < 3) {
      suggestions.add(CareerSuggestion(
        title: 'Backend Developer',
        description: 'API ve sunucu tarafı uygulamaları geliştiren geliştirici',
        requiredSkills: ['Node.js/Python/Java', 'Database', 'REST APIs', 'Git'],
        matchScore: 0.87,
        nextStep: 'Mikroservis mimarisi ve Docker konularını öğrenin',
        category: 'Backend Development',
        level: 'Mid-Level',
        salaryRange: {'min': 60000, 'max': 85000, 'currency': 'TL'},
        marketDemand: 0.92,
        learningPath: [
          'Microservices',
          'Docker',
          'Kubernetes',
          'System Design'
        ],
        timeToAchieve: 8,
        companies: ['Yemeksepeti', 'BiTaksi', 'Getir', 'Peak Games'],
      ));
    } else {
      suggestions.add(CareerSuggestion(
        title: 'Senior Backend Developer / System Architect',
        description:
            'Ölçeklenebilir sistem mimarileri tasarlayan uzman geliştirici',
        requiredSkills: [
          'Microservices',
          'Cloud Architecture',
          'Performance Tuning',
          'Security'
        ],
        matchScore: 0.84,
        nextStep:
            'Cloud platformları ve büyük ölçekli sistem tasarımında uzmanlaşın',
        category: 'Backend Development',
        level: 'Senior',
        salaryRange: {'min': 100000, 'max': 180000, 'currency': 'TL'},
        marketDemand: 0.88,
        learningPath: [
          'AWS/Azure/GCP',
          'Scalability',
          'Security Best Practices',
          'Monitoring'
        ],
        timeToAchieve: 15,
        companies: ['Garanti BBVA', 'İş Bankası', 'Akbank', 'QNB Finansbank'],
      ));
    }

    return suggestions;
  }

  List<CareerSuggestion> _getMobileCareerPath(
      Set<String> skills, int experience) {
    final suggestions = <CareerSuggestion>[];

    suggestions.add(CareerSuggestion(
      title: 'Flutter Developer',
      description:
          'Cross-platform mobil uygulamalar geliştiren uzman geliştirici',
      requiredSkills: ['Flutter', 'Dart', 'Firebase', 'State Management'],
      matchScore: 0.90,
      nextStep: 'Advanced Flutter patterns ve performance optimization öğrenin',
      category: 'Mobile Development',
      level: experience < 2
          ? 'Junior'
          : experience < 5
              ? 'Mid-Level'
              : 'Senior',
      salaryRange: {
        'min': 55000 + (experience * 8000),
        'max': 80000 + (experience * 12000),
        'currency': 'TL'
      },
      marketDemand: 0.85,
      learningPath: [
        'Advanced Flutter',
        'Native Integration',
        'App Store Optimization',
        'CI/CD'
      ],
      timeToAchieve: 10,
      companies: ['Turkcell', 'Getir', 'BiTaksi', 'Modanisa'],
    ));

    return suggestions;
  }

  List<CareerSuggestion> _getDevOpsCareerPath(
      Set<String> skills, int experience) {
    final suggestions = <CareerSuggestion>[];

    suggestions.add(CareerSuggestion(
      title: 'DevOps Engineer',
      description: 'CI/CD, altyapı otomasyonu ve bulut teknolojileri uzmanı',
      requiredSkills: [
        'Docker',
        'Kubernetes',
        'AWS/Azure',
        'CI/CD',
        'Infrastructure as Code'
      ],
      matchScore: 0.86,
      nextStep: 'Site Reliability Engineering (SRE) konularında derinleşin',
      category: 'DevOps & Infrastructure',
      level: experience < 3 ? 'Mid-Level' : 'Senior',
      salaryRange: {'min': 80000, 'max': 140000, 'currency': 'TL'},
      marketDemand: 0.95,
      learningPath: [
        'Terraform',
        'Monitoring',
        'Security',
        'Site Reliability Engineering'
      ],
      timeToAchieve: 12,
      companies: ['Amadeus', 'Siemens', 'SAP', 'Oracle'],
    ));

    return suggestions;
  }

  List<CareerSuggestion> _getDataScienceCareerPath(
      Set<String> skills, int experience) {
    final suggestions = <CareerSuggestion>[];

    suggestions.add(CareerSuggestion(
      title: 'Data Scientist / ML Engineer',
      description:
          'Makine öğrenmesi modelleri geliştiren ve veri analizi yapan uzman',
      requiredSkills: [
        'Python',
        'Machine Learning',
        'TensorFlow/PyTorch',
        'Data Analysis'
      ],
      matchScore: 0.83,
      nextStep: 'Deep learning ve büyük veri işleme konularında uzmanlaşın',
      category: 'Data Science & AI',
      level: experience < 2
          ? 'Junior'
          : experience < 4
              ? 'Mid-Level'
              : 'Senior',
      salaryRange: {'min': 70000, 'max': 160000, 'currency': 'TL'},
      marketDemand: 0.92,
      learningPath: [
        'Deep Learning',
        'MLOps',
        'Big Data',
        'Computer Vision/NLP'
      ],
      timeToAchieve: 14,
      companies: ['Beko', 'Arçelik', 'Turkish Airlines', 'Migros'],
    ));

    return suggestions;
  }

  List<CareerSuggestion> _getLeadershipCareerPath(
      Set<String> skills, int experience) {
    final suggestions = <CareerSuggestion>[];

    if (experience >= 5) {
      suggestions.add(CareerSuggestion(
        title: 'Technical Lead / Engineering Manager',
        description: 'Teknik ekipleri yönetip proje koordinasyonu yapan lider',
        requiredSkills: [
          'Leadership',
          'Project Management',
          'Technical Strategy',
          'Team Building'
        ],
        matchScore: 0.75,
        nextStep:
            'Agile/Scrum metodolojileri ve ekip yönetimi sertifikalarını alın',
        category: 'Management & Leadership',
        level: 'Senior',
        salaryRange: {'min': 120000, 'max': 200000, 'currency': 'TL'},
        marketDemand: 0.80,
        learningPath: [
          'Agile/Scrum',
          'People Management',
          'Strategic Planning',
          'Budget Management'
        ],
        timeToAchieve: 20,
        companies: [
          'Koç Holding',
          'Sabancı Holding',
          'Eczacıbaşı',
          'Zorlu Holding'
        ],
      ));
    }

    return suggestions;
  }

  List<CareerSuggestion> _getEmergingTechCareerPath(
      Set<String> skills, int experience) {
    final suggestions = <CareerSuggestion>[];

    // Blockchain
    if (_hasSkills(
        skills, ['blockchain', 'cryptocurrency', 'smart contracts'])) {
      suggestions.add(CareerSuggestion(
        title: 'Blockchain Developer',
        description:
            'Blockchain teknolojileri ve akıllı kontratlar geliştiren uzman',
        requiredSkills: ['Solidity', 'Web3', 'Smart Contracts', 'DeFi'],
        matchScore: 0.78,
        nextStep:
            'DeFi protokolleri ve NFT marketplace geliştirme deneyimi kazanın',
        category: 'Emerging Technologies',
        level: 'Specialist',
        salaryRange: {'min': 90000, 'max': 180000, 'currency': 'TL'},
        marketDemand: 0.70,
        learningPath: [
          'Ethereum',
          'DeFi Protocols',
          'NFT Development',
          'Web3 Integration'
        ],
        timeToAchieve: 16,
        companies: ['BTCTurk', 'Paribu', 'BinanceTR', 'Bitexen'],
      ));
    }

    // AI/Automation
    suggestions.add(CareerSuggestion(
      title: 'AI/Automation Engineer',
      description:
          'Yapay zeka ve otomasyon çözümleri geliştiren yeni nesil uzman',
      requiredSkills: ['AI/ML', 'Automation', 'Python', 'Process Optimization'],
      matchScore: 0.82,
      nextStep: 'RPA araçları ve AI model deployment konularında uzmanlaşın',
      category: 'Emerging Technologies',
      level: 'Specialist',
      salaryRange: {'min': 85000, 'max': 170000, 'currency': 'TL'},
      marketDemand: 0.88,
      learningPath: [
        'RPA Tools',
        'AI Model Deployment',
        'Process Mining',
        'Cognitive Automation'
      ],
      timeToAchieve: 12,
      companies: ['Akbank', 'Garanti BBVA', 'İş Bankası', 'Turkcell'],
    ));

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

  // Helper methods for certifications
  List<CertificationRecommendation> _getFrontendCertifications(int experience) {
    return [
      CertificationRecommendation(
        name: 'React Developer Certification',
        provider: 'Meta',
        difficulty: experience < 2 ? 'Beginner' : 'Intermediate',
        estimatedHours: 40,
        costRange: 300,
        careerImpact: 0.85,
        prerequisites: ['JavaScript fundamentals', 'HTML/CSS'],
        validityPeriod: '2 years',
        skillsGained: [
          'Advanced React',
          'Hooks',
          'State Management',
          'Testing'
        ],
      ),
    ];
  }

  List<CertificationRecommendation> _getBackendCertifications(int experience) {
    return [
      CertificationRecommendation(
        name: 'AWS Certified Developer',
        provider: 'Amazon',
        difficulty: 'Intermediate',
        estimatedHours: 60,
        costRange: 150,
        careerImpact: 0.90,
        prerequisites: ['Cloud basics', 'API development'],
        validityPeriod: '3 years',
        skillsGained: [
          'AWS Services',
          'Serverless',
          'Microservices',
          'Security'
        ],
      ),
    ];
  }

  List<CertificationRecommendation> _getCloudCertifications(int experience) {
    return [
      CertificationRecommendation(
        name: 'Kubernetes Administrator (CKA)',
        provider: 'CNCF',
        difficulty: 'Advanced',
        estimatedHours: 80,
        costRange: 300,
        careerImpact: 0.95,
        prerequisites: ['Docker', 'Linux', 'Container orchestration'],
        validityPeriod: '3 years',
        skillsGained: [
          'Kubernetes',
          'Container orchestration',
          'DevOps',
          'Scalability'
        ],
      ),
    ];
  }

  List<CertificationRecommendation> _getMobileCertifications(int experience) {
    return [
      CertificationRecommendation(
        name: 'Google Flutter Certification',
        provider: 'Google',
        difficulty: experience < 1 ? 'Beginner' : 'Intermediate',
        estimatedHours: 50,
        costRange: 200,
        careerImpact: 0.88,
        prerequisites: ['Dart programming', 'Mobile app basics'],
        validityPeriod: '2 years',
        skillsGained: [
          'Advanced Flutter',
          'State Management',
          'Platform Integration',
          'Testing'
        ],
      ),
    ];
  }

  // Helper methods for portfolio projects
  List<PortfolioRecommendation> _getFlutterPortfolioProjects(int experience) {
    if (experience < 1) {
      return [
        PortfolioRecommendation(
          projectType: 'Mobile App',
          title: 'Personal Finance Tracker',
          description: 'Expense tracking app with charts and budget management',
          technologies: ['Flutter', 'Dart', 'SQLite', 'Charts'],
          difficulty: 'Beginner',
          estimatedDays: 14,
          careerBoost: 0.80,
          learningObjectives: [
            'State management',
            'Database integration',
            'UI/UX design'
          ],
          showcasePoints: [
            'Clean architecture',
            'Data visualization',
            'User experience'
          ],
        ),
      ];
    } else {
      return [
        PortfolioRecommendation(
          projectType: 'Enterprise App',
          title: 'Real-time Chat Application',
          description:
              'Multi-platform chat app with real-time messaging and file sharing',
          technologies: ['Flutter', 'Firebase', 'WebRTC', 'Push Notifications'],
          difficulty: 'Advanced',
          estimatedDays: 30,
          careerBoost: 0.95,
          learningObjectives: [
            'Real-time communication',
            'Complex state management',
            'Performance optimization'
          ],
          showcasePoints: [
            'Scalable architecture',
            'Real-time features',
            'Cross-platform compatibility'
          ],
        ),
      ];
    }
  }

  List<PortfolioRecommendation> _getReactPortfolioProjects(int experience) {
    return [
      PortfolioRecommendation(
        projectType: 'Web Application',
        title: 'E-commerce Dashboard',
        description:
            'Admin dashboard for e-commerce with analytics and inventory management',
        technologies: [
          'React',
          'TypeScript',
          'Redux',
          'Material-UI',
          'Charts.js'
        ],
        difficulty: experience < 2 ? 'Intermediate' : 'Advanced',
        estimatedDays: 20,
        careerBoost: 0.85,
        learningObjectives: [
          'Complex state management',
          'Data visualization',
          'Performance optimization'
        ],
        showcasePoints: [
          'Modern architecture',
          'Responsive design',
          'Performance metrics'
        ],
      ),
    ];
  }

  List<PortfolioRecommendation> _getBackendPortfolioProjects(int experience) {
    return [
      PortfolioRecommendation(
        projectType: 'API Service',
        title: 'Microservices E-commerce Backend',
        description:
            'Scalable microservices architecture for e-commerce platform',
        technologies: ['Node.js', 'Docker', 'Kubernetes', 'MongoDB', 'Redis'],
        difficulty: 'Advanced',
        estimatedDays: 35,
        careerBoost: 0.90,
        learningObjectives: [
          'Microservices architecture',
          'Scalability',
          'DevOps integration'
        ],
        showcasePoints: [
          'System design',
          'Performance optimization',
          'Monitoring and logging'
        ],
      ),
    ];
  }

  List<PortfolioRecommendation> _getAIPortfolioProjects(int experience) {
    return [
      PortfolioRecommendation(
        projectType: 'AI Application',
        title: 'Computer Vision Document Scanner',
        description:
            'AI-powered document scanner with text extraction and classification',
        technologies: ['Python', 'TensorFlow', 'OpenCV', 'Flask', 'AWS'],
        difficulty: 'Advanced',
        estimatedDays: 25,
        careerBoost: 0.92,
        learningObjectives: [
          'Computer vision',
          'Machine learning deployment',
          'Cloud integration'
        ],
        showcasePoints: [
          'AI model training',
          'Real-world application',
          'Cloud deployment'
        ],
      ),
    ];
  }

  // Generate interview preparation
  List<InterviewPreparation> generateInterviewPreparation(
      UserProfile userProfile) {
    final preparations = <InterviewPreparation>[];
    final skills = userProfile.skills.map((s) => s.toLowerCase()).toSet();

    if (skills.contains('flutter') || skills.contains('mobile')) {
      preparations.add(generateInterviewPrep('Flutter Developer'));
    }

    if (skills.contains('react') || skills.contains('frontend')) {
      preparations.add(generateInterviewPrep('Senior Frontend Developer'));
    }

    return preparations;
  }

  // Generate market analytics
  MarketAnalytics generateMarketAnalytics(UserProfile userProfile) {
    // Default to Turkey market, could be enhanced with user location
    return getMarketAnalytics('Turkey');
  }

  // Generate industry trends - using existing method
  List<IndustryTrend> generateIndustryTrends(UserProfile userProfile) {
    // Return existing industry trends
    return analyzeIndustryTrends();
  }

  // Generate networking strategies
  List<NetworkingRecommendation> generateNetworkingStrategies(
      UserProfile userProfile) {
    final strategies = <NetworkingRecommendation>[
      NetworkingRecommendation(
        strategy: 'Tech Community Engagement',
        targetCompanies: ['Google', 'Microsoft', 'Meta', 'Local startups'],
        relevantEvents: [
          'Flutter meetups',
          'Tech conferences',
          'Developer workshops'
        ],
        onlineCommunities: ['GitHub', 'Stack Overflow', 'Dev.to', 'LinkedIn'],
        keyPeople: [
          'Flutter team leads',
          'Industry experts',
          'Local tech leaders'
        ],
        contentTopics: [
          'Flutter development',
          'Mobile technologies',
          'Cross-platform solutions'
        ],
      ),
      NetworkingRecommendation(
        strategy: 'Open Source Contribution',
        targetCompanies: [
          'Open source organizations',
          'Tech companies using Flutter'
        ],
        relevantEvents: [
          'Hacktoberfest',
          'Flutter contribute',
          'Open source conferences'
        ],
        onlineCommunities: ['GitHub', 'Flutter community', 'Dart community'],
        keyPeople: [
          'Flutter maintainers',
          'Package authors',
          'Core contributors'
        ],
        contentTopics: [
          'Package development',
          'Bug fixes',
          'Feature contributions'
        ],
      ),
    ];

    return strategies;
  }
}
