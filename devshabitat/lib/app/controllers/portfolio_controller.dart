import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/user_profile_model.dart';
import '../models/portfolio_project_model.dart';
import '../models/portfolio/tech_stack_model.dart';
import '../models/portfolio/project_model.dart';
import '../controllers/auth_controller.dart';
import '../services/professional_insights_service.dart';
export '../services/professional_insights_service.dart'
    show
        CareerSuggestion,
        SkillGapAnalysis,
        CertificationRecommendation,
        PortfolioRecommendation,
        InterviewPreparation,
        MarketAnalytics,
        NetworkingRecommendation,
        IndustryTrend,
        CourseRecommendation,
        ProjectIdea;

class PortfolioController extends GetxController {
  final ProfessionalInsightsService _insightsService =
      Get.find<ProfessionalInsightsService>();
  final Logger _logger = Logger();

  // Enhanced reactive variables
  final userProfile = Rxn<UserProfile>();
  final portfolioProjects = <PortfolioProjectModel>[].obs;
  final isLoading = false.obs;
  final isLoadingInsights = false.obs;
  final isLoadingCareerPath = false.obs;
  final errorMessage = ''.obs;
  final insightsStatus = ''.obs;

  // Portfolio visualization data
  final techStackAnalysis = <TechStackModel>[].obs;
  final featuredProjects = <ProjectModel>[].obs;
  final contributionData = <DateTime, int>{}.obs;

  // AI Career Coach Features
  final careerSuggestions = <CareerSuggestion>[].obs;
  final skillGapAnalysis = <SkillGapAnalysis>[].obs;
  final certificationRecommendations = <CertificationRecommendation>[].obs;
  final portfolioRecommendations = <PortfolioRecommendation>[].obs;
  final interviewPreparation = <InterviewPreparation>[].obs;
  final marketAnalytics = Rxn<MarketAnalytics>();
  final networkingStrategies = <NetworkingRecommendation>[].obs;
  final industryTrends = <IndustryTrend>[].obs;

  // Career Path Management
  final selectedCareerPath = ''.obs;
  final careerProgressScore = 0.0.obs;
  final nextMilestones = <String>[].obs;
  final estimatedTimeToGoal = 0.obs; // months
  final salaryProjections = <String, dynamic>{}.obs;

  // Learning and Development
  final learningRoadmap = <LearningStep>[].obs;
  final completedCertifications = <String>[].obs;
  final recommendedCourses = <CourseRecommendation>[].obs;
  final practiceProjects = <ProjectIdea>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializePortfolio();
  }

  // Initialize comprehensive portfolio system
  Future<void> _initializePortfolio() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      insightsStatus.value = 'Initializing portfolio...';

      await _loadUserProfile();
      await _loadPortfolioProjects();
      await _loadPortfolioVisualizationData();
      await _initializeAICareerCoach();

      insightsStatus.value = 'Portfolio initialized successfully';
      _logger.i('Portfolio system initialized');
    } catch (e) {
      errorMessage.value = 'Failed to initialize portfolio: $e';
      _logger.e('Portfolio initialization error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load user profile with enhanced data
  Future<void> _loadUserProfile() async {
    try {
      final currentUser = Get.find<AuthController>().currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Load from Firestore - this would be implemented in a UserService
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        userProfile.value = UserProfile.fromFirestore(userDoc);
        _logger.i('User profile loaded');
      }
    } catch (e) {
      _logger.e('Load user profile error: $e');
      throw Exception('Failed to load user profile');
    }
  }

  // Load portfolio projects
  Future<void> _loadPortfolioProjects() async {
    try {
      final currentUser = Get.find<AuthController>().currentUser;
      if (currentUser == null) return;

      final projectsSnapshot = await FirebaseFirestore.instance
          .collection('portfolio_projects')
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .get();

      portfolioProjects.value = projectsSnapshot.docs
          .map((doc) => PortfolioProjectModel.fromFirestore(doc))
          .toList();

      _logger.i('Loaded ${portfolioProjects.length} portfolio projects');
    } catch (e) {
      _logger.e('Load portfolio projects error: $e');
    }
  }

  // Load portfolio visualization data
  Future<void> _loadPortfolioVisualizationData() async {
    try {
      await _generateTechStackAnalysis();
      await _generateFeaturedProjects();
      await _generateContributionData();
      _logger.i('Portfolio visualization data loaded');
    } catch (e) {
      _logger.e('Load portfolio visualization data error: $e');
    }
  }

  // Generate tech stack analysis
  Future<void> _generateTechStackAnalysis() async {
    try {
      // Create tech stack analysis from portfolio projects
      final techStackMap = <String, TechStackModel>{};

      for (final project in portfolioProjects) {
        // Use first technology as language, fallback to category or 'Unknown'
        final language = project.technologies.isNotEmpty
            ? project.technologies.first
            : project.category ?? 'Unknown';

        if (techStackMap.containsKey(language)) {
          techStackMap[language]!.projectCount++;
          // Use number of technologies as stars indicator
          techStackMap[language]!.totalStars += project.technologies.length;
        } else {
          techStackMap[language] = TechStackModel(
            name: language,
            projectCount: 1,
            totalStars: project.technologies.length,
            experienceLevel: _determineExperienceLevel(1),
          );
        }
      }

      // Update experience levels based on project count
      for (final entry in techStackMap.entries) {
        final projectCount = entry.value.projectCount;
        techStackMap[entry.key] = TechStackModel(
          name: entry.value.name,
          projectCount: entry.value.projectCount,
          totalStars: entry.value.totalStars,
          experienceLevel: _determineExperienceLevel(projectCount),
        );
      }

      techStackAnalysis.value = techStackMap.values.toList()
        ..sort((a, b) => b.totalStars.compareTo(a.totalStars));
    } catch (e) {
      _logger.e('Generate tech stack analysis error: $e');
    }
  }

  // Determine experience level based on project count
  ExperienceLevel _determineExperienceLevel(int projectCount) {
    if (projectCount >= 10) return ExperienceLevel.expert;
    if (projectCount >= 5) return ExperienceLevel.advanced;
    if (projectCount >= 3) return ExperienceLevel.intermediate;
    return ExperienceLevel.beginner;
  }

  // Generate featured projects
  Future<void> _generateFeaturedProjects() async {
    try {
      // Convert portfolio projects to project models and get top ones
      final projects = portfolioProjects
          .map((project) => ProjectModel(
                name: project.title,
                description: project.description,
                language: project.technologies.isNotEmpty
                    ? project.technologies.first
                    : project.category ?? 'Unknown',
                stars: project.technologies.length, // Use tech count as stars
                forks: project.images.length, // Use image count as forks
                url: project.repositoryUrl ?? '',
                topics: project.technologies,
              ))
          .toList();

      // Sort by featured status first, then by tech count
      projects.sort((a, b) {
        final aFeatured =
            portfolioProjects.firstWhere((p) => p.title == a.name).isFeatured;
        final bFeatured =
            portfolioProjects.firstWhere((p) => p.title == b.name).isFeatured;

        if (aFeatured && !bFeatured) return -1;
        if (!aFeatured && bFeatured) return 1;
        return b.stars.compareTo(a.stars);
      });

      featuredProjects.value = projects.take(5).toList();
    } catch (e) {
      _logger.e('Generate featured projects error: $e');
    }
  }

  // Generate contribution data
  Future<void> _generateContributionData() async {
    try {
      // Generate sample contribution data for the last 12 months
      final now = DateTime.now();
      final contributions = <DateTime, int>{};

      for (int i = 11; i >= 0; i--) {
        final date = DateTime(now.year, now.month - i, 1);
        // Generate random contribution count based on projects
        final baseContributions = portfolioProjects.length * 5;
        final randomVariation = (baseContributions * 0.3).round();
        final contributionCount =
            baseContributions + (DateTime.now().millisecond % randomVariation);
        contributions[date] = contributionCount;
      }

      contributionData.value = contributions;
    } catch (e) {
      _logger.e('Generate contribution data error: $e');
    }
  }

  // Initialize AI Career Coach with comprehensive analysis
  Future<void> _initializeAICareerCoach() async {
    try {
      if (userProfile.value == null) return;

      isLoadingInsights.value = true;
      insightsStatus.value = 'Analyzing career profile...';

      // Generate comprehensive career insights
      await Future.wait([
        _generateCareerSuggestions(),
        _analyzeSkillGaps(),
        _generateCertificationRoadmap(),
        _generatePortfolioRecommendations(),
        _prepareInterviewGuidance(),
        _analyzeMarketTrends(),
        _generateNetworkingStrategies(),
      ]);

      insightsStatus.value = 'AI Career Coach ready';
      _logger.i('AI Career Coach initialized successfully');
    } catch (e) {
      errorMessage.value = 'Failed to initialize AI Career Coach: $e';
      _logger.e('AI Career Coach initialization error: $e');
    } finally {
      isLoadingInsights.value = false;
    }
  }

  // Generate personalized career suggestions
  Future<void> _generateCareerSuggestions() async {
    try {
      final suggestions =
          _insightsService.generateCareerSuggestions(userProfile.value!);
      careerSuggestions.value = suggestions;

      // Automatically select best match if none selected
      if (selectedCareerPath.value.isEmpty && suggestions.isNotEmpty) {
        await selectCareerPath(suggestions.first.title);
      }

      _logger.i('Generated ${suggestions.length} career suggestions');
    } catch (e) {
      _logger.e('Generate career suggestions error: $e');
    }
  }

  // Analyze skill gaps with detailed recommendations
  Future<void> _analyzeSkillGaps() async {
    try {
      // Create industry benchmarks for common skills
      final industryBenchmarks = <String, double>{
        'flutter': 0.8,
        'dart': 0.7,
        'react': 0.8,
        'javascript': 0.7,
        'typescript': 0.8,
        'node.js': 0.7,
        'python': 0.8,
        'aws': 0.9,
        'docker': 0.8,
        'kubernetes': 0.9,
      };

      final analysis = _insightsService.analyzeSkillGaps(
          userProfile.value!, industryBenchmarks);
      skillGapAnalysis.value = analysis;
      _logger.i('Analyzed ${analysis.length} skill gaps');
    } catch (e) {
      _logger.e('Analyze skill gaps error: $e');
    }
  }

  // Generate certification roadmap
  Future<void> _generateCertificationRoadmap() async {
    try {
      final roadmap =
          _insightsService.generateCertificationRoadmap(userProfile.value!);
      certificationRecommendations.value = roadmap;
      _logger.i('Generated ${roadmap.length} certification recommendations');
    } catch (e) {
      _logger.e('Generate certification roadmap error: $e');
    }
  }

  // Generate portfolio recommendations
  Future<void> _generatePortfolioRecommendations() async {
    try {
      final recommendations =
          _insightsService.generatePortfolioRecommendations(userProfile.value!);
      portfolioRecommendations.value = recommendations;
      _logger
          .i('Generated ${recommendations.length} portfolio recommendations');
    } catch (e) {
      _logger.e('Generate portfolio recommendations error: $e');
    }
  }

  // Prepare interview guidance
  Future<void> _prepareInterviewGuidance() async {
    try {
      final preparation =
          _insightsService.generateInterviewPreparation(userProfile.value!);
      interviewPreparation.value = preparation;
      _logger.i('Generated ${preparation.length} interview preparation items');
    } catch (e) {
      _logger.e('Prepare interview guidance error: $e');
    }
  }

  // Analyze market trends with Turkish market data
  Future<void> _analyzeMarketTrends() async {
    try {
      final analytics =
          _insightsService.generateMarketAnalytics(userProfile.value!);
      marketAnalytics.value = analytics;

      final trends =
          _insightsService.generateIndustryTrends(userProfile.value!);
      industryTrends.value = trends;

      _logger.i('Market analytics and trends generated');
    } catch (e) {
      _logger.e('Analyze market trends error: $e');
    }
  }

  // Generate networking strategies
  Future<void> _generateNetworkingStrategies() async {
    try {
      final strategies =
          _insightsService.generateNetworkingStrategies(userProfile.value!);
      networkingStrategies.value = strategies;
      _logger.i('Generated ${strategies.length} networking strategies');
    } catch (e) {
      _logger.e('Generate networking strategies error: $e');
    }
  }

  // Select and configure career path
  Future<void> selectCareerPath(String careerTitle) async {
    try {
      isLoadingCareerPath.value = true;
      selectedCareerPath.value = careerTitle;

      // Find the selected career suggestion
      final selectedCareer =
          careerSuggestions.firstWhere((career) => career.title == careerTitle);

      // Calculate progress and projections
      await _calculateCareerProgress(selectedCareer);
      await _generateLearningRoadmap(selectedCareer);
      await _projectSalaryGrowth(selectedCareer);

      insightsStatus.value = 'Career path selected: $careerTitle';
      _logger.i('Career path selected: $careerTitle');
    } catch (e) {
      errorMessage.value = 'Failed to select career path: $e';
      _logger.e('Select career path error: $e');
    } finally {
      isLoadingCareerPath.value = false;
    }
  }

  // Calculate career progress and milestones
  Future<void> _calculateCareerProgress(CareerSuggestion career) async {
    try {
      final currentSkills = userProfile.value!.skills;
      final requiredSkills = career.requiredSkills;

      final matchingSkills =
          currentSkills.where((skill) => requiredSkills.contains(skill)).length;

      careerProgressScore.value = matchingSkills / requiredSkills.length;
      estimatedTimeToGoal.value = career.timeToAchieve;

      // Generate next milestones
      final missingSkills = requiredSkills
          .where((skill) => !currentSkills.contains(skill))
          .take(3)
          .toList();

      nextMilestones.value = missingSkills;
      _logger.i(
          'Career progress calculated: ${(careerProgressScore.value * 100).toStringAsFixed(1)}%');
    } catch (e) {
      _logger.e('Calculate career progress error: $e');
    }
  }

  // Generate personalized learning roadmap
  Future<void> _generateLearningRoadmap(CareerSuggestion career) async {
    try {
      final roadmap = career.learningPath
          .map((step) => LearningStep(
                title: step,
                description: 'Master $step to advance in your career path',
                estimatedHours: 40, // Default estimation
                priority:
                    career.learningPath.indexOf(step) < 3 ? 'High' : 'Medium',
                resources: [], // Would be populated with actual resources
              ))
          .toList();

      learningRoadmap.value = roadmap;
      _logger.i('Learning roadmap generated with ${roadmap.length} steps');
    } catch (e) {
      _logger.e('Generate learning roadmap error: $e');
    }
  }

  // Project salary growth based on career path
  Future<void> _projectSalaryGrowth(CareerSuggestion career) async {
    try {
      final salaryRange = career.salaryRange;

      salaryProjections.value = {
        'current_min': salaryRange['min'],
        'current_max': salaryRange['max'],
        'projected_1_year': (salaryRange['max'] * 1.1).round(),
        'projected_3_years': (salaryRange['max'] * 1.35).round(),
        'projected_5_years': (salaryRange['max'] * 1.6).round(),
        'currency': salaryRange['currency'] ?? 'TL',
        'market_demand': career.marketDemand,
      };

      _logger.i('Salary projections calculated');
    } catch (e) {
      _logger.e('Project salary growth error: $e');
    }
  }

  // Add new portfolio project
  Future<void> addPortfolioProject(PortfolioProjectModel project) async {
    try {
      final currentUser = Get.find<AuthController>().currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final projectData = project.copyWith(userId: currentUser.uid).toJson();

      final docRef = await FirebaseFirestore.instance
          .collection('portfolio_projects')
          .add(projectData);

      final newProject =
          project.copyWith(id: docRef.id, userId: currentUser.uid);
      portfolioProjects.add(newProject);

      // Refresh career insights based on new project
      await _refreshCareerInsights();

      _logger.i('Portfolio project added: ${project.title}');
    } catch (e) {
      errorMessage.value = 'Failed to add project: $e';
      _logger.e('Add portfolio project error: $e');
    }
  }

  // Update portfolio project
  Future<void> updatePortfolioProject(PortfolioProjectModel project) async {
    try {
      await FirebaseFirestore.instance
          .collection('portfolio_projects')
          .doc(project.id)
          .update(project.toJson());

      final index = portfolioProjects.indexWhere((p) => p.id == project.id!);
      if (index != -1) {
        portfolioProjects[index] = project;
      }

      await _refreshCareerInsights();
      _logger.i('Portfolio project updated: ${project.title}');
    } catch (e) {
      errorMessage.value = 'Failed to update project: $e';
      _logger.e('Update portfolio project error: $e');
    }
  }

  // Delete portfolio project
  Future<void> deletePortfolioProject(String projectId) async {
    try {
      await FirebaseFirestore.instance
          .collection('portfolio_projects')
          .doc(projectId)
          .delete();

      portfolioProjects.removeWhere((project) => project.id! == projectId);

      await _refreshCareerInsights();
      _logger.i('Portfolio project deleted: $projectId');
    } catch (e) {
      errorMessage.value = 'Failed to delete project: $e';
      _logger.e('Delete portfolio project error: $e');
    }
  }

  // Mark certification as completed
  Future<void> markCertificationCompleted(String certificationName) async {
    try {
      if (!completedCertifications.contains(certificationName)) {
        completedCertifications.add(certificationName);

        // Update user profile with new certification
        // This would update the actual user profile in Firestore

        await _refreshCareerInsights();
        _logger.i('Certification marked completed: $certificationName');
      }
    } catch (e) {
      _logger.e('Mark certification completed error: $e');
    }
  }

  // Refresh career insights based on current data
  Future<void> _refreshCareerInsights() async {
    try {
      await _initializeAICareerCoach();

      if (selectedCareerPath.value.isNotEmpty) {
        await selectCareerPath(selectedCareerPath.value);
      }
    } catch (e) {
      _logger.e('Refresh career insights error: $e');
    }
  }

  // Get comprehensive portfolio status
  Map<String, dynamic> getPortfolioStatus() {
    return {
      'user_authenticated': userProfile.value != null,
      'total_projects': portfolioProjects.length,
      'career_suggestions': careerSuggestions.length,
      'skill_gaps': skillGapAnalysis.length,
      'certifications_recommended': certificationRecommendations.length,
      'certifications_completed': completedCertifications.length,
      'selected_career_path': selectedCareerPath.value,
      'career_progress':
          '${(careerProgressScore.value * 100).toStringAsFixed(1)}%',
      'estimated_time_to_goal': '${estimatedTimeToGoal.value} months',
      'next_milestones': nextMilestones.length,
      'learning_steps': learningRoadmap.length,
      'is_loading': isLoading.value,
      'is_loading_insights': isLoadingInsights.value,
      'insights_status': insightsStatus.value,
      'error_message': errorMessage.value,
    };
  }

  // Refresh all data
  Future<void> refreshPortfolio() async {
    await _initializePortfolio();
  }

  // Override onClose if needed for cleanup
}

// Supporting model classes for the expanded features
class LearningStep {
  final String title;
  final String description;
  final int estimatedHours;
  final String priority;
  final List<String> resources;

  LearningStep({
    required this.title,
    required this.description,
    required this.estimatedHours,
    required this.priority,
    required this.resources,
  });
}
