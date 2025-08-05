import 'package:get/get.dart';
import '../../core/config/registration_config.dart';
import '../../core/error/registration_error.dart';

class RegistrationValidationService extends GetxService {
  bool validateEmail(String email) {
    if (email.isEmpty) {
      throw RegistrationException(RegistrationErrorType.invalidEmail);
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      throw RegistrationException(
        RegistrationErrorType.invalidEmail,
        details: 'Geçerli bir email adresi girin',
      );
    }

    return true;
  }

  bool validatePassword(String password) {
    if (password.length < RegistrationConfig.minPasswordLength) {
      throw RegistrationException(
        RegistrationErrorType.weakPassword,
        details:
            'Şifre en az ${RegistrationConfig.minPasswordLength} karakter olmalıdır',
      );
    }

    if (password.length > RegistrationConfig.maxPasswordLength) {
      throw RegistrationException(
        RegistrationErrorType.weakPassword,
        details:
            'Şifre en fazla ${RegistrationConfig.maxPasswordLength} karakter olabilir',
      );
    }

    // En az bir büyük harf
    if (!password.contains(RegExp(r'[A-Z]'))) {
      throw RegistrationException(
        RegistrationErrorType.weakPassword,
        details: 'Şifre en az bir büyük harf içermelidir',
      );
    }

    // En az bir küçük harf
    if (!password.contains(RegExp(r'[a-z]'))) {
      throw RegistrationException(
        RegistrationErrorType.weakPassword,
        details: 'Şifre en az bir küçük harf içermelidir',
      );
    }

    // En az bir rakam
    if (!password.contains(RegExp(r'[0-9]'))) {
      throw RegistrationException(
        RegistrationErrorType.weakPassword,
        details: 'Şifre en az bir rakam içermelidir',
      );
    }

    // En az bir özel karakter
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      throw RegistrationException(
        RegistrationErrorType.weakPassword,
        details: 'Şifre en az bir özel karakter içermelidir',
      );
    }

    return true;
  }

  bool validatePasswordMatch(String password, String confirmPassword) {
    if (password != confirmPassword) {
      throw RegistrationException(RegistrationErrorType.passwordMismatch);
    }
    return true;
  }

  bool validateUsername(String username) {
    if (username.isEmpty) {
      throw RegistrationException(
        RegistrationErrorType.invalidUsername,
        details: 'Kullanıcı adı boş olamaz',
      );
    }

    if (username.length > RegistrationConfig.maxUsernameLength) {
      throw RegistrationException(
        RegistrationErrorType.invalidUsername,
        details:
            'Kullanıcı adı en fazla ${RegistrationConfig.maxUsernameLength} karakter olabilir',
      );
    }

    // Sadece harf, rakam ve alt çizgi
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(username)) {
      throw RegistrationException(
        RegistrationErrorType.invalidUsername,
        details: 'Kullanıcı adı sadece harf, rakam ve alt çizgi içerebilir',
      );
    }

    return true;
  }

  bool validateLocation(Map<String, dynamic>? location) {
    if (location == null) {
      throw RegistrationException(RegistrationErrorType.invalidLocation);
    }

    final lat = location['latitude'];
    final lng = location['longitude'];

    if (lat == null || lng == null) {
      throw RegistrationException(
        RegistrationErrorType.invalidLocation,
        details: 'Eksik konum bilgisi',
      );
    }

    try {
      final latitude = double.parse(lat.toString());
      final longitude = double.parse(lng.toString());

      if (latitude < -90 || latitude > 90) {
        throw RegistrationException(
          RegistrationErrorType.invalidLocation,
          details: 'Geçersiz enlem değeri',
        );
      }

      if (longitude < -180 || longitude > 180) {
        throw RegistrationException(
          RegistrationErrorType.invalidLocation,
          details: 'Geçersiz boylam değeri',
        );
      }
    } catch (e) {
      throw RegistrationException(
        RegistrationErrorType.invalidLocation,
        details: 'Konum verisi sayısal değer olmalıdır',
      );
    }

    return true;
  }
}
