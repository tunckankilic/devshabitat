import 'package:get/get.dart';

class ErrorHandlerService extends GetxService {
  void handleError(dynamic error) {
    // Hata yönetimi mantığı burada uygulanacak
    print('Hata: $error');
  }
}
