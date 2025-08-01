import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/env.dart';

class FCMService {
  static const String _baseUrl = 'https://fcm.googleapis.com/v1/projects';

  Future<void> sendNotification({
    String? token,
    String? topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (token == null && topic == null) {
        throw Exception('Either token or topic must be provided');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/${Env.fcmProjectId}/messages:send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=${Env.fcmAccessToken}',
        },
        body: jsonEncode({
          'message': {
            if (token != null) 'token': token,
            if (topic != null) 'topic': topic,
            'notification': {
              'title': title,
              'body': body,
            },
            if (data != null) 'data': data,
            'android': {
              'priority': 'high',
              'notification': {'channel_id': 'default_channel'}
            },
            'apns': {
              'payload': {
                'aps': {'sound': 'default', 'badge': 1, 'content-available': 1}
              }
            }
          }
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('FCM isteği başarısız oldu: ${response.body}');
      }
    } catch (e) {
      print('Bildirim gönderme hatası: $e');
      rethrow;
    }
  }
}
