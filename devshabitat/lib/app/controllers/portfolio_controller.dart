import 'package:get/get.dart';
import '../services/github_service.dart';
import '../models/portfolio/tech_stack_model.dart';
import '../models/portfolio/project_model.dart';
import '../core/services/error_handler_service.dart';

class PortfolioController extends GetxController {
  final GithubService _githubService = Get.find();
  final ErrorHandlerService _errorHandler = Get.find();

  final RxList<ProjectModel> featuredProjects = <ProjectModel>[].obs;
  final RxList<TechStackModel> techStack = <TechStackModel>[].obs;
  final RxMap<String, int> contributionData = <String, int>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadPortfolioData();
  }

  Future<void> loadPortfolioData() async {
    await Future.wait([
      selectFeaturedProjects(),
      extractTechStack(),
      showContributionGraph(),
    ]);
  }

  // Öne çıkan projeleri seçme
  Future<void> selectFeaturedProjects() async {
    try {
      isLoading.value = true;
      error.value = '';

      final username = await _githubService.getCurrentUsername();
      if (username == null) {
        throw Exception('GitHub kullanıcı adı bulunamadı');
      }

      final repos = await _githubService.getUserRepos(username);
      final sortedRepos = repos
        ..sort((a, b) =>
            (b['stargazers_count'] ?? 0).compareTo(a['stargazers_count'] ?? 0));

      featuredProjects.value = sortedRepos.take(5).map((repo) {
        return ProjectModel(
          name: repo['name'] ?? '',
          description: repo['description'] ?? '',
          language: repo['language'] ?? '',
          stars: repo['stargazers_count'] ?? 0,
          forks: repo['forks_count'] ?? 0,
          url: repo['html_url'] ?? '',
          topics: List<String>.from(repo['topics'] ?? []),
        );
      }).toList();
    } catch (e) {
      error.value = 'Projeler yüklenirken bir hata oluştu: $e';
      _errorHandler.handleError(e, ErrorHandlerService.PORTFOLIO_ERROR);
    } finally {
      isLoading.value = false;
    }
  }

  // Teknoloji stack'ini otomatik çıkarma
  Future<void> extractTechStack() async {
    try {
      isLoading.value = true;
      error.value = '';

      final username = await _githubService.getCurrentUsername();
      if (username == null) {
        throw Exception('GitHub kullanıcı adı bulunamadı');
      }

      final repos = await _githubService.getUserRepos(username);
      final Map<String, TechStackModel> techStackMap = {};

      for (final repo in repos) {
        final language = repo['language'];
        if (language != null) {
          if (techStackMap.containsKey(language)) {
            techStackMap[language]!.projectCount++;
            techStackMap[language]!.totalStars +=
                (repo['stargazers_count'] ?? 0) as int;
          } else {
            techStackMap[language] = TechStackModel(
              name: language,
              projectCount: 1,
              totalStars: (repo['stargazers_count'] ?? 0) as int,
              experienceLevel: _calculateExperienceLevel(
                repo['created_at'] as String?,
                repo['updated_at'] as String?,
              ),
            );
          }
        }

        // Proje etiketlerini de teknoloji stack'ine ekle
        final topics = List<String>.from(repo['topics'] ?? []);
        for (final topic in topics) {
          if (techStackMap.containsKey(topic)) {
            techStackMap[topic]!.projectCount++;
          } else {
            techStackMap[topic] = TechStackModel(
              name: topic,
              projectCount: 1,
              totalStars: 0,
              experienceLevel: ExperienceLevel.intermediate,
            );
          }
        }
      }

      techStack.value = techStackMap.values.toList()
        ..sort((a, b) => b.projectCount.compareTo(a.projectCount));
    } catch (e) {
      error.value = 'Teknoloji stack\'i çıkarılırken bir hata oluştu: $e';
      _errorHandler.handleError(e, ErrorHandlerService.PORTFOLIO_ERROR);
    } finally {
      isLoading.value = false;
    }
  }

  // Katkı grafiklerini gösterme
  Future<void> showContributionGraph() async {
    try {
      isLoading.value = true;
      error.value = '';

      final username = await _githubService.getCurrentUsername();
      if (username == null) {
        throw Exception('GitHub kullanıcı adı bulunamadı');
      }

      final contributions = await _githubService.getContributionData(username);
      contributionData.value = contributions;
    } catch (e) {
      error.value = 'Katkı grafiği yüklenirken bir hata oluştu: $e';
      _errorHandler.handleError(e, ErrorHandlerService.PORTFOLIO_ERROR);
    } finally {
      isLoading.value = false;
    }
  }

  // Deneyim seviyesini hesapla
  ExperienceLevel _calculateExperienceLevel(
    String? createdAt,
    String? updatedAt,
  ) {
    if (createdAt == null || updatedAt == null) {
      return ExperienceLevel.beginner;
    }

    final created = DateTime.parse(createdAt);
    final updated = DateTime.parse(updatedAt);
    final duration = updated.difference(created);

    if (duration.inDays > 365 * 2) {
      return ExperienceLevel.expert;
    } else if (duration.inDays > 365) {
      return ExperienceLevel.advanced;
    } else if (duration.inDays > 180) {
      return ExperienceLevel.intermediate;
    } else {
      return ExperienceLevel.beginner;
    }
  }
}
