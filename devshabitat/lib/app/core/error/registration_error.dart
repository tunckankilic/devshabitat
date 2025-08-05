enum RegistrationErrorType {
  // Validation Errors
  invalidEmail('Geçersiz email formatı'),
  weakPassword('Şifre gereksinimleri karşılanmıyor'),
  passwordMismatch('Şifreler eşleşmiyor'),
  invalidUsername('Geçersiz kullanıcı adı'),

  // Authentication Errors
  emailAlreadyExists('Bu email adresi zaten kayıtlı. Giriş yapmayı deneyin.'),
  authenticationFailed('Kimlik doğrulama başarısız oldu'),

  // GitHub Integration Errors
  githubConnectionFailed('GitHub bağlantısı başarısız oldu'),
  githubRateLimit('GitHub rate limit aşıldı. 10 dakika sonra tekrar deneyin.'),
  githubUserNotFound('GitHub kullanıcısı bulunamadı'),

  // Location Errors
  locationPermissionDenied('Konum izni reddedildi'),
  locationServiceDisabled('Konum servisi kapalı'),
  invalidLocation('Geçersiz konum bilgisi'),

  // Network Errors
  networkTimeout('Bağlantı zaman aşımına uğradı'),
  noInternetConnection('İnternet bağlantısı yok'),
  serverError('Sunucu hatası oluştu'),

  // File Upload Errors
  invalidFileType('Desteklenmeyen dosya türü'),
  fileSizeTooLarge('Dosya boyutu çok büyük'),
  uploadFailed('Dosya yükleme başarısız'),

  // Unknown Error
  unknown('Beklenmeyen bir hata oluştu');

  final String message;
  const RegistrationErrorType(this.message);

  bool get isNetworkError =>
      [networkTimeout, noInternetConnection, serverError].contains(this);

  bool get isRecoverable =>
      ![emailAlreadyExists, invalidFileType, fileSizeTooLarge].contains(this);

  bool get requiresUserAction => [
    locationPermissionDenied,
    locationServiceDisabled,
    noInternetConnection,
  ].contains(this);
}

class RegistrationException implements Exception {
  final RegistrationErrorType type;
  final String? details;
  final dynamic originalError;

  RegistrationException(this.type, {this.details, this.originalError});

  @override
  String toString() {
    if (details != null) {
      return '${type.message} - $details';
    }
    return type.message;
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'message': type.message,
      'details': details,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
