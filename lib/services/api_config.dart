import 'dart:io';
import 'package:http/http.dart' as http;

class ApiConfig {
  static const int port = 3000;

  /// IP Wi-Fi actuelle du PC (`ipconfig`). Pas 127.0.0.1 sur le téléphone.
  static const String currentLanHost = '10.121.135.19';

  static String? _resolvedBaseUrl;

  static List<String> get candidates {
    if (Platform.isAndroid) {
      return [
        'http://$currentLanHost:$port/api',
        'http://10.0.2.2:$port/api',
      ];
    }
    return [
      'http://$currentLanHost:$port/api',
      'http://127.0.0.1:$port/api',
      'http://localhost:$port/api',
    ];
  }

  static String get baseUrl =>
      _resolvedBaseUrl ?? 'http://$currentLanHost:$port/api';

  static Future<String> ensureReachable() async {
    if (_resolvedBaseUrl != null && !_resolvedBaseUrl!.contains('127.0.0.1')) {
      return _resolvedBaseUrl!;
    }

    final seen = <String>{};
    for (final url in candidates) {
      if (url.contains('127.0.0.1') && Platform.isAndroid) continue;
      if (!seen.add(url)) continue;
      print('🔎 Test backend $url');
      if (await _isUp(url)) {
        _resolvedBaseUrl = url;
        print('✅ Backend: $url');
        return url;
      }
    }

    _resolvedBaseUrl = 'http://$currentLanHost:$port/api';
    print('⚠️ Fallback backend $_resolvedBaseUrl');
    return _resolvedBaseUrl!;
  }

  static Future<bool> _isUp(String url) async {
    try {
      final response = await http
          .get(Uri.parse('$url/flutter/test'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200 ||
          response.statusCode == 401 ||
          response.statusCode == 403;
    } catch (_) {
      return false;
    }
  }

  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get me => '$baseUrl/auth/me';
  static String get flutterTest => '$baseUrl/flutter/test';

  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? details;

  ApiException(this.statusCode, this.message, [this.details]);

  static ApiException fromResponse(int statusCode, String? body) {
    switch (statusCode) {
      case 400:
        return ApiException(400, 'Données invalides', body);
      case 401:
        return ApiException(401, 'Token expiré, reconnexion requise');
      case 403:
        return ApiException(403, 'Accès refusé');
      case 404:
        return ApiException(404, 'Ressource non trouvée');
      case 422:
        return ApiException(422, 'Erreur de validation', body);
      case 500:
        return ApiException(500, 'Erreur serveur');
      default:
        return ApiException(statusCode, 'Erreur inconnue', body);
    }
  }

  @override
  String toString() {
    return 'ApiException: $message (Code: $statusCode)${details != null ? ' - $details' : ''}';
  }
}
