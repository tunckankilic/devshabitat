class AppStrings {
  // General
  static const String appName = 'DevsHabitat';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String accept = 'Accept';

  // Auth
  static const String login = 'Login';
  static const String register = 'Register';
  static const String forgotPassword = 'Forgot Password';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String username = 'Username';
  static const String logout = 'Logout';
  static const String continueWithGithub = 'Continue with GitHub';
  static const String security = 'Güvenlik';

  // Profile
  static const String profile = 'Profile';
  static const String editProfile = 'Edit Profile';
  static const String bio = 'About Me';
  static const String skills = 'Skills';
  static const String experience = 'Experience';
  static const String education = 'Education';
  static const String projects = 'Projects';

  // Discover
  static const String discover = 'Discover';
  static const String search = 'Search';
  static const String filters = 'Filters';
  static const String trending = 'Trending';
  static const String recommended = 'Recommended';

  // Error messages
  static const String errorNetwork = 'No internet connection';
  static const String errorGeneric = 'An error occurred';
  static const String errorAuth =
      'Login failed. Please check your credentials.';
  static const String errorValidation = 'Please fill all fields correctly.';
  static const String errorNoData = 'No Data Found';

  // Success messages
  static const String successLogin = 'Successfully logged in.';
  static const String successRegister = 'Account successfully created.';
  static const String successUpdate = 'Update successful.';
  static const String successDelete = 'Delete successful.';

  // Auth Errors
  static const String errorUserNotFound = 'User not found';
  static const String errorWrongPassword = 'Wrong password';
  static const String errorEmailInUse = 'This email is already in use';
  static const String errorWeakPassword = 'Password is too weak';
  static const String errorInvalidEmail = 'Invalid email address';
  static const String errorOperationNotAllowed = 'Operation not allowed';
  static const String errorAccountExists =
      'Account exists with different credential';
  static const String errorRequiresRecentLogin =
      'This operation requires recent login';
  static const String errorCredentialInUse =
      'This credential is already in use';
  static const String errorProviderAlreadyLinked = 'Provider already linked';
  static const String errorNoSuchProvider = 'No such provider found';
  static const String errorInvalidCredential = 'Invalid credential';

  // Social Auth
  static const String googleLoginCancelled = 'Google login cancelled';
  static const String googleLoginNotSupported =
      'Google login is not supported on this platform';
  static const String githubLoginFailed =
      'GitHub login failed. Please try again.';
  static const String githubUserInfoFailed = 'Could not get GitHub user info';
  static const String facebookLoginFailed = 'Facebook login failed';
  static const String facebookEmailMissing = 'Could not get Facebook email';
  static const String emailAlreadyInUseWithProvider =
      'This email is already in use with {provider}';
  static const String loginWithProvider = 'Login with {provider}';
  static const String registerWithProvider = 'Register with {provider}';

  // Form Validation
  static const String requiredField = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordTooShort =
      'Password must be at least 8 characters';
  static const String passwordRequirements =
      'Password must contain uppercase, lowercase and number';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String usernameTooShort =
      'Username must be at least 3 characters';
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Invalid email format';
  static const String passwordRequired = 'Password is required';
  static const String passwordInvalid = 'Invalid password format';
  static const String displayNameRequired = 'Display name is required';
  static const String displayNameInvalid = 'Invalid display name format';
  static const String confirmPasswordRequired = 'Confirm password is required';
  static const String confirmPasswordInvalid = 'Passwords do not match';
  static const String confirmPasswordHint = 'Confirm your password';

  // Profile Fields
  static const String firstName = 'First Name';
  static const String lastName = 'Last Name';
  static const String githubUsername = 'GitHub Username';
  static const String location = 'Location';
  static const String company = 'Company';
  static const String website = 'Website';
  static const String name = 'Name';
  static const String nameHint = 'Enter your name';
  static const String title = 'Title';
  static const String titleHint = 'Enter your title';
  static const String locationHint = 'Enter your location';
  static const String githubUsernameHint = 'Enter your GitHub username';
  static const String selectProfileImage = 'Select Profile Image';
  static const String gallery = 'Gallery';
  static const String editProfileImage = 'Edit Profile Image';
  static const String errorOccurredWhileSelectingImage =
      'Error occurred while selecting image';
  static const String profileNotFound = 'Profile not found';
  static const String aboutMe = 'About Me';
  static const String frameworks = 'Frameworks';
  static const String github = 'GitHub';
  static const String githubDataNotLoaded = 'GitHub data not loaded';
  static const String githubDataNotFound = 'GitHub data not found';
  static const String workExperience = 'Work Experience';
  static const String currentlyStudying = 'Currently Studying';
  static const String graduate = 'Graduate';
  static const String selectFromGallery = 'Select from Gallery';
  static const String takePhoto = 'Take Photo';
  static const String clear = 'Clear';
  static const String messageTypes = 'Message Types';
  static const String textMessages = 'Text Messages';
  static const String sortingAndPriority = 'Sorting and Priority';
  static const String sorting = 'Sorting';
  static const String priorityMessages = 'Priority Messages';
  static const String selectDate = 'Select Date';
  static const String notSelected = 'Not Selected';
  static const String minimumPriority = 'Minimum Priority';
  static const String selectedValue = 'Selected Value';
  static const String generalSettings = 'General Settings';
  static const String notificationCategories = 'Notification Categories';
  static const String pushNotifications = 'Push Notifications';
  static const String pushNotificationsSubtitle = 'Receive push notifications';
  static const String inAppNotifications = 'In-App Notifications';
  static const String inAppNotificationsSubtitle =
      'Receive in-app notifications';
  static const String eventNotifications = 'Event Notifications';
  static const String eventNotificationsSubtitle =
      'Receive event notifications';
  static const String messageNotifications = 'Message Notifications';
  static const String messageNotificationsSubtitle =
      'Receive message notifications';
  static const String communityNotifications = 'Community Notifications';
  static const String communityNotificationsSubtitle =
      'Receive community notifications';
  static const String connectionNotificationsSubtitle =
      'Receive connection notifications';
  static const String makeProfilePublic = 'Make Profile Public';
  static const String profileVisibilitySubtitle =
      'Your profile visibility settings';
  static const String showLocation = 'Show Location';
  static const String allowConnectionRequests = 'Allow Connection Requests';
  static const String allowMentorshipRequests = 'Allow Mentorship Requests';
  static const String profileDetails = 'Profile Details';
  static const String showTechnologies = 'Show Technologies';
  static const String showBio = 'Show Bio';
  static const String appearance = 'Appearance';
  static const String sound = 'Sound';
  static const String language = 'Language';
  static const String appLanguage = 'App Language';
  static const String account = 'Account';
  static const String signOut = 'Sign Out';
  static const String selectLanguage = 'Select Language';
  static const String callHistory = 'Call History';
  static const String noCallHistory = 'No Call History';
  static const String groupCall = 'Group Call';
  static const String incomingCall = 'Incoming Call';

  // Actions
  static const String connect = 'Connect';
  static const String connecting = 'Connecting...';
  static const String disconnect = 'Disconnect';
  static const String send = 'Send';
  static const String verify = 'Verify';
  static const String update = 'Update';
  static const String next = 'Next';
  static const String back = 'Back';
  static const String finish = 'Finish';

  // Navigation
  static const String home = 'Home';
  static const String messages = 'Messages';
  static const String notifications = 'Notifications';
  static const String settings = 'Settings';

  // Misc
  static const String welcomeBack = 'Welcome Back';
  static const String welcome = 'Welcome to DevsHabitat';
  static const String alreadyHaveAccount = 'Already have an account? Login';
  static const String dontHaveAccount = 'Don\'t have an account? Register';
  static const String or = 'OR';
  static const String matchPercentage = '{percentage}% Match';
  static const String lastSeen = 'Last seen {time}';
  static const String memberSince = 'Member since {date}';

  // Profile
  static const String noTitle = 'No Title';
  static const String noLocations = 'No Locations';
  static const String noBio = 'No Bio';
  static const String noSkills = 'No Skills';
  static const String noExperience = 'No Experience';
  static const String noEducation = 'No Education';
  static const String noProjects = 'No Projects';
  static const String noConnections = 'No Connections';
  static const String noMessages = 'No Messages';
  static const String noNotifications = 'No Notifications';
  static const String noSettings = 'No Settings';
  static const String noProfile = 'No Profile';
  static const String noPhotoUrl = '';
  static const String noName = 'No Name';
  static const String deletePost = 'Delete Post';
  static const String reportPost = 'Report Post';
  static const String githubRepo = 'GitHub Repository';
  static const String postSharing = 'DevShabitat Post Sharing';
  static String postSharingmessage(
      {required String content, required String postId}) {
    return 'A post on \'DevShabitat\': $content\n\nView post: https://devshabitat.com/posts/$postId';
  }

  static const String defaultPicUrl = 'https://via.placeholder.com/150';
  static const String tryAgain = 'Try Again';
  static const String replyHint = 'Write your reply...';
  static const String deleteThread = 'Delete Thread';
  static const String manageNotifications = 'Manage Notifications';
  static const String deleteThreadConfirmation =
      'Are you sure you want to delete this thread?';
  static const String notificationSettings = 'Notification Settings';
  static const String threadNotifications = 'Thread Notifications';
  static const String open = 'Open';
  static const String close = 'Close';
  static const String ok = 'Ok';

  static String reactedWith(String emoji) {
    return 'Reacted with $emoji';
  }

  static const String welcomeDescription =
      'A platform for software developers. Share your projects, collaborate with others and grow together.';

  // Community
  static const String community = 'Community';
  static const String createCommunity = 'Create Community';
  static const String joinCommunity = 'Join Community';
  static const String leaveCommunity = 'Leave Community';
  static const String communityMembers = 'Community Members';
  static const String communityDescription = 'Community Description';
  static const String communityRules = 'Community Rules';
  static const String noCommunities = 'No Communities Found';

  // Events
  static const String events = 'Events';
  static const String createEvent = 'Create Event';
  static const String joinEvent = 'Join Event';
  static const String leaveEvent = 'Leave Event';
  static const String eventDate = 'Event Date';
  static const String eventLocation = 'Event Location';
  static const String eventDescription = 'Event Description';
  static const String noEvents = 'No Events Found';
  static const String upcomingEvents = 'Upcoming Events';
  static const String pastEvents = 'Past Events';

  // Chat & Messages
  static const String newMessage = 'New Message';
  static const String typeMessage = 'Type a message...';
  static const String sendMessage = 'Send Message';
  static const String deleteMessage = 'Delete Message';
  static const String editMessage = 'Edit Message';
  static const String messageDeleted = 'Message deleted';
  static const String chatRoom = 'Chat Room';

  // Video Call
  static const String videoCall = 'Video Call';
  static const String startCall = 'Start Call';
  static const String endCall = 'End Call';
  static const String muteAudio = 'Mute Audio';
  static const String unmuteAudio = 'Unmute Audio';
  static const String toggleCamera = 'Toggle Camera';
  static const String switchCamera = 'Switch Camera';

  // Settings
  static const String accountSettings = 'Account Settings';
  static const String privacySettings = 'Privacy Settings';
  static const String themeSettings = 'Theme Settings';
  static const String languageSettings = 'Language Settings';
  static const String darkMode = 'Dark Mode';
  static const String lightMode = 'Light Mode';
  static const String systemDefault = 'System Default';

  // Networking
  static const String connections = 'Connections';
  static const String pendingRequests = 'Pending Requests';
  static const String acceptRequest = 'Accept Request';
  static const String declineRequest = 'Decline Request';
  static const String sendRequest = 'Send Request';
  static const String cancelRequest = 'Cancel Request';

  // Portfolio
  static const String addProject = 'Add Project';
  static const String editProject = 'Edit Project';
  static const String projectTitle = 'Project Title';
  static const String projectDescription = 'Project Description';
  static const String projectUrl = 'Project URL';
  static const String technologies = 'Technologies Used';
  static const String addSkill = 'Add Skill';
  static const String removeSkill = 'Remove Skill';

  // Location
  static const String currentLocation = 'Current Location';
  static const String searchLocation = 'Search Location';
  static const String nearbyDevelopers = 'Nearby Developers';
  static const String distance = 'Distance';
  static const String locationPermission = 'Location Permission';
  static const String enableLocation = 'Enable Location';

  // Code Sharing
  static const String shareCode = 'Share Code';
  static const String copyCode = 'Copy Code';
  static const String codeSnippet = 'Code Snippet';
  static const String addComment = 'Add Comment';
  static const String syntax = 'Syntax';
  static const String preview = 'Preview';

  // Feed
  static const String noPosts = 'No Posts';
  static const String errorLoadingFeed = 'Error loading feed';
  static const String likes = 'Likes';
  static const String comments = 'Comments';
  static const String shares = 'Shares';
  static const String create = 'Create';
  static const String detail = 'Detail';
  static const String refresh = 'Refresh';

  // Location Status
  static const String online = 'Online';
  static const String offline = 'Offline';

  // Search
  static const String searchMessages = 'Search messages...';

  // Connection
  static const String connectionRequest = 'Connection Request';
  static const String introductionMessage = 'Introduction Message';
  static const String introductionHint = 'Write a brief introduction...';

  // Chat
  static const String deleteChat = 'Delete Chat';
  static const String deleteChatSubtitle =
      'Are you sure you want to delete this chat?';

  // Moderation
  static const String moderationProcess = 'Moderation Process';
  static const String note = 'Note';
  static const String warn = 'Warn';
  static const String ban = 'Ban';

  // GitHub
  static const String githubAuthRequired = 'GitHub Authentication Required';

  // Community Management
  static const String deleteCommunityConfirmation =
      'Are you sure you want to delete this community?';
  static const String moderation = 'Moderation';
  static const String pending = 'Pending';
  static const String completed = 'Completed';
  static const String contentType = 'Content Type';
  static const String reason = 'Reason';
  static const String description = 'Description';
  static const String process = 'Process';
  static const String mute = 'Mute';
  static const String approve = 'Approve';
  static const String reject = 'Reject';
  static const String post = 'Post';
  static const String comment = 'Comment';
  static const String event = 'Event';
  static const String resource = 'Resource';
  static const String myCommunities = 'My Communities';
  static const String joinedCommunities = 'Joined Communities';
  static const String managedCommunities = 'Managed Communities';
  static const String noCommunitiesJoined =
      'You haven\'t joined any communities yet';
  static const String noCommunitiesManaged =
      'You don\'t manage any communities yet';

  // Role Management
  static const String roleManagement = 'Role Management';
  static const String roles = 'Roles';
  static const String members = 'Members';
  static const String newRole = 'New Role';
  static const String roleName = 'Role Name';
  static const String color = 'Color';
  static const String icon = 'Icon';
  static const String priority = 'Priority';
  static const String permissions = 'Permissions';
  static const String deleteRole = 'Delete Role';
  static const String deleteRoleConfirmation =
      'Are you sure you want to delete this role?';
  static const String editRole = 'Edit Role';

  // Role Permissions
  static const String viewContent = 'View Content';
  static const String createContent = 'Create Content';
  static const String editOwnContent = 'Edit Own Content';
  static const String deleteOwnContent = 'Delete Own Content';
  static const String moderateContent = 'Moderate Content';
  static const String banUsers = 'Ban Users';
  static const String manageRoles = 'Manage Roles';
  static const String manageSettings = 'Manage Settings';
  static const String manageRules = 'Manage Rules';
  static const String manageResources = 'Manage Resources';
  static const String createEvents = 'Create Events';
  static const String pinContent = 'Pin Content';
  static const String assignRoles = 'Assign Roles';
  static const String viewAnalytics = 'View Analytics';
  static const String manageMembers = 'Manage Members';
  static const String deleteContent = 'Delete Content';

  // Discovery & Filters
  static const String advancedFilters = 'Advanced Filters';
  static const String reset = 'Reset';
  static const String applyFilters = 'Apply Filters';
  static const String searchSkills = 'Search Skills';
  static const String enterCityOrCountry = 'Enter City or Country';
  static const String enterCompanyName = 'Enter Company Name';
  static const String onlineStatus = 'Online Status';
  static const String showOnlyOnlineUsers = 'Show Only Online Users';
  static const String savedFilters = 'Saved Filters';
  static const String saveFilter = 'Save Filter';
  static const String filterName = 'Filter Name';
  static const String recommendations = 'Recommendations';
  static const String requests = 'Requests';
  static const String searchUser = 'Search User';
  static const String incomingRequests = 'Incoming Requests';
  static const String outgoingRequests = 'Outgoing Requests';
  static const String mutualConnections = 'Mutual Connections';
  static const String viewProfile = 'View Profile';
  static const String removeConnection = 'Remove Connection';
  static const String rejectRequest = 'Reject Request';
  static const String withdrawRequest = 'Withdraw Request';
  static const String rejectRequestConfirmation =
      'Are you sure you want to reject this request?';
  static const String withdrawRequestConfirmation =
      'Are you sure you want to withdraw your request?';
  static const String withdraw = 'Withdraw';
  static const String removeConnectionConfirmation =
      'Are you sure you want to remove this connection?';
  static const String remove = 'Remove';

  // Events
  static const String eventTitle = 'Event Title';
  static const String eventType = 'Event Type';
  static const String inPerson = 'In Person';
  static const String onlineMeetingUrl = 'Online Meeting URL';
  static const String eventAddress = 'Event Address';
  static const String startDate = 'Start Date';
  static const String endDate = 'End Date';
  static const String participantLimit = 'Participant Limit';
  static const String categories = 'Categories';
  static const String meetup = 'Meetup';
  static const String workshop = 'Workshop';
  static const String hackathon = 'Hackathon';
  static const String conference = 'Conference';
  static const String other = 'Other';
  static const String noLocation = 'No Location';
  static const String dateAndTime = 'Date and Time';
  static const String participantCount = 'Participant Count';
  static const String eventDiscovery = 'Event Discovery';
  static const String searchEvent = 'Search Event';
  static const String upcoming = 'Upcoming';
  static const String past = 'Past';
  static const String calendar = 'Calendar';
  static const String noUpcomingEvents = 'No Upcoming Events';
  static const String noPastEvents = 'No Past Events';
  static const String nearbyEvents = 'Nearby Events';
  static const String noNearbyEvents = 'No Nearby Events';
  static const String searchRadius = 'Search Radius';

  // Messaging & Chat
  static const String noChats = 'No Chats';
  static const String startChat = 'Start Chat';
  static const String chat = 'Chat';
  static const String writeYourMessage = 'Write your message...';
  static const String repliedMessage = 'Replied Message';
  static const String edited = 'edited';
  static const String reply = 'Reply';
  static const String forward = 'Forward';
  static const String copy = 'Copy';
  static const String muteNotifications = 'Mute Notifications';
  static const String block = 'Block';
  static const String deleteConversation = 'Delete Conversation';
  static const String confirmDeleteMessage =
      'Are you sure you want to delete this message?';
  static const String confirmDeleteConversation =
      'Are you sure you want to delete this conversation?';
  static const String now = 'now';
  static const String media = 'Media';
  static const String documents = 'Documents';
  static const String links = 'Links';
  static const String recentSearches = 'Recent Searches';
  static const String noResults = 'No Results';
  static const String tryDifferentKeywords = 'Try different keywords';
  static const String dateRange = 'Date Range';
  static const String start = 'Start';
  static const String end = 'End';
  static const String sender = 'Sender';
  static const String messageType = 'Message Type';
  static const String text = 'Text';
  static const String image = 'Image';
  static const String file = 'File';
  static const String clearFilters = 'Clear Filters';
  static const String conversation = 'Conversation';
  static const String date = 'Date';

  // Video Call
  static const String excellent = 'Excellent';
  static const String good = 'Good';
  static const String fair = 'Fair';
  static const String poor = 'Poor';
  static const String disconnected = 'Disconnected';
  static const String connectionDetails = 'Connection Details';
  static const String connectionQuality = 'Connection Quality';
  static const String bitRate = 'Bit Rate';
  static const String packetLoss = 'Packet Loss';
  static const String latency = 'Latency';

  // Home
  static const String noContent = 'No Content';
  static const String startDiscovering = 'Start Discovering';
  static const String like = 'Like';
  static const String share = 'Share';
  static const String originalPost = 'Original Post';
  static const String noComments = 'No Comments';
  static const String makeFirstComment = 'Make First Comment';
  static const String writeYourComment = 'Write your comment...';
  static const String myConnections = 'My Connections';
  static const String viewAll = 'View All';
  static const String totalConnections = 'Total Connections';
  static const String newMessages = 'New Messages';
  static const String githubStats = 'GitHub Stats';
  static const String totalCommits = 'Total Commits';
  static const String openPRs = 'Open PRs';
  static const String contributedRepos = 'Contributed Repos';
  static const String starredRepos = 'Starred Repos';
  static const String followers = 'Followers';
  static const String stars = 'Stars';
  static const String quickActions = 'Quick Actions';
  static const String newProject = 'New Project';
  static const String addConnection = 'Add Connection';
  static const String writeBlog = 'Write Blog';

  // Map
  static const String developersFound = 'Developers Found';
  static const String eventsFound = 'Events Found';
  static const String locationSettings = 'Location Settings';
  static const String locationPermissions = 'Location Permissions';
  static const String locationAccess = 'Location Access';
  static const String allowLocationAccess = 'Allow Location Access';
  static const String backgroundLocation = 'Background Location';
  static const String allowBackgroundLocation = 'Allow Background Location';
  static const String locationTracking = 'Location Tracking';
  static const String locationUpdates = 'Location Updates';
  static const String selectUpdateInterval = 'Select Update Interval';
  static const String batteryOptimization = 'Battery Optimization';
  static const String adjustLocationAccuracy = 'Adjust Location Accuracy';
  static const String receiveNotificationsForNearbyEvents =
      'Receive Notifications for Nearby Events';
  static const String receiveNotificationsForNearbyDevelopers =
      'Receive Notifications for Nearby Developers';
  static const String privacy = 'Privacy';
  static const String locationSharing = 'Location Sharing';
  static const String shareLocationWithOthers = 'Share Location with Others';
  static const String locationHistory = 'Location History';
  static const String manageLocationHistory = 'Manage Location History';
  static const String updateInterval = 'Update Interval';
  static const String high = 'High';
  static const String normal = 'Normal';
  static const String low = 'Low';
  static const String locationAccuracy = 'Location Accuracy';
  static const String moreBatteryUsage = 'More Battery Usage';
  static const String balanced = 'Balanced';
  static const String batterySaving = 'Battery Saving';

  // Portfolio
  static const String beginner = 'Beginner';
  static const String intermediate = 'Intermediate';
  static const String advanced = 'Advanced';
  static const String expert = 'Expert';
  static const String featuredProjects = 'Featured Projects';
  static const String contributionTimeline = 'Contribution Timeline';
  static const String noContributionData = 'No Contribution Data';

  // Networking
  static const String myNetwork = 'My Network';
  static const String generalOverview = 'General Overview';
  static const String analytics = 'Analytics';
  static const String acceptanceRate = 'Acceptance Rate';
  static const String weeklyGrowth = 'Weekly Growth';
  static const String activeConnections = 'Active Connections';
  static const String bestSkills = 'Best Skills';
  static const String recentActivity = 'Recent Activity';
  static const String newConnection = 'New Connection';
  static const String profileView = 'Profile View';
  static const String skillApproval = 'Skill Approval';
  static const String searchConnections = 'Search Connections';
  static const String connectionDistribution = 'Connection Distribution';
  static const String interactionAnalysis = 'Interaction Analysis';
  static const String growthTrend = 'Growth Trend';
  static const String filterOptions = 'Filter Options';
  static const String allConnections = 'All Connections';
  static const String newConnections = 'New Connections';
  static const String sortOptions = 'Sort Options';
  static const String byName = 'By Name';
  static const String byConnectionDate = 'By Connection Date';
  static const String byInteraction = 'By Interaction';

  // Privacy Settings
  static const String profilePrivacy = 'Profile Privacy';
  static const String profileVisibility = 'Profile Visibility';
  static const String connectionRequests = 'Connection Requests';
  static const String newConnectionRequests = 'New Connection Requests';
  static const String blockManagement = 'Block Management';
  static const String blockedUsers = 'Blocked Users';
  static const String manageBlockedUsers = 'Manage Blocked Users';
  static const String public = 'Public';
  static const String everyoneCanSee = 'Everyone can see';
  static const String onlyConnections = 'Only Connections';
  static const String onlyConnectionsCanSee = 'Only connections can see';
  static const String private = 'Private';
  static const String yourProfileIsPrivate = 'Your profile is private';
  static const String removeBlock = 'Remove Block';
  static const String interactions = 'Interactions';
  static const String interactionsWithYourProfile =
      'Interactions with your profile';

  // Professional Tools
  static const String professionalTools = 'Professional Tools';
  static const String profileTools = 'Profile Tools';
  static const String profileAnalysis = 'Profile Analysis';
  static const String analyzeYourProfile = 'Analyze your profile';
  static const String seoOptimization = 'SEO Optimization';
  static const String improveYourSearchResults = 'Improve your search results';
  static const String dataExport = 'Data Export';
  static const String exportYourData = 'Export your data';
  static const String connectionTools = 'Connection Tools';
  static const String connectionManager = 'Connection Manager';
  static const String organizeYourConnections = 'Organize your connections';
  static const String contentSharing = 'Content Sharing';
  static const String shareYourContent = 'Share your content';
  static const String statistics = 'Statistics';
  static const String profileViews = 'Profile Views';
  static const String interactionRate = 'Interaction Rate';
  static const String exportAsPdf = 'Export as PDF';
  static const String exportAsCsv = 'Export as CSV';
  static const String exportAsJson = 'Export as JSON';
  static const String exportingData = 'Exporting Data';
  static const String detailedAnalysis = 'Detailed Analysis';
  static const String connectionGrowth = 'Connection Growth';
  static const String skillAnalysis = 'Skill Analysis';

  // Notifications
  static const String markAllAsRead = 'Mark All as Read';
  static const String filter = 'Filter';
  static const String newNotificationsWillAppearHere =
      'New notifications will appear here';
  static const String filterNotifications = 'Filter Notifications';
  static const String all = 'All';
  static const String unread = 'Unread';
  static const String communities = 'Communities';

  // Error Messages
  static const String errorLoadingRecommendations =
      'Error loading recommendations';
  static const String noRecommendations = 'No recommendations';
  static const String updateProfileForMoreRecommendations =
      'Update your profile for more recommendations';
  static const String recommendedConnections = 'Recommended Connections';
  static const String recommendationsBasedOnSkills =
      'Recommendations based on skills';
  static const String unknownUser = 'Unknown User';
  static const String connectionRequestSent = 'Connection request sent';
  static const String connectionRequestFailed = 'Connection request failed';
  static const String networkError = 'Network Error';
  static const String serverError = 'Server Error';
  static const String saveSuccess = 'Save Success';
  static const String updateSuccess = 'Update Success';
  static const String invalidGitHubUrl = 'Invalid GitHub URL';
  static const String selectImage = 'Select Image';
  static const String imageLoadError = 'Image Load Error';
  static const String imageSaved = 'Image Saved';

  // Chat Settings
  static const String chatSettings = 'Chat Settings';
  static const String export = 'Export';
  static const String exportJson = 'Export JSON';
  static const String exportJsonSubtitle = 'Export chat history as JSON file';
  static const String exportCsv = 'Export CSV';
  static const String exportCsvSubtitle = 'Export chat history as CSV file';
  static const String chatManagement = 'Chat Management';
  static const String unarchive = 'Unarchive';
  static const String archive = 'Archive';
  static const String returnToMainList = 'Return to main list';
  static const String disableNotifications = 'Disable Notifications';
  static const String enableNotifications = 'Enable Notifications';
  static const String disableNotificationsSubtitle =
      'Stop receiving notifications for this chat';
  static const String enableNotificationsSubtitle =
      'Start receiving notifications for this chat';
  static const String blockSubtitle = 'Block messages from this user';
  static const String report = 'Report';
  static const String reportSubtitle = 'Report inappropriate content';
  static const String dangerousOperations = 'Dangerous Operations';
  static const String exporting = 'Exporting...';

  // Code Discussion
  static const String solutionSuggestions = 'Solution Suggestions';

  // Auth
  static const String emailHint = 'Enter your email';
  static const String passwordHint = 'Enter your password';
  static const String displayName = 'Display Name';
  static const String displayNameHint = 'Enter your display name';
  static const String passwordDescription =
      'Password must be at least 8 characters long and contain uppercase, lowercase, and numbers';
  static const String loginDescription =
      'Welcome back! Please sign in to continue';
  static const String continueWithGoogle = 'Continue with Google';
  static const String continueWithApple = 'Sign in with Apple';
  static const String noAccount = 'Don\'t have an account?';
  static const String forgotPasswordDescription =
      'Enter your email to receive a password reset link';
  static const String sendPasswordResetLink = 'Send Password Reset Link';
  static const String skipStep = 'Skip this step';
  static const String completeRegistration = 'Complete Registration';
  static const String continueRegistration = 'Continue Registration';
  static const String registrationSteps = 'Registration Steps';
  static const String basicInfo = 'Basic Information';
  static const String personalInfo = 'Personal Information';
  static const String professionalInfo = 'Professional Information';
  static const String skillsInfo = 'Skills Information';
  static const String bioHint = 'Tell us about yourself';
  static const String locationCoordinates = 'Location Coordinates';
  static const String locationCoordinatesHint =
      'Enter your coordinates (lat, long)';
  static const String coordinatesFormatHint = 'Format: 12.3456, -78.9012';
  static const String locationName = 'Location Name';
  static const String locationNameHint = 'Enter your location name';
  static const String minimumSkillsHint = 'Add at least 3 skills';
  static const String job = 'Job Title';
  static const String jobHint = 'Enter your job title';
  static const String companyHint = 'Enter your company name';
  static const String yearsOfExperience = 'Years of Experience';
  static const String yearsOfExperienceHint = 'Enter your years of experience';
  static const String workPreferences = 'Work Preferences';
  static const String isAvailableForWork = 'Available for Work';
  static const String isRemote = 'Remote Work';
  static const String isFullTime = 'Full Time';
  static const String isPartTime = 'Part Time';
  static const String isFreelance = 'Freelance';
  static const String isInternship = 'Internship';
  static const String professionalInfoDescription =
      'Tell us about your professional experience';
  static const String skill = 'Skill';
  static const String programmingLanguages = 'Programming Languages';
  static const String programmingLanguage = 'Programming Language';
  static const String interests = 'Interests';
  static const String interest = 'Interest';
  static const String socialMediaLinks = 'Social Media Links';
  static const String portfolioUrls = 'Portfolio URLs';
  static const String portfolioUrl = 'Portfolio URL';
  static const String skillsInfoDescription =
      'Tell us about your skills and interests';
  static const String add = 'Add';

  // Community
  static const String communityName = 'Community Name';
  static const String communityNameHint = 'Enter community name';
  static const String communityNameRequired = 'Community name is required';
  static const String communityDescriptionHint = 'Enter community description';
  static const String communityDescriptionRequired =
      'Community description is required';
  static const String membershipApprovalRequired =
      'Membership Approval Required';
  static const String membershipApprovalRequiredDescription =
      'New members need approval to join';
  static const String onlyMembersCanView = 'Only Members Can View';
  static const String onlyMembersCanViewDescription =
      'Only members can view community content';
  static const String communityNotFound = 'Community not found';
  static const String discoverCommunities = 'Discover Communities';
  static const String noCommunitiesFound = 'No communities found';
  static const String errorLoadingEvents = 'Error loading events';
  static const String communityEvents = 'Community Events';
  static const String newEvent = 'New Event';
  static const String allEvents = 'All Events';
  static const String onlyUpcoming = 'Only Upcoming';
  static const String onlyOnline = 'Only Online';
  static const String onlyOffline = 'Only Offline';
  static const String noEventsFound = 'No events found';
  static const String tryChangingFilters = 'Try changing filters';
  static const String join = 'Join';
  static const String more = 'More';
  static const String inProgress = 'In Progress';
  static const String category = 'Category';
  static const String apply = 'Apply';
  static const String eventJoinRequestSent = 'Event join request sent';
  static const String eventShareLinkCopied = 'Event share link copied';
  static const String copyLink = 'Copy Link';
  static const String deleteEvent = 'Delete Event';
  static const String deleteEventConfirmation =
      'Are you sure you want to delete this event?';
  static const String eventDeleted = 'Event deleted successfully';
  static const String communityManagement = 'Community Management';
  static const String deleteCommunity = 'Delete Community';
  static const String coverPhoto = 'Cover Photo';
  static const String saveChanges = 'Save Changes';

  // Event
  static const String noEventsForDay = 'No events for this day';
  static const String eventEnded = 'Event has ended';
  static const String quotaFull = 'Event quota is full';
  static const String cancelRegistration = 'Cancel Registration';

  // Time Formats
  static String dateTimeFormat(DateTime date) => 'Date: ${date.toString()}';
  static String daysAgo(int days) => '$days days ago';
  static String minutesAgo(int minutes) => '$minutes minutes ago';
  static String hoursAgo(int hours) => '$hours hours ago';
  static const String justNow = 'Just now';

  // Repository Errors
  static const String emailAlreadyInUse = 'This email is already in use';
  static const String userNotLoggedIn = 'User not logged in';
  static const String userProfileNotFound = 'User profile not found';
  static const String githubAccountAlreadyLinked =
      'GitHub account already linked';
  static const String githubAccountAlreadyInUse =
      'GitHub account already in use';
  static const String feedLoadingError = 'Error loading feed';
  static const String likeError = 'Error liking post';
  static const String unlikeError = 'Error unliking post';
  static const String shareError = 'Error sharing post';

  // Map Controls
  static const String zoomIn = 'Zoom In';
  static const String zoomOut = 'Zoom Out';
  static const String recenter = 'Recenter';
  static const String toggleLayer = 'Toggle Layer';
  static const String refreshMap = 'Refresh Map';
  static const String locateMe = 'Locate Me';
  static const String changeMapType = 'Change Map Type';
  static const String showFilters = 'Show Filters';
  static const String distanceFilter = 'Distance Filter';
  static const String onlineOnly = 'Online Only';

  // Profile
  static const String about = 'About';
  static const String currently = 'Currently';
  static const String noCompany = 'No Company';
  static const String profileImageUpdatedSuccessfully =
      'Profile image updated successfully';
  static const String profileImageUpdateError = 'Error updating profile image';
  static const String locationCoordinatesUpdated =
      'Location coordinates updated';
  static const String invalidCoordinates = 'Invalid coordinates';
  static const String coordinatesValidationMessage =
      'Please enter valid coordinates';
  static const String invalidFormat = 'Invalid format';

  // Developer Matching
  static const String matchingAlgorithm = 'Matching Algorithm';
  static const String matchingScore = 'Matching Score';
  static const String skillMatch = 'Skill Match';
  static const String locationMatch = 'Location Match';
  static const String interestMatch = 'Interest Match';
  static const String experienceMatch = 'Experience Match';
  static const String matchingPreferences = 'Matching Preferences';
  static const String matchingResults = 'Matching Results';
  static const String matchingCriteria = 'Matching Criteria';
  static const String matchingSettings = 'Matching Settings';
  static const String matchingRange = 'Matching Range';
  static const String matchingThreshold = 'Matching Threshold';
  static const String matchingFilters = 'Matching Filters';
  static const String matchingPriorities = 'Matching Priorities';
  static const String matchingHistory = 'Matching History';
  static const String matchingAnalytics = 'Matching Analytics';
  static const String matchingInsights = 'Matching Insights';
  static const String matchingRecommendations = 'Matching Recommendations';
  static const String matchingFeedback = 'Matching Feedback';
  static const String matchingOptimization = 'Matching Optimization';

  // Connection
  static const String connectionStatus = 'Connection Status';
  static const String connectionType = 'Connection Type';
  static const String connectionStrength = 'Connection Strength';
  static const String connectionSettings = 'Connection Settings';
  static const String connectionPreferences = 'Connection Preferences';
  static const String connectionHistory = 'Connection History';
  static const String connectionAnalytics = 'Connection Analytics';
  static const String connectionInsights = 'Connection Insights';
  static const String connectionRecommendations = 'Connection Recommendations';
  static const String connectionFeedback = 'Connection Feedback';
  static const String connectionOptimization = 'Connection Optimization';
  static const String connectionSecurity = 'Connection Security';
  static const String connectionPrivacy = 'Connection Privacy';
  static const String connectionPermissions = 'Connection Permissions';
  static const String connectionNotifications = 'Connection Notifications';
  static const String connectionAlerts = 'Connection Alerts';
  static const String connectionWarnings = 'Connection Warnings';
  static const String connectionErrors = 'Connection Errors';
  static const String connectionLogs = 'Connection Logs';
  static const String connectionMetrics = 'Connection Metrics';

  // Location
  static const String locationServices = 'Location Services';
  static const String locationStatus = 'Location Status';
  static const String locationMode = 'Location Mode';
  static const String locationPreferences = 'Location Preferences';
  static const String locationAnalytics = 'Location Analytics';
  static const String locationInsights = 'Location Insights';
  static const String locationRecommendations = 'Location Recommendations';
  static const String locationFeedback = 'Location Feedback';
  static const String locationOptimization = 'Location Optimization';
  static const String locationSecurity = 'Location Security';
  static const String locationPrivacy = 'Location Privacy';
  static const String locationNotifications = 'Location Notifications';
  static const String locationAlerts = 'Location Alerts';
  static const String locationWarnings = 'Location Warnings';
  static const String locationErrors = 'Location Errors';
  static const String locationLogs = 'Location Logs';
  static const String locationMetrics = 'Location Metrics';

  // Map
  static const String mapServices = 'Map Services';
  static const String mapStatus = 'Map Status';
  static const String mapMode = 'Map Mode';
  static const String mapPreferences = 'Map Preferences';
  static const String mapHistory = 'Map History';
  static const String mapAnalytics = 'Map Analytics';
  static const String mapInsights = 'Map Insights';
  static const String mapRecommendations = 'Map Recommendations';
  static const String mapFeedback = 'Map Feedback';
  static const String mapOptimization = 'Map Optimization';
  static const String mapSecurity = 'Map Security';
  static const String mapPrivacy = 'Map Privacy';
  static const String mapPermissions = 'Map Permissions';
  static const String mapNotifications = 'Map Notifications';
  static const String mapAlerts = 'Map Alerts';
  static const String mapWarnings = 'Map Warnings';
  static const String mapErrors = 'Map Errors';
  static const String mapLogs = 'Map Logs';
  static const String mapMetrics = 'Map Metrics';

  // Validation Messages
  static const String locationCoordinatesRequired =
      'Location coordinates are required';
  static const String locationCoordinatesInvalid =
      'Invalid location coordinates format';
  static const String minimumSkillsRequired = 'At least 3 skills are required';
  static const String invalidSkillFormat = 'Invalid skill format';
  static const String invalidPortfolioUrl = 'Invalid portfolio URL format';
  static const String invalidSocialMediaUrl = 'Invalid social media URL format';
  static const String invalidGithubUsername = 'Invalid GitHub username format';
  static const String invalidLinkedinUrl = 'Invalid LinkedIn URL format';
  static const String invalidTwitterHandle = 'Invalid Twitter handle format';
  static const String invalidWebsiteUrl = 'Invalid website URL format';
  static const String invalidPhoneNumber = 'Invalid phone number format';
  static const String invalidDateFormat = 'Invalid date format';
  static const String invalidTimeFormat = 'Invalid time format';
  static const String invalidDuration = 'Invalid duration format';
  static const String invalidCapacity = 'Invalid capacity value';
  static const String invalidPrice = 'Invalid price value';
  static const String invalidRange = 'Invalid range value';
  static const String invalidCoordinateRange = 'Coordinates out of valid range';
  static const String invalidZoomLevel = 'Invalid zoom level';
  static const String invalidRadius = 'Invalid radius value';
  static const String invalidDistance = 'Invalid distance value';
  static const String invalidLatitude = 'Invalid latitude value';
  static const String invalidLongitude = 'Invalid longitude value';
  static const String invalidAltitude = 'Invalid altitude value';
  static const String invalidAccuracy = 'Invalid accuracy value';
  static const String invalidHeading = 'Invalid heading value';
  static const String invalidSpeed = 'Invalid speed value';
  static const String invalidTimestamp = 'Invalid timestamp value';

  // Error Messages
  static const String errorLoadingProfile = 'Error loading profile';
  static const String errorUpdatingProfile = 'Error updating profile';
  static const String errorDeletingProfile = 'Error deleting profile';
  static const String errorLoadingSkills = 'Error loading skills';
  static const String errorUpdatingSkills = 'Error updating skills';
  static const String errorDeletingSkills = 'Error deleting skills';
  static const String errorLoadingLocation = 'Error loading location';
  static const String errorUpdatingLocation = 'Error updating location';
  static const String errorDeletingLocation = 'Error deleting location';
  static const String errorLoadingPortfolio = 'Error loading portfolio';
  static const String errorUpdatingPortfolio = 'Error updating portfolio';
  static const String errorDeletingPortfolio = 'Error deleting portfolio';
  static const String errorLoadingSocialMedia = 'Error loading social media';
  static const String errorUpdatingSocialMedia = 'Error updating social media';
  static const String errorDeletingSocialMedia = 'Error deleting social media';
  static const String errorLoadingGithub = 'Error loading GitHub data';
  static const String errorUpdatingGithub = 'Error updating GitHub data';
  static const String errorDeletingGithub = 'Error deleting GitHub data';
  static const String errorLoadingLinkedin = 'Error loading LinkedIn data';
  static const String errorUpdatingLinkedin = 'Error updating LinkedIn data';
  static const String errorDeletingLinkedin = 'Error deleting LinkedIn data';
  static const String errorLoadingTwitter = 'Error loading Twitter data';
  static const String errorUpdatingTwitter = 'Error updating Twitter data';
  static const String errorDeletingTwitter = 'Error deleting Twitter data';
  static const String errorLoadingWebsite = 'Error loading website data';
  static const String errorUpdatingWebsite = 'Error updating website data';
  static const String errorDeletingWebsite = 'Error deleting website data';

  // Community & Events
  static const String coverImage = 'Cover Image';
  static const String communitySettings = 'Community Settings';
  static const String locationNotSet = 'Location not set';
  static const String participants = 'Participants';
  static const String membershipRequests = 'Membership Requests';
  static const String myEvents = 'My Events';
  static const String peopleYouMayKnow = 'People You May Know';
  static const String posts = 'Posts';
  static const String communityStatistics = 'Community Statistics';
  static const String activity = 'Activity';
  static const String rating = 'Rating';
  static const String activityLevel = 'Activity Level';
  static const String veryHigh = 'Very High';
  static const String medium = 'Medium';
  static const String veryLow = 'Very Low';
  static const String promote = 'Promote';
  static const String onRemoveMember = 'Remove Member';
  static const String noPendingMembers = 'No Pending Members';

  // Connection & Matching
  static const String requestSent = 'Request Sent';
  static const String similarDevelopers = 'Similar Developers';
  static const String noSimilarDevelopers = 'No Similar Developers Found';
  static const String projectSuggestions = 'Project Suggestions';
  static const String noProjectSuggestions = 'No Project Suggestions';
  static const String mentorshipOpportunities = 'Mentorship Opportunities';
  static const String noMentors = 'No Mentors Available';
  static const String mentorshipRequest = 'Mentorship Request';

  // Video Call Controls
  static const String microphone = 'Microphone';
  static const String camera = 'Camera';
  static const String changeCamera = 'Change Camera';
  static const String screenShare = 'Screen Share';
  static const String record = 'Record';
  static const String recording = 'Recording';
  static const String reconnecting = 'Reconnecting';

  // App Info
  static const String appInfo = 'Uygulama Bilgileri';
  static const String appVersion = 'Uygulama Sürümü';
  static const String developerInfo = 'Geliştirici Bilgileri';
  static const String systemStatus = 'Sistem Durumu';
  static const String networkStatus = 'Bağlantı Durumu';
  static const String themeMode = 'Tema Modu';
  static const String lastUpdate = 'Son Güncelleme';
  static const String buildNumber = 'Build Numarası';
  static const String packageName = 'Paket Adı';
  static const String deviceInfo = 'Cihaz Bilgileri';
  static const String operatingSystem = 'İşletim Sistemi';
  static const String deviceModel = 'Cihaz Modeli';
  static const String screenResolution = 'Ekran Çözünürlüğü';
  static const String memoryUsage = 'Bellek Kullanımı';
  static const String storageUsage = 'Depolama Kullanımı';

  // Chat Management
  static const String archiveChats = 'Sohbetleri Arşivle';
  static const String archiveChatsDesc = 'Seçili sohbetleri arşivle ve yedekle';
  static const String exportChats = 'Sohbetleri Dışa Aktar';
  static const String exportChatsDesc =
      'Sohbet geçmişini farklı formatlarda dışa aktar';
  static const String deleteChats = 'Sohbetleri Sil';
  static const String deleteChatsDesc = 'Seçili sohbetleri kalıcı olarak sil';
  static const String chatArchived = 'Sohbet başarıyla arşivlendi';
  static const String chatExported = 'Sohbet başarıyla dışa aktarıldı';
  static const String chatDeleted = 'Sohbet başarıyla silindi';
  static const String confirmArchive =
      'Bu sohbeti arşivlemek istediğinize emin misiniz?';
  static const String confirmExport =
      'Bu sohbeti dışa aktarmak istediğinize emin misiniz?';
  static const String confirmDelete =
      'Bu sohbeti silmek istediğinize emin misiniz?';
  static const String processing = 'İşleniyor...';
  static const String selectExportFormat = 'Dışa aktarma formatını seçin';
  static const String archiveInProgress = 'Arşivleme devam ediyor...';
  static const String exportInProgress = 'Dışa aktarma devam ediyor...';
  static const String deleteInProgress = 'Silme işlemi devam ediyor...';
  static const String operationSuccess = 'İşlem başarılı';
  static const String operationFailed = 'İşlem başarısız';
  static const String message = 'Mesaj';
}
