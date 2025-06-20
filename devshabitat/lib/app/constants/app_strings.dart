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

  // Auth
  static const String login = 'Login';
  static const String register = 'Register';
  static const String forgotPassword = 'Forgot Password';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String username = 'Username';
  static const String logout = 'Logout';

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

  // Profile Fields
  static const String firstName = 'First Name';
  static const String lastName = 'Last Name';
  static const String githubUsername = 'GitHub Username';
  static const String location = 'Location';
  static const String company = 'Company';
  static const String website = 'Website';

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
}
