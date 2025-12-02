// lib/core/network/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Pour émulateur Android
  static const String _baseUrl = 'http://10.0.2.2/api';
  // Pour émulateur iOS ou appareil physique, utilisez votre adresse IP locale
  // static const String _baseUrl = 'http://VOTRE_IP/api';

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {'success': true, 'data': responseData};
    } else {
      return {
        'success': false,
        'error': responseData['message'] ?? 'Erreur inconnue',
        'statusCode': response.statusCode,
      };
    }
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/$endpoint'),
            headers: await _getHeaders(),
            body: jsonEncode(data),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      print('Erreur API: $e');
      return {
        'success': false,
        'error':
            'Impossible de se connecter au serveur. Vérifiez votre connexion internet.',
        'details': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/$endpoint'),
            headers: await _getHeaders(),
            body: jsonEncode(data),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      print('Erreur API: $e');
      return {
        'success': false,
        'error':
            'Impossible de se connecter au serveur. Vérifiez votre connexion internet.',
        'details': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/$endpoint',
      ).replace(queryParameters: queryParameters);

      final response = await http
          .get(uri, headers: await _getHeaders())
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      print('Erreur API: $e');
      return {
        'success': false,
        'error':
            'Impossible de se connecter au serveur. Vérifiez votre connexion internet.',
        'details': e.toString(),
      };
    }
  }
}
