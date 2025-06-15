class GithubStatsModel {
  final String username;
  final int totalRepositories;
  final int totalContributions;
  final Map<String, int> languageStats;
  final List<Map<String, dynamic>> recentRepositories;
  final Map<String, int> contributionGraph;
  final int followers;
  final int following;
  final String? avatarUrl;
  final String? bio;
  final String? location;
  final String? website;
  final String? company;

  GithubStatsModel({
    required this.username,
    required this.totalRepositories,
    required this.totalContributions,
    required this.languageStats,
    required this.recentRepositories,
    required this.contributionGraph,
    required this.followers,
    required this.following,
    this.avatarUrl,
    this.bio,
    this.location,
    this.website,
    this.company,
  });

  factory GithubStatsModel.fromJson(Map<String, dynamic> json) {
    return GithubStatsModel(
      username: json['username'] as String,
      totalRepositories: json['totalRepositories'] as int,
      totalContributions: json['totalContributions'] as int,
      languageStats: Map<String, int>.from(json['languageStats'] as Map),
      recentRepositories: List<Map<String, dynamic>>.from(
        json['recentRepositories'] as List,
      ),
      contributionGraph:
          Map<String, int>.from(json['contributionGraph'] as Map),
      followers: json['followers'] as int,
      following: json['following'] as int,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      website: json['website'] as String?,
      company: json['company'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'totalRepositories': totalRepositories,
      'totalContributions': totalContributions,
      'languageStats': languageStats,
      'recentRepositories': recentRepositories,
      'contributionGraph': contributionGraph,
      'followers': followers,
      'following': following,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'location': location,
      'website': website,
      'company': company,
    };
  }
}
