class ProjectModel {
  final String name;
  final String description;
  final String language;
  final int stars;
  final int forks;
  final String url;
  final List<String> topics;

  ProjectModel({
    required this.name,
    required this.description,
    required this.language,
    required this.stars,
    required this.forks,
    required this.url,
    required this.topics,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      name: json['name'] as String,
      description: json['description'] as String,
      language: json['language'] as String,
      stars: json['stars'] as int,
      forks: json['forks'] as int,
      url: json['url'] as String,
      topics: List<String>.from(json['topics'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'language': language,
      'stars': stars,
      'forks': forks,
      'url': url,
      'topics': topics,
    };
  }
}
