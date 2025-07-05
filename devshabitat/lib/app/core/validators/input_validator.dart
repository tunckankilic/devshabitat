import '../config/security_config.dart';

class InputValidator {
  // Genel input validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName alanı zorunludur';
    }
    return null;
  }

  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta adresi zorunludur';
    }
    if (value.length > SecurityConfig.MAX_EMAIL_LENGTH) {
      return 'E-posta adresi çok uzun';
    }
    if (!SecurityConfig.isEmailValid(value)) {
      return 'Geçerli bir e-posta adresi giriniz';
    }
    return null;
  }

  // Şifre validation
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Şifre zorunludur';
    }
    if (value.length < SecurityConfig.MIN_PASSWORD_LENGTH) {
      return 'Şifre en az ${SecurityConfig.MIN_PASSWORD_LENGTH} karakter olmalıdır';
    }
    if (value.length > SecurityConfig.MAX_PASSWORD_LENGTH) {
      return 'Şifre en fazla ${SecurityConfig.MAX_PASSWORD_LENGTH} karakter olmalıdır';
    }
    if (!SecurityConfig.isPasswordValid(value)) {
      return 'Şifre en az bir harf ve bir rakam içermelidir';
    }
    return null;
  }

  // Kullanıcı adı validation
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kullanıcı adı zorunludur';
    }
    if (value.length > SecurityConfig.MAX_USERNAME_LENGTH) {
      return 'Kullanıcı adı çok uzun';
    }
    if (!SecurityConfig.isUsernameValid(value)) {
      return 'Kullanıcı adı sadece harf, rakam ve alt çizgi içerebilir';
    }
    return null;
  }

  // Telefon numarası validation
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefon numarası zorunludur';
    }
    if (value.length > SecurityConfig.MAX_PHONE_LENGTH) {
      return 'Telefon numarası çok uzun';
    }
    if (!SecurityConfig.isPhoneValid(value)) {
      return 'Geçerli bir telefon numarası giriniz';
    }
    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // URL opsiyonel olabilir
    }
    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || !uri.hasAuthority) {
        return 'Geçerli bir URL giriniz';
      }
    } catch (e) {
      return 'Geçerli bir URL giriniz';
    }
    return null;
  }

  // Tarih validation
  static String? validateDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tarih zorunludur';
    }
    try {
      final date = DateTime.parse(value);
      if (date.isAfter(DateTime.now())) {
        return 'Gelecek bir tarih giremezsiniz';
      }
    } catch (e) {
      return 'Geçerli bir tarih giriniz';
    }
    return null;
  }

  // Sayı validation
  static String? validateNumber(
    String? value, {
    double? min,
    double? max,
    bool allowDecimals = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Bu alan zorunludur';
    }
    try {
      final number = allowDecimals ? double.parse(value) : int.parse(value);
      if (min != null && number < min) {
        return 'En az $min olmalıdır';
      }
      if (max != null && number > max) {
        return 'En fazla $max olmalıdır';
      }
    } catch (e) {
      return allowDecimals
          ? 'Geçerli bir sayı giriniz'
          : 'Geçerli bir tam sayı giriniz';
    }
    return null;
  }

  // Dosya adı validation
  static String? validateFileName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Dosya adı zorunludur';
    }
    if (value.length > SecurityConfig.MAX_FILE_NAME_LENGTH) {
      return 'Dosya adı çok uzun';
    }
    if (!SecurityConfig.isFileNameSafe(value)) {
      return 'Geçersiz dosya adı';
    }
    return null;
  }

  // Kredi kartı numarası validation
  static String? validateCreditCard(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kredi kartı numarası zorunludur';
    }
    // Sadece rakamları al
    final cleanNumber = value.replaceAll(RegExp(r'\D'), '');
    if (cleanNumber.length != 16) {
      return 'Geçerli bir kredi kartı numarası giriniz';
    }
    // Luhn algoritması kontrolü
    int sum = 0;
    bool alternate = false;
    for (int i = cleanNumber.length - 1; i >= 0; i--) {
      int n = int.parse(cleanNumber[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) {
          n = (n % 10) + 1;
        }
      }
      sum += n;
      alternate = !alternate;
    }
    if (sum % 10 != 0) {
      return 'Geçerli bir kredi kartı numarası giriniz';
    }
    return null;
  }

  // Para miktarı validation
  static String? validateAmount(
    String? value, {
    double? min,
    double? max,
    String? currency = 'TL',
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Tutar zorunludur';
    }
    try {
      final amount = double.parse(value.replaceAll(RegExp(r'[^\d.]'), ''));
      if (min != null && amount < min) {
        return 'En az $min $currency olmalıdır';
      }
      if (max != null && amount > max) {
        return 'En fazla $max $currency olmalıdır';
      }
      if (amount <= 0) {
        return 'Geçerli bir tutar giriniz';
      }
    } catch (e) {
      return 'Geçerli bir tutar giriniz';
    }
    return null;
  }

  // Metin uzunluğu validation
  static String? validateLength(
    String? value, {
    required int minLength,
    int? maxLength,
    String? fieldName,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Bu alan'} zorunludur';
    }
    if (value.length < minLength) {
      return '${fieldName ?? 'Bu alan'} en az $minLength karakter olmalıdır';
    }
    if (maxLength != null && value.length > maxLength) {
      return '${fieldName ?? 'Bu alan'} en fazla $maxLength karakter olmalıdır';
    }
    return null;
  }

  // Özel karakter kontrolü
  static String? validateSpecialCharacters(
    String? value, {
    required String allowedCharacters,
    String? fieldName,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Bu alan'} zorunludur';
    }
    final regex = RegExp('[^$allowedCharacters]');
    if (regex.hasMatch(value)) {
      return '${fieldName ?? 'Bu alan'} sadece şu karakterleri içerebilir: $allowedCharacters';
    }
    return null;
  }
}
