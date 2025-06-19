import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../core/services/error_handler_service.dart';
import 'dart:convert';

class GitHubCodeViewerService extends GetxService {
  final ErrorHandlerService _errorHandler;
  final String _baseApiUrl = 'https://api.github.com';

  GitHubCodeViewerService({
    ErrorHandlerService? errorHandler,
  }) : _errorHandler = errorHandler ?? Get.find();

  // GitHub URL'sinden repo bilgilerini ayıkla
  Map<String, String>? parseGitHubUrl(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.host != 'github.com') return null;

      final parts = uri.path.split('/')..removeWhere((part) => part.isEmpty);

      if (parts.length < 2) return null;

      return {
        'owner': parts[0],
        'repo': parts[1],
        'branch': parts.length > 3 && parts[2] == 'tree' ? parts[3] : 'main',
        'path': parts.length > 4 && parts[2] == 'tree'
            ? parts.sublist(4).join('/')
            : '',
      };
    } catch (e) {
      _errorHandler.handleError(e);
      return null;
    }
  }

  // Repo içeriğini getir
  Future<List<Map<String, dynamic>>> getRepositoryContents({
    required String owner,
    required String repo,
    String branch = 'main',
    String path = '',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseApiUrl/repos/$owner/$repo/contents/$path?ref=$branch'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('GitHub API hatası: ${response.statusCode}');
      }
    } catch (e) {
      _errorHandler.handleError(e);
      return [];
    }
  }

  // Dosya içeriğini getir
  Future<String?> getFileContent({
    required String owner,
    required String repo,
    required String path,
    String branch = 'main',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseApiUrl/repos/$owner/$repo/contents/$path?ref=$branch'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['type'] == 'file') {
          final content = data['content'];
          if (content != null) {
            return utf8.decode(base64.decode(content.replaceAll('\n', '')));
          }
        }
      }
      return null;
    } catch (e) {
      _errorHandler.handleError(e);
      return null;
    }
  }

  // README dosyasını getir
  Future<String?> getReadme({
    required String owner,
    required String repo,
    String branch = 'main',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseApiUrl/repos/$owner/$repo/readme?ref=$branch'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['content'];
        if (content != null) {
          return utf8.decode(base64.decode(content.replaceAll('\n', '')));
        }
      }
      return null;
    } catch (e) {
      _errorHandler.handleError(e);
      return null;
    }
  }
}
