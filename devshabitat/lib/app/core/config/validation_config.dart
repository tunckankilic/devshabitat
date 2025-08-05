class ValidationConfig {
  static const int minCommunityNameLength = 3;
  static const int maxCommunityNameLength = 50;
  static const int minCommunityDescriptionLength = 10;
  static const int maxCommunityDescriptionLength = 500;

  static const int maxImageWidth = 2048;
  static const int maxImageHeight = 2048;
  static const int maxCoverImageSizeMB = 5;

  static const List<String> allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
  ];
}
