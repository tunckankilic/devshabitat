import 'package:flutter_test/flutter_test.dart';
import 'responsive_test_suite.dart';

void main() {
  group('Responsive Test Suite', () {
    test('Run All Responsive Tests', () {
      ResponsiveTestSuite.runAllTests();
    });
  });
}
