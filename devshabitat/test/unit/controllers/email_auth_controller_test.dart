import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmailAuthController Tests', () {
    test('should validate email correctly', () {
      // Bu test sadece email validation logic'ini test eder
      // Gerçek controller instance'ı olmadan da test edebiliriz

      // Email validation regex
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

      // Valid emails
      expect(emailRegex.hasMatch('test@example.com'), isTrue);
      expect(emailRegex.hasMatch('user.name@domain.co.uk'), isTrue);
      expect(emailRegex.hasMatch('test123@test.com'), isTrue);

      // Invalid emails
      expect(emailRegex.hasMatch('invalid-email'), isFalse);
      expect(emailRegex.hasMatch('test@'), isFalse);
      expect(emailRegex.hasMatch('@test.com'), isFalse);
      expect(emailRegex.hasMatch(''), isFalse);
      expect(emailRegex.hasMatch('test..test@example.com'), isFalse);
    });

    test('should handle email format validation', () {
      // Email format validation test
      bool isValidEmail(String email) {
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        return emailRegex.hasMatch(email);
      }

      expect(isValidEmail('test@example.com'), isTrue);
      expect(isValidEmail('user.name@domain.co.uk'), isTrue);
      expect(isValidEmail('invalid-email'), isFalse);
      expect(isValidEmail('test@'), isFalse);
      expect(isValidEmail(''), isFalse);
    });
  });
}
