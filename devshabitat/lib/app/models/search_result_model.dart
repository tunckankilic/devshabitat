import 'user_profile_model.dart';
import 'blog_model.dart';
import 'community/community_model.dart';
import 'event/event_model.dart';

class SearchResultModel {
  final String query;
  List<UserProfile> users;
  List<BlogModel> blogs;
  List<CommunityModel> communities;
  List<EventModel> events;
  int totalResults;

  SearchResultModel({
    required this.query,
    required this.users,
    required this.blogs,
    required this.communities,
    required this.events,
    required this.totalResults,
  });

  factory SearchResultModel.empty(String query) {
    return SearchResultModel(
      query: query,
      users: [],
      blogs: [],
      communities: [],
      events: [],
      totalResults: 0,
    );
  }

  bool get hasResults => totalResults > 0;
  bool get hasUsers => users.isNotEmpty;
  bool get hasBlogs => blogs.isNotEmpty;
  bool get hasCommunities => communities.isNotEmpty;
  bool get hasEvents => events.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'query': query,
      'users': users.map((user) => user.toJson()).toList(),
      'blogs': blogs.map((blog) => blog.toMap()).toList(),
      'communities': communities
          .map((community) => community.toJson())
          .toList(),
      'events': events.map((event) => event.toMap()).toList(),
      'totalResults': totalResults,
    };
  }

  factory SearchResultModel.fromMap(Map<String, dynamic> map) {
    return SearchResultModel(
      query: map['query'] ?? '',
      users:
          (map['users'] as List<dynamic>?)
              ?.map(
                (item) => UserProfile.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      blogs:
          (map['blogs'] as List<dynamic>?)
              ?.map((item) => BlogModel.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      communities:
          (map['communities'] as List<dynamic>?)
              ?.map(
                (item) => CommunityModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      events:
          (map['events'] as List<dynamic>?)
              ?.map((item) => EventModel.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalResults: map['totalResults'] ?? 0,
    );
  }
}
