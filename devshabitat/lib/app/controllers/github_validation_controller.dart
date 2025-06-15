import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GitHubValidationController extends GetxController {
  final username = ''.obs;
  final isLoading = false.obs;
  final isValid = false.obs;
  final error = RxnString();

  Future<void> validateGitHubUsername(String value) async {
    username.value = value;
    if (value.isEmpty) {
      error.value = 'GitHub kullanıcı adı boş olamaz';
      isValid.value = false;
      return;
    }

    try {
      isLoading.value = true;
      error.value = null;

      final response = await http.get(
        Uri.parse('https://api.github.com/users/$value'),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        if (userData['login'] != null) {
          isValid.value = true;
          error.value = null;
        } else {
          isValid.value = false;
          error.value = 'Geçersiz GitHub kullanıcı adı';
        }
      } else if (response.statusCode == 404) {
        isValid.value = false;
        error.value = 'GitHub kullanıcısı bulunamadı';
      } else {
        isValid.value = false;
        error.value = 'GitHub API hatası: ${response.statusCode}';
      }
    } catch (e) {
      isValid.value = false;
      error.value = 'GitHub kullanıcı adı doğrulanırken bir hata oluştu';
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    if (!isValid.value) return null;

    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse('https://api.github.com/users/${username.value}'),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
