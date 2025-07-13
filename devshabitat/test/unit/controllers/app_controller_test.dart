import 'package:flutter_test/flutter_test.dart';
import 'package:devshabitat/app/controllers/app_controller.dart';
import 'package:devshabitat/app/core/services/error_handler_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([MockSpec<ErrorHandlerService>()])
import 'app_controller_test.mocks.dart';

void main() {
  late AppController controller;
  late MockErrorHandlerService mockErrorHandler;

  setUp(() {
    mockErrorHandler = MockErrorHandlerService();
    controller = AppController(errorHandler: mockErrorHandler);
  });

  group('AppController Tests', () {
    test('initial values should be correct', () {
      expect(controller.isDarkMode, false);
      expect(controller.isOnline, true);
      expect(controller.isLoading, false);
    });

    test('toggleTheme should change theme mode', () {
      final initialTheme = controller.isDarkMode;
      controller.toggleTheme();
      expect(controller.isDarkMode, !initialTheme);
    });

    test('setLoading should update loading state', () {
      controller.setLoading(true);
      expect(controller.isLoading, true);

      controller.setLoading(false);
      expect(controller.isLoading, false);
    });

    test('handleError should call error handler service', () {
      final error = Exception('Test error');
      controller.handleError(error);
      verify(mockErrorHandler.handleError(
              error, ErrorHandlerService.SERVER_ERROR))
          .called(1);
    });

    test('resetAppState should reset all states', () {
      controller.setLoading(true);
      controller.resetAppState();
      expect(controller.isLoading, false);
    });
  });
}
