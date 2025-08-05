import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/github_repository_model.dart';
import '../../models/collaboration_request_model.dart';
import '../../core/services/error_handler_service.dart';
import '../../core/services/logger_service.dart';
import '../../repositories/auth_repository.dart';

class GitHubContentSharingService extends GetxService {
  final LoggerService _logger;
  final ErrorHandlerService _errorHandler;
  final String _baseUrl = 'https://api.github.com';

  GitHubContentSharingService({
    required LoggerService logger,
    required ErrorHandlerService errorHandler,
  }) : _logger = logger,
       _errorHandler = errorHandler;

  // Repository İçerik Yönetimi
  Future<List<GitHubRepositoryModel>> getDiscoverableRepositories({
    String? language,
    String? topic,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final token = await _getGitHubToken();
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/search/repositories?q=language:$language+topic:$topic&page=$page&per_page=$perPage',
        ),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['items'] as List)
            .map((item) => GitHubRepositoryModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Repository listesi alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Repository listesi alınırken hata: $e');
      rethrow;
    }
  }

  Future<String> generateProjectDescription(String owner, String repo) async {
    try {
      final token = await _getGitHubToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/repos/$owner/$repo/readme'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = utf8.decode(base64.decode(data['content']));
        return _extractSummaryFromReadme(content);
      } else {
        throw Exception('README dosyası alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Proje açıklaması oluşturulurken hata: $e');
      rethrow;
    }
  }

  // İşbirliği ve Etkileşim
  Future<void> createCollaborationRequest(
    String owner,
    String repo,
    CollaborationRequestModel request,
  ) async {
    try {
      final token = await _getGitHubToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/repos/$owner/$repo/collaborators'),
        headers: _getHeaders(token),
        body: json.encode(request.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception(
          'İşbirliği isteği oluşturulamadı: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.e('İşbirliği isteği oluşturulurken hata: $e');
      rethrow;
    }
  }

  Future<void> createDiscussion(
    String owner,
    String repo,
    String title,
    String body,
  ) async {
    try {
      final token = await _getGitHubToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/repos/$owner/$repo/discussions'),
        headers: _getHeaders(token),
        body: json.encode({
          'title': title,
          'body': body,
          'category': 'general',
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Tartışma oluşturulamadı: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Tartışma oluşturulurken hata: $e');
      rethrow;
    }
  }

  // Portföy ve Analiz
  Future<Map<String, dynamic>> getContributionTimeline(String username) async {
    try {
      final token = await _getGitHubToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$username/events'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Katkı zaman çizelgesi alınamadı: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.e('Katkı zaman çizelgesi alınırken hata: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getRepositoryAnalytics(
    String owner,
    String repo,
  ) async {
    try {
      final token = await _getGitHubToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/repos/$owner/$repo/stats/contributors'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Repository analitiği alınamadı: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.e('Repository analitiği alınırken hata: $e');
      rethrow;
    }
  }

  // Yardımcı Metodlar
  Map<String, String> _getHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/vnd.github.v3+json',
      'Content-Type': 'application/json',
    };
  }

  Future<String> _getGitHubToken() async {
    try {
      final authRepo = Get.find<AuthRepository>();
      final token = await authRepo.getGithubAccessToken();
      if (token == null) {
        throw Exception('GitHub token bulunamadı');
      }
      return token;
    } catch (e) {
      _logger.e('GitHub token alınırken hata: $e');
      rethrow;
    }
  }

  // İşbirliği İstekleri
  Future<void> cancelCollaborationRequest(
    String owner,
    String repo,
    String requestId,
  ) async {
    try {
      final token = await _getGitHubToken();
      final response = await http.delete(
        Uri.parse(
          '$_baseUrl/repos/$owner/$repo/collaboration-requests/$requestId',
        ),
        headers: _getHeaders(token),
      );

      if (response.statusCode != 204) {
        throw Exception(
          'İşbirliği isteği iptal edilemedi: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.e('İşbirliği isteği iptal edilirken hata: $e');
      _errorHandler.handleError(e);
      rethrow;
    }
  }

  Future<void> updateCollaborationRequest(
    String owner,
    String repo,
    CollaborationRequestModel request,
  ) async {
    try {
      final token = await _getGitHubToken();
      final response = await http.patch(
        Uri.parse(
          '$_baseUrl/repos/$owner/$repo/collaboration-requests/${request.id}',
        ),
        headers: _getHeaders(token),
        body: json.encode(request.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'İşbirliği isteği güncellenemedi: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.e('İşbirliği isteği güncellenirken hata: $e');
      _errorHandler.handleError(e);
      rethrow;
    }
  }

  Future<int> getUserCollaborationsCount() async {
    try {
      final token = await _getGitHubToken();
      final authRepo = Get.find<AuthRepository>();
      final username = authRepo.currentUser?.displayName;

      if (username == null) {
        throw Exception('Kullanıcı adı bulunamadı');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/users/$username/collaborators'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final collaborators = json.decode(response.body) as List;
        return collaborators.length;
      } else {
        throw Exception('İşbirliği sayısı alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('İşbirliği sayısı alınırken hata: $e');
      return 0;
    }
  }

  Future<int> getUserContributionsCount() async {
    try {
      final token = await _getGitHubToken();
      final authRepo = Get.find<AuthRepository>();
      final username = authRepo.currentUser?.displayName;

      if (username == null) {
        throw Exception('Kullanıcı adı bulunamadı');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/users/$username/events'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final events = json.decode(response.body) as List;
        return events
            .where(
              (event) =>
                  event['type'] == 'PushEvent' ||
                  event['type'] == 'PullRequestEvent' ||
                  event['type'] == 'IssuesEvent',
            )
            .length;
      } else {
        throw Exception('Katkı sayısı alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Katkı sayısı alınırken hata: $e');
      return 0;
    }
  }

  String _extractSummaryFromReadme(String content) {
    // İlk paragrafı al
    final firstParagraph = content.split('\n\n').first;

    // Markdown formatını temizle
    return firstParagraph
        .replaceAll(RegExp(r'#+ '), '') // Başlıkları temizle
        .replaceAll(
          RegExp(r'\[([^\]]+)\]\([^\)]+\)'),
          r'$1',
        ) // Linkleri temizle
        .replaceAll(RegExp(r'[*_`]'), '') // Vurgu işaretlerini temizle
        .trim();
  }
}
