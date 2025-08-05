import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum CommunityOperationStatus { initial, loading, success, error }

class BaseCommunityController extends GetxController {
  // Genel durum yönetimi
  final status = CommunityOperationStatus.initial.obs;
  final errorMessage = RxnString();
  final isLoading = false.obs;

  // Form durumu
  final isFormValid = false.obs;
  final isFormDirty = false.obs;

  // Yükleme durumu yönetimi
  void startLoading() {
    isLoading.value = true;
    status.value = CommunityOperationStatus.loading;
    errorMessage.value = null;
  }

  void finishLoading() {
    isLoading.value = false;
  }

  void setSuccess([String? message]) {
    status.value = CommunityOperationStatus.success;
    if (message != null) {
      showSuccessMessage(message);
    }
  }

  void setError(dynamic error) {
    status.value = CommunityOperationStatus.error;
    String message = _parseError(error);
    errorMessage.value = message;
    showErrorMessage(message);
  }

  void resetState() {
    status.value = CommunityOperationStatus.initial;
    errorMessage.value = null;
    isLoading.value = false;
  }

  // Hata mesajı yönetimi
  String _parseError(dynamic error) {
    if (error is FirebaseException) {
      return _handleFirebaseError(error);
    } else if (error is String) {
      return error;
    } else {
      return 'Beklenmeyen bir hata oluştu';
    }
  }

  String _handleFirebaseError(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Bu işlem için yetkiniz bulunmuyor';
      case 'not-found':
        return 'İstenen kaynak bulunamadı';
      case 'already-exists':
        return 'Bu kayıt zaten mevcut';
      case 'failed-precondition':
        return 'İşlem için gerekli koşullar sağlanmadı';
      case 'invalid-argument':
        return 'Geçersiz parametre';
      default:
        return error.message ?? 'Bir hata oluştu';
    }
  }

  // Mesaj gösterimi
  void showSuccessMessage(String message) {
    Get.snackbar('Başarılı', message, snackPosition: SnackPosition.BOTTOM);
  }

  void showErrorMessage(String message) {
    Get.snackbar('Hata', message, snackPosition: SnackPosition.BOTTOM);
  }

  // Form yönetimi
  void markFormDirty() {
    isFormDirty.value = true;
  }

  void resetForm() {
    isFormDirty.value = false;
    isFormValid.value = false;
  }

  // Genel try-catch wrapper
  Future<T?> handleAsync<T>({
    required Future<T> Function() operation,
    String? successMessage,
    bool showLoading = true,
    bool resetOnSuccess = true,
  }) async {
    try {
      if (showLoading) startLoading();

      final result = await operation();

      if (resetOnSuccess) resetState();
      if (successMessage != null) setSuccess(successMessage);

      return result;
    } on FirebaseException catch (e) {
      setError(e);
      return null;
    } catch (e) {
      setError(e);
      return null;
    } finally {
      if (showLoading) finishLoading();
    }
  }

  // Optimistik güncelleme yönetimi için helper
  Future<bool> optimisticUpdate<T>({
    required T oldData,
    required T newData,
    required Future<void> Function() updateOperation,
    required void Function(T) updateLocal,
    required void Function(T) revertLocal,
  }) async {
    try {
      // Optimistik güncelleme
      updateLocal(newData);

      // Backend güncelleme
      await updateOperation();

      return true;
    } catch (e) {
      // Hata durumunda geri al
      revertLocal(oldData);
      setError(e);
      return false;
    }
  }
}
