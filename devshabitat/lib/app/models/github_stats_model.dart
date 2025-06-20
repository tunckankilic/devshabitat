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
      totalRepositories: json['total_repositories'] as int,
      totalContributions: json['total_contributions'] as int,
      languageStats: Map<String, int>.from(json['language_stats']),
      recentRepositories:
          List<Map<String, dynamic>>.from(json['recent_repositories']),
      contributionGraph: Map<String, int>.from(json['contribution_graph']),
      followers: json['followers'] as int,
      following: json['following'] as int,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      website: json['website'] as String?,
      company: json['company'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'total_repositories': totalRepositories,
      'total_contributions': totalContributions,
      'language_stats': languageStats,
      'recent_repositories': recentRepositories,
      'contribution_graph': contributionGraph,
      'followers': followers,
      'following': following,
      'avatar_url': avatarUrl,
      'bio': bio,
      'location': location,
      'website': website,
      'company': company,
    };
  }
}
