import 'package:get/get.dart';

mixin FormValidationMixin {
  final Map<String, RxString> _errors = {};
  final RxBool isFormValid = false.obs;
  final RxBool isFormDirty = false.obs;

  void markFormDirty() {
    isFormDirty.value = true;
  }

  void setError(String field, String? error) {
    if (!_errors.containsKey(field)) {
      _errors[field] = ''.obs;
    }
    _errors[field]?.value = error ?? '';
  }

  bool hasError(String field) => _errors[field]?.value.isNotEmpty ?? false;

  String? validateCategories(List<String> categories) {
    if (categories.isEmpty) {
      return 'En az bir kategori seçmelisiniz';
    }
    return null;
  }

  String sanitizeInput(String text) {
    return text
        .trim()
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'[<>&]'), '')
        .replaceAll(RegExp(r'[\n\r\t]'), ' ');
  }
}
