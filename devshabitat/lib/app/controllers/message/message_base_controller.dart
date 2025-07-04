import 'package:get/get.dart';
import '../../services/messaging_service.dart';
import '../../core/services/error_handler_service.dart';

abstract class MessageBaseController extends GetxController {
  final MessagingService _messagingService;
  final ErrorHandlerService _errorHandler;

  final _isLoading = false.obs;
  final _lastError = ''.obs;

  bool get isLoading => _isLoading.value;
  String get lastError => _lastError.value;

  MessageBaseController({
    required MessagingService messagingService,
    required ErrorHandlerService errorHandler,
  })  : _messagingService = messagingService,
        _errorHandler = errorHandler;

  void startLoading() {
    _isLoading.value = true;
    _lastError.value = '';
  }

  void stopLoading() {
    _isLoading.value = false;
  }

  void handleError(dynamic error) {
    _lastError.value = error.toString();
    _errorHandler.handleError(error, ErrorHandlerService.SERVER_ERROR);
  }

  MessagingService get messagingService => _messagingService;
}
