import 'dart:async';
import 'package:get/get.dart';

enum FormFieldState {
  pristine, // Hiç dokunulmamış
  touched, // Dokunulmuş ama değiştirilmemiş
  valid, // Geçerli
  invalid, // Geçersiz
  loading, // Yükleniyor
}

class FormValidationService extends GetxService {
  // Debounce süresi
  static const int _debounceMs = 800;

  // Form field state'lerini tutan map
  final _fieldStates = <String, Rx<FormFieldState>>{}.obs;

  // Field error mesajlarını tutan map
  final _fieldErrors = <String, RxString>{}.obs;

  // Debounce timer'ları
  final _debounceTimers = <String, Timer>{};

  // Field state'ini al
  FormFieldState getFieldState(String fieldId) {
    return _fieldStates[fieldId]?.value ?? FormFieldState.pristine;
  }

  // Field error mesajını al
  String? getFieldError(String fieldId) {
    return _fieldErrors[fieldId]?.value;
  }

  // Field state'ini güncelle
  void setFieldState(String fieldId, FormFieldState state) {
    if (!_fieldStates.containsKey(fieldId)) {
      _fieldStates[fieldId] = FormFieldState.pristine.obs;
    }
    _fieldStates[fieldId]!.value = state;
  }

  // Field error mesajını güncelle
  void setFieldError(String fieldId, String? error) {
    if (!_fieldErrors.containsKey(fieldId)) {
      _fieldErrors[fieldId] = RxString('');
    }
    _fieldErrors[fieldId]!.value = error ?? '';
  }

  // Field'a dokunulduğunu işaretle
  void markFieldAsTouched(String fieldId) {
    if (getFieldState(fieldId) == FormFieldState.pristine) {
      setFieldState(fieldId, FormFieldState.touched);
    }
  }

  // Debounce ile validasyon yap
  void validateFieldWithDebounce(
    String fieldId,
    String value,
    Future<String?> Function(String) validator,
  ) {
    // Önce loading state'ine geç
    setFieldState(fieldId, FormFieldState.loading);

    // Önceki timer'ı iptal et
    _debounceTimers[fieldId]?.cancel();

    // Yeni timer oluştur
    _debounceTimers[fieldId] = Timer(
      Duration(milliseconds: _debounceMs),
      () async {
        try {
          final error = await validator(value);

          if (error != null) {
            setFieldState(fieldId, FormFieldState.invalid);
            setFieldError(fieldId, error);
          } else {
            setFieldState(fieldId, FormFieldState.valid);
            setFieldError(fieldId, null);
          }
        } catch (e) {
          setFieldState(fieldId, FormFieldState.invalid);
          setFieldError(fieldId, 'Doğrulama sırasında bir hata oluştu');
        }
      },
    );
  }

  // Field'ı resetle
  void resetField(String fieldId) {
    _debounceTimers[fieldId]?.cancel();
    setFieldState(fieldId, FormFieldState.pristine);
    setFieldError(fieldId, null);
  }

  // Tüm form field'larını resetle
  void resetAllFields() {
    for (var timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    _fieldStates.clear();
    _fieldErrors.clear();
  }

  @override
  void onClose() {
    for (var timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    super.onClose();
  }
}
