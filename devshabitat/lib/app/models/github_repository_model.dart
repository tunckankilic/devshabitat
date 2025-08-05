class GitHubRepositoryModel {
  final String id;
  final String name;
  final String? description;
  final String owner;
  final bool isPrivate;
  final bool hasReadme;
  final int stars;
  final int forks;
  final int watchers;
  final Map<String, double> languages;
  final List<String> topics;
  final String defaultBranch;
  final DateTime createdAt;
  final DateTime updatedAt;

  GitHubRepositoryModel({
    required this.id,
    required this.name,
    this.description,
    required this.owner,
    required this.isPrivate,
    required this.hasReadme,
    required this.stars,
    required this.forks,
    required this.watchers,
    required this.languages,
    required this.topics,
    required this.defaultBranch,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GitHubRepositoryModel.fromJson(Map<String, dynamic> json) {
    return GitHubRepositoryModel(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      owner: json['owner']['login'],
      isPrivate: json['private'] ?? false,
      hasReadme: json['has_readme'] ?? false,
      stars: json['stargazers_count'] ?? 0,
      forks: json['forks_count'] ?? 0,
      watchers: json['watchers_count'] ?? 0,
      languages: Map<String, double>.from(json['languages'] ?? {}),
      topics: List<String>.from(json['topics'] ?? []),
      defaultBranch: json['default_branch'] ?? 'main',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'owner': {'login': owner},
      'private': isPrivate,
      'has_readme': hasReadme,
      'stargazers_count': stars,
      'forks_count': forks,
      'watchers_count': watchers,
      'languages': languages,
      'topics': topics,
      'default_branch': defaultBranch,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
