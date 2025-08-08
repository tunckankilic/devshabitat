import 'package:logger/logger.dart';
import 'package:get/get.dart';

class LoggerService extends GetxService {
  final Logger _logger;

  LoggerService({required Logger logger}) : _logger = logger;

  void d(dynamic message) => _logger.d(message);
  void i(dynamic message) => _logger.i(message);
  void w(dynamic message) => _logger.w(message);
  void e(dynamic message) => _logger.e(message);
  void v(dynamic message) => _logger.v(message);
  void wtf(dynamic message) => _logger.wtf(message);
}
