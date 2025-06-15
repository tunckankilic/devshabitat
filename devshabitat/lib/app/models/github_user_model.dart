import 'package:get/get.dart';
import 'enhanced_user_model.dart';

class GitHubUserModel {
  final RxString id;
  final RxString login;
  final RxString? name;
  final RxString? email;
  final RxString? avatarUrl;
  final RxString? bio;
  final RxString? location;
  final RxString? company;
  final RxString? blog;
  final RxInt? publicRepos;
  final RxInt? publicGists;
  final RxInt? followers;
  final RxInt? following;
  final Rx<DateTime?> createdAt;
  final Rx<DateTime?> updatedAt;
  final RxString? type;
  final RxBool? siteAdmin;
  final RxInt? totalPrivateRepos;
  final RxInt? ownedPrivateRepos;
  final RxInt? diskUsage;
  final RxInt? collaborators;
  final RxString? twitterUsername;
  final RxBool? hireable;
  final RxString? nodeId;
  final RxString? gravatarId;
  final RxString? url;
  final RxString? htmlUrl;
  final RxString? followersUrl;
  final RxString? followingUrl;
  final RxString? gistsUrl;
  final RxString? starredUrl;
  final RxString? subscriptionsUrl;
  final RxString? organizationsUrl;
  final RxString? reposUrl;
  final RxString? eventsUrl;
  final RxString? receivedEventsUrl;
  final RxMap<String, dynamic>? rawData;

  GitHubUserModel({
    required String id,
    required String login,
    String? name,
    String? email,
    String? avatarUrl,
    String? bio,
    String? location,
    String? company,
    String? blog,
    int? publicRepos,
    int? publicGists,
    int? followers,
    int? following,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? type,
    bool? siteAdmin,
    int? totalPrivateRepos,
    int? ownedPrivateRepos,
    int? diskUsage,
    int? collaborators,
    String? twitterUsername,
    bool? hireable,
    String? nodeId,
    String? gravatarId,
    String? url,
    String? htmlUrl,
    String? followersUrl,
    String? followingUrl,
    String? gistsUrl,
    String? starredUrl,
    String? subscriptionsUrl,
    String? organizationsUrl,
    String? reposUrl,
    String? eventsUrl,
    String? receivedEventsUrl,
    Map<String, dynamic>? rawData,
  })  : id = id.obs,
        login = login.obs,
        name = name?.obs,
        email = email?.obs,
        avatarUrl = avatarUrl?.obs,
        bio = bio?.obs,
        location = location?.obs,
        company = company?.obs,
        blog = blog?.obs,
        publicRepos = publicRepos?.obs,
        publicGists = publicGists?.obs,
        followers = followers?.obs,
        following = following?.obs,
        createdAt = createdAt.obs,
        updatedAt = updatedAt.obs,
        type = type?.obs,
        siteAdmin = siteAdmin?.obs,
        totalPrivateRepos = totalPrivateRepos?.obs,
        ownedPrivateRepos = ownedPrivateRepos?.obs,
        diskUsage = diskUsage?.obs,
        collaborators = collaborators?.obs,
        twitterUsername = twitterUsername?.obs,
        hireable = hireable?.obs,
        nodeId = nodeId?.obs,
        gravatarId = gravatarId?.obs,
        url = url?.obs,
        htmlUrl = htmlUrl?.obs,
        followersUrl = followersUrl?.obs,
        followingUrl = followingUrl?.obs,
        gistsUrl = gistsUrl?.obs,
        starredUrl = starredUrl?.obs,
        subscriptionsUrl = subscriptionsUrl?.obs,
        organizationsUrl = organizationsUrl?.obs,
        reposUrl = reposUrl?.obs,
        eventsUrl = eventsUrl?.obs,
        receivedEventsUrl = receivedEventsUrl?.obs,
        rawData = rawData != null ? RxMap<String, dynamic>.from(rawData) : null;

  factory GitHubUserModel.fromJson(Map<String, dynamic> json) {
    return GitHubUserModel(
      id: json['id'].toString(),
      login: json['login'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      company: json['company'] as String?,
      blog: json['blog'] as String?,
      publicRepos: json['public_repos'] as int?,
      publicGists: json['public_gists'] as int?,
      followers: json['followers'] as int?,
      following: json['following'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      type: json['type'] as String?,
      siteAdmin: json['site_admin'] as bool?,
      totalPrivateRepos: json['total_private_repos'] as int?,
      ownedPrivateRepos: json['owned_private_repos'] as int?,
      diskUsage: json['disk_usage'] as int?,
      collaborators: json['collaborators'] as int?,
      twitterUsername: json['twitter_username'] as String?,
      hireable: json['hireable'] as bool?,
      nodeId: json['node_id'] as String?,
      gravatarId: json['gravatar_id'] as String?,
      url: json['url'] as String?,
      htmlUrl: json['html_url'] as String?,
      followersUrl: json['followers_url'] as String?,
      followingUrl: json['following_url'] as String?,
      gistsUrl: json['gists_url'] as String?,
      starredUrl: json['starred_url'] as String?,
      subscriptionsUrl: json['subscriptions_url'] as String?,
      organizationsUrl: json['organizations_url'] as String?,
      reposUrl: json['repos_url'] as String?,
      eventsUrl: json['events_url'] as String?,
      receivedEventsUrl: json['received_events_url'] as String?,
      rawData: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.value,
      'login': login.value,
      'name': name?.value,
      'email': email?.value,
      'avatar_url': avatarUrl?.value,
      'bio': bio?.value,
      'location': location?.value,
      'company': company?.value,
      'blog': blog?.value,
      'public_repos': publicRepos?.value,
      'public_gists': publicGists?.value,
      'followers': followers?.value,
      'following': following?.value,
      'created_at': createdAt.value?.toIso8601String(),
      'updated_at': updatedAt.value?.toIso8601String(),
      'type': type?.value,
      'site_admin': siteAdmin?.value,
      'total_private_repos': totalPrivateRepos?.value,
      'owned_private_repos': ownedPrivateRepos?.value,
      'disk_usage': diskUsage?.value,
      'collaborators': collaborators?.value,
      'twitter_username': twitterUsername?.value,
      'hireable': hireable?.value,
      'node_id': nodeId?.value,
      'gravatar_id': gravatarId?.value,
      'url': url?.value,
      'html_url': htmlUrl?.value,
      'followers_url': followersUrl?.value,
      'following_url': followingUrl?.value,
      'gists_url': gistsUrl?.value,
      'starred_url': starredUrl?.value,
      'subscriptions_url': subscriptionsUrl?.value,
      'organizations_url': organizationsUrl?.value,
      'repos_url': reposUrl?.value,
      'events_url': eventsUrl?.value,
      'received_events_url': receivedEventsUrl?.value,
    };
  }

  EnhancedUserModel toUser() {
    return EnhancedUserModel(
      uid: id.value,
      email: email?.value ?? '',
      displayName: name?.value ?? login.value,
      photoURL: avatarUrl?.value,
      githubUsername: login.value,
      githubAvatarUrl: avatarUrl?.value,
      githubId: id.value,
      githubData: rawData,
    );
  }

  GitHubUserModel copyWith({
    String? id,
    String? login,
    String? name,
    String? email,
    String? avatarUrl,
    String? bio,
    String? location,
    String? company,
    String? blog,
    int? publicRepos,
    int? publicGists,
    int? followers,
    int? following,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? type,
    bool? siteAdmin,
    int? totalPrivateRepos,
    int? ownedPrivateRepos,
    int? diskUsage,
    int? collaborators,
    String? twitterUsername,
    bool? hireable,
    String? nodeId,
    String? gravatarId,
    String? url,
    String? htmlUrl,
    String? followersUrl,
    String? followingUrl,
    String? gistsUrl,
    String? starredUrl,
    String? subscriptionsUrl,
    String? organizationsUrl,
    String? reposUrl,
    String? eventsUrl,
    String? receivedEventsUrl,
    Map<String, dynamic>? rawData,
  }) {
    return GitHubUserModel(
      id: id ?? this.id.value,
      login: login ?? this.login.value,
      name: name ?? this.name?.value,
      email: email ?? this.email?.value,
      avatarUrl: avatarUrl ?? this.avatarUrl?.value,
      bio: bio ?? this.bio?.value,
      location: location ?? this.location?.value,
      company: company ?? this.company?.value,
      blog: blog ?? this.blog?.value,
      publicRepos: publicRepos ?? this.publicRepos?.value,
      publicGists: publicGists ?? this.publicGists?.value,
      followers: followers ?? this.followers?.value,
      following: following ?? this.following?.value,
      createdAt: createdAt ?? this.createdAt.value,
      updatedAt: updatedAt ?? this.updatedAt.value,
      type: type ?? this.type?.value,
      siteAdmin: siteAdmin ?? this.siteAdmin?.value,
      totalPrivateRepos: totalPrivateRepos ?? this.totalPrivateRepos?.value,
      ownedPrivateRepos: ownedPrivateRepos ?? this.ownedPrivateRepos?.value,
      diskUsage: diskUsage ?? this.diskUsage?.value,
      collaborators: collaborators ?? this.collaborators?.value,
      twitterUsername: twitterUsername ?? this.twitterUsername?.value,
      hireable: hireable ?? this.hireable?.value,
      nodeId: nodeId ?? this.nodeId?.value,
      gravatarId: gravatarId ?? this.gravatarId?.value,
      url: url ?? this.url?.value,
      htmlUrl: htmlUrl ?? this.htmlUrl?.value,
      followersUrl: followersUrl ?? this.followersUrl?.value,
      followingUrl: followingUrl ?? this.followingUrl?.value,
      gistsUrl: gistsUrl ?? this.gistsUrl?.value,
      starredUrl: starredUrl ?? this.starredUrl?.value,
      subscriptionsUrl: subscriptionsUrl ?? this.subscriptionsUrl?.value,
      organizationsUrl: organizationsUrl ?? this.organizationsUrl?.value,
      reposUrl: reposUrl ?? this.reposUrl?.value,
      eventsUrl: eventsUrl ?? this.eventsUrl?.value,
      receivedEventsUrl: receivedEventsUrl ?? this.receivedEventsUrl?.value,
      rawData: rawData ?? this.rawData,
    );
  }

  bool get isValid => id.value.isNotEmpty && login.value.isNotEmpty;

  bool get isHireable => hireable?.value ?? false;

  bool get isSiteAdmin => siteAdmin?.value ?? false;

  int get totalRepos =>
      (publicRepos?.value ?? 0) + (totalPrivateRepos?.value ?? 0);

  String get profileUrl =>
      htmlUrl?.value ?? 'https://github.com/${login.value}';
}
