import '../config/security_config.dart';

class InputValidator {
  // General input validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName field is required';
    }
    return null;
  }

  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    if (value.length > SecurityConfig.MAX_EMAIL_LENGTH) {
      return 'Email address is too long';
    }
    if (!SecurityConfig.isEmailValid(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < SecurityConfig.MIN_PASSWORD_LENGTH) {
      return 'Password must be at least ${SecurityConfig.MIN_PASSWORD_LENGTH} characters';
    }
    if (value.length > SecurityConfig.MAX_PASSWORD_LENGTH) {
      return 'Password must be at most ${SecurityConfig.MAX_PASSWORD_LENGTH} characters';
    }
    if (!SecurityConfig.isPasswordValid(value)) {
      return 'Password must contain at least one letter and one number';
    }
    return null;
  }

  // Username validation
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.length > SecurityConfig.MAX_USERNAME_LENGTH) {
      return 'Username is too long';
    }
    if (!SecurityConfig.isUsernameValid(value)) {
      return 'Username can only contain letters, numbers and underscores';
    }
    return null;
  }

  // Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (value.length > SecurityConfig.MAX_PHONE_LENGTH) {
      return 'Phone number is too long';
    }
    if (!SecurityConfig.isPhoneValid(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // URL can be optional
    }
    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || !uri.hasAuthority) {
        return 'Please enter a valid URL';
      }
    } catch (e) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  // Date validation
  static String? validateDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Date is required';
    }
    try {
      final date = DateTime.parse(value);
      if (date.isAfter(DateTime.now())) {
        return 'Cannot enter a future date';
      }
    } catch (e) {
      return 'Please enter a valid date';
    }
    return null;
  }

  // Number validation
  static String? validateNumber(
    String? value, {
    double? min,
    double? max,
    bool allowDecimals = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    try {
      final number = allowDecimals ? double.parse(value) : int.parse(value);
      if (min != null && number < min) {
        return 'Must be at least $min';
      }
      if (max != null && number > max) {
        return 'Must be at most $max';
      }
    } catch (e) {
      return allowDecimals
          ? 'Please enter a valid number'
          : 'Please enter a valid integer';
    }
    return null;
  }

  // File name validation
  static String? validateFileName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'File name is required';
    }
    if (value.length > SecurityConfig.MAX_FILE_NAME_LENGTH) {
      return 'File name is too long';
    }
    if (!SecurityConfig.isFileNameSafe(value)) {
      return 'Invalid file name';
    }
    return null;
  }

  // Credit card number validation
  static String? validateCreditCard(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Credit card number is required';
    }
    // Get only numbers
    final cleanNumber = value.replaceAll(RegExp(r'\D'), '');
    if (cleanNumber.length != 16) {
      return 'Please enter a valid credit card number';
    }
    // Luhn algorithm check
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
      return 'Please enter a valid credit card number';
    }
    return null;
  }

  // Amount validation
  static String? validateAmount(
    String? value, {
    double? min,
    double? max,
    String? currency = 'USD',
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    try {
      final amount = double.parse(value.replaceAll(RegExp(r'[^\d.]'), ''));
      if (min != null && amount < min) {
        return 'Must be at least $min $currency';
      }
      if (max != null && amount > max) {
        return 'Must be at most $max $currency';
      }
      if (amount <= 0) {
        return 'Please enter a valid amount';
      }
    } catch (e) {
      return 'Please enter a valid amount';
    }
    return null;
  }

  // Text length validation
  static String? validateLength(
    String? value, {
    required int minLength,
    int? maxLength,
    String? fieldName,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    if (value.length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters';
    }
    if (maxLength != null && value.length > maxLength) {
      return '${fieldName ?? 'This field'} must be at most $maxLength characters';
    }
    return null;
  }

  // Special character validation
  static String? validateSpecialCharacters(
    String? value, {
    required String allowedCharacters,
    String? fieldName,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    final regex = RegExp('[^$allowedCharacters]');
    if (regex.hasMatch(value)) {
      return '${fieldName ?? 'This field'} can only contain the following characters: $allowedCharacters';
    }
    return null;
  }
}
