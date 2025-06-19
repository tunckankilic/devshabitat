import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:get/get.dart';
import '../services/github_code_viewer_service.dart';
import 'loading_widget.dart';

class GitHubCodeViewer extends StatefulWidget {
  final String githubUrl;

  const GitHubCodeViewer({
    Key? key,
    required this.githubUrl,
  }) : super(key: key);

  @override
  State<GitHubCodeViewer> createState() => _GitHubCodeViewerState();
}

class _GitHubCodeViewerState extends State<GitHubCodeViewer> {
  final _service = Get.find<GitHubCodeViewerService>();
  String? _content;
  String? _error;
  bool _isLoading = true;
  Map<String, String>? _repoInfo;
  List<Map<String, dynamic>>? _contents;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _repoInfo = _service.parseGitHubUrl(widget.githubUrl);
      if (_repoInfo == null) {
        throw Exception('Geçersiz GitHub URL\'si');
      }

      if (_repoInfo!['path']!.isEmpty) {
        // Repo kök dizinini göster
        _contents = await _service.getRepositoryContents(
          owner: _repoInfo!['owner']!,
          repo: _repoInfo!['repo']!,
          branch: _repoInfo!['branch']!,
        );

        // README dosyasını göster
        _content = await _service.getReadme(
          owner: _repoInfo!['owner']!,
          repo: _repoInfo!['repo']!,
          branch: _repoInfo!['branch']!,
        );
      } else {
        // Dosya içeriğini göster
        _content = await _service.getFileContent(
          owner: _repoInfo!['owner']!,
          repo: _repoInfo!['repo']!,
          path: _repoInfo!['path']!,
          branch: _repoInfo!['branch']!,
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getLanguage(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      // Mobile
      case 'dart':
        return 'dart';
      case 'swift':
        return 'swift';
      case 'kt':
      case 'kts':
        return 'kotlin';
      case 'java':
        return 'java';
      case 'h':
      case 'mm':
        return 'objectivec';

      // Web Frontend
      case 'js':
      case 'jsx':
        return 'javascript';
      case 'ts':
      case 'tsx':
        return 'typescript';
      case 'html':
        return 'html';
      case 'css':
        return 'css';
      case 'scss':
      case 'sass':
        return 'scss';
      case 'vue':
        return 'vue';

      // Backend
      case 'py':
        return 'python';
      case 'rb':
        return 'ruby';
      case 'php':
        return 'php';
      case 'go':
        return 'go';
      case 'rs':
        return 'rust';
      case 'cs':
        return 'csharp';
      case 'cpp':
      case 'cc':
      case 'cxx':
        return 'cpp';
      case 'c':
        return 'c';

      // Data & Config
      case 'json':
        return 'json';
      case 'yaml':
      case 'yml':
        return 'yaml';
      case 'xml':
        return 'xml';
      case 'sql':
        return 'sql';
      case 'graphql':
      case 'gql':
        return 'graphql';

      // Shell & Build
      case 'sh':
      case 'bash':
        return 'bash';
      case 'ps1':
        return 'powershell';
      case 'bat':
      case 'cmd':
        return 'batch';
      case 'gradle':
        return 'gradle';
      case 'dockerfile':
        return 'dockerfile';

      // Documentation
      case 'md':
      case 'markdown':
        return 'markdown';
      case 'tex':
        return 'latex';
      case 'rst':
        return 'restructuredtext';

      // Others
      case 'r':
        return 'r';
      case 'matlab':
        return 'matlab';
      case 'm':
        // Dosya adına göre Objective-C veya MATLAB olduğunu belirle
        final fileName = path.split('/').last.toLowerCase();
        return fileName.contains('matlab') ? 'matlab' : 'objectivec';
      case 'scala':
        return 'scala';
      case 'perl':
      case 'pl':
        return 'perl';
      case 'lua':
        return 'lua';
      case 'ex':
      case 'exs':
        return 'elixir';

      default:
        return 'plaintext';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: LoadingListItem(
          height: 200,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadContent,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Repo bilgileri
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.folder_outlined),
              const SizedBox(width: 8),
              Text(
                '${_repoInfo!['owner']}/${_repoInfo!['repo']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'branch: ${_repoInfo!['branch']}',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // Dosya listesi veya içerik
        if (_contents != null) ...[
          Expanded(
            child: ListView.builder(
              itemCount: _contents!.length,
              itemBuilder: (context, index) {
                final item = _contents![index];
                final isDirectory = item['type'] == 'dir';

                return ListTile(
                  leading: Icon(
                    isDirectory ? Icons.folder : Icons.insert_drive_file,
                    color: isDirectory ? Colors.blue : Colors.grey,
                  ),
                  title: Text(item['name']),
                  trailing: isDirectory
                      ? const Icon(Icons.chevron_right)
                      : Text(
                          _getLanguage(item['name']),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                  onTap: () {
                    // TODO: Dizin veya dosya içeriğini göster
                  },
                );
              },
            ),
          ),
        ],

        if (_content != null) ...[
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: HighlightView(
                _content!,
                language: _getLanguage(_repoInfo!['path'] ?? 'md'),
                theme: githubTheme,
                padding: const EdgeInsets.all(16),
                textStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
