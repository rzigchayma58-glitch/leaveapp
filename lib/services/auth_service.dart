import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_config.dart';

class AuthService {

  // 🔐 LOGIN POUR VOTRE CAPTURE D'ÉCRAN
  static Future<Map<String, dynamic>> loginNew({
    required String email,      // chaimaa.rz@xtensus.com
    required String password,   // chaimaa123
  }) async {
    try {
      print('🔍 Connexion: $email');
      
      final requestData = {
        'usernameOrEmail': email,
        'password': password,
      };

      print('📋 Données login: $requestData');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      print('📡 Status: ${response.statusCode}');
      print('📋 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'token': data['accessToken'],
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'error': 'Email ou mot de passe incorrect',
        };
      }
    } catch (e) {
      print('❌ Erreur login: $e');
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }

  static Future<LoginResponse?> login(String emailOrUsername, String password) async {
    try {
      final base = await ApiConfig.ensureReachable();
      final response = await http.post(
        Uri.parse('$base/auth/login'),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          'usernameOrEmail': emailOrUsername,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 12));

      print('📡 Login $base => ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
        await _storeAuthData(loginResponse);
        return loginResponse;
      }

      throw ApiException(
        response.statusCode,
        response.statusCode == 401 || response.statusCode == 403
            ? 'Email ou mot de passe incorrect'
            : 'Connexion refusée (${response.statusCode})',
        response.body,
      );
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException(
        0,
        'Serveur injoignable (${ApiConfig.baseUrl}). PC et téléphone doivent être sur le même Wi-Fi.',
      );
    } on TimeoutException {
      throw ApiException(
        0,
        'Délai dépassé. L\'app n\'atteint pas ${ApiConfig.baseUrl}. PC et téléphone sur le même Wi-Fi, backend démarré.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(0, 'Erreur de connexion: $e');
    }
  }

  static Future<UserProfile?> getCurrentUser() async {
    final token = await getStoredToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/auth/me'),
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        return UserProfile.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        // Token expiré
        await logout();
        return null;
      }
    } catch (e) {
      print('Get current user error: $e');
    }
    return null;
  }

  static String toBackendRole(String role) {
    final value = role.toLowerCase().trim();
    if (value.contains('responsable') || value.contains('manager')) {
      return 'MANAGER';
    }
    return 'EMPLOYEE';
  }

  static Future<void> persistSession({
    required String token,
    required Map<String, dynamic> user,
    int expiresIn = 3600000,
    String tokenType = 'Bearer',
  }) async {
    await _storeAuthData(LoginResponse(
      accessToken: token,
      tokenType: tokenType,
      expiresIn: expiresIn,
      user: UserProfile.fromJson(user),
    ));
  }

  // 🎯 FLUTTER FIX IMMÉDIAT - REGISTER EXACTEMENT COMME VOS CAPTURES D'ÉCRAN
  static Future<Map<String, dynamic>> register({
    required String nom,        // "bb" dans votre capture
    required String prenom,     // "aa" dans votre capture  
    required String email,      // "aa.bb@xtensus.com" dans votre capture
    required String matricule,  // "77" dans votre capture
    required String departement, // "it" dans votre capture
    required String role,       // "Employé" ou "Responsable"
    required String password,   // mot de passe
    String? managerEmail,
  }) async {
    try {
      print('🔍 Création compte: $email');
      final backendRole = toBackendRole(role);
      final username = email.split('@').first;
      
      // Format EXACT pour votre backend Spring Boot
      final requestData = {
        'email': email,
        'password': password,
        'firstName': prenom,
        'lastName': nom,
        'username': username,
        'role': backendRole,
        if (matricule.isNotEmpty) 'employeeId': matricule,
        if (departement.isNotEmpty) 'department': departement,
        if (managerEmail != null && managerEmail.isNotEmpty)
          'managerEmail': managerEmail,
      };

      print('📋 Données envoyées: $requestData');

      final base = await ApiConfig.ensureReachable();
      final response = await http.post(
        Uri.parse('$base/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestData),
      ).timeout(const Duration(seconds: 12));

      print('📡 Status: ${response.statusCode}');
      print('📋 Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final user = data['user'];
        final createdRole = user is Map ? user['role'] : null;
        final ok = data['success'] == true || user != null;
        if (ok) {
          return {
            'success': true,
            'message': 'Compte créé avec succès !',
            'token': data['token'] ?? data['accessToken'],
            'user': user,
            'role': createdRole ?? backendRole,
          };
        }
        return {
          'success': false,
          'error': data['message'] ?? 'Erreur inconnue',
        };
      }

      String error = 'Erreur serveur: ${response.statusCode}';
      try {
        final data = jsonDecode(response.body);
        error = data['message']?.toString() ?? error;
      } catch (_) {}
      return {
        'success': false,
        'error': error,
      };
    } catch (e) {
      print('❌ Erreur réseau: $e');
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final base = await ApiConfig.ensureReachable();
    final paths = [
      '/auth/forgot-password',
      '/auth/password/forgot',
      '/auth/reset-password-request',
      '/users/forgot-password',
    ];
    final bodies = [
      {'email': email},
      {'usernameOrEmail': email},
    ];

    Object? lastError;
    for (final path in paths) {
      for (final body in bodies) {
        try {
          print('📤 POST $base$path $body');
          final response = await http
              .post(
                Uri.parse('$base$path'),
                headers: ApiConfig.defaultHeaders,
                body: jsonEncode(body),
              )
              .timeout(const Duration(seconds: 12));
          print('📡 Forgot $path => ${response.statusCode} ${response.body}');

          if (response.statusCode == 200 ||
              response.statusCode == 201 ||
              response.statusCode == 202 ||
              response.statusCode == 204) {
            Map<String, dynamic> data = {};
            if (response.body.isNotEmpty) {
              try {
                final decoded = jsonDecode(response.body);
                if (decoded is Map) {
                  data = Map<String, dynamic>.from(decoded);
                }
              } catch (_) {}
            }
            return {
              'success': true,
              'message': data['message']?.toString() ??
                  'Si un compte existe, un lien de réinitialisation a été envoyé.',
              'token': data['token'] ?? data['resetToken'] ?? data['code'],
              'requiresCode': data['token'] != null ||
                  data['resetToken'] != null ||
                  data['code'] != null ||
                  data['requiresCode'] == true,
            };
          }

          if (response.statusCode == 404 || response.statusCode == 401) {
            lastError = 'endpoint';
            continue;
          }

          String error = 'Impossible d\'envoyer le lien (${response.statusCode})';
          try {
            final decoded = jsonDecode(response.body);
            if (decoded is Map && decoded['message'] != null) {
              error = decoded['message'].toString();
            }
          } catch (_) {}
          return {'success': false, 'error': error};
        } on TimeoutException {
          lastError = 'timeout';
        } on SocketException {
          lastError = 'network';
        } catch (e) {
          lastError = e;
        }
      }
    }

    if (lastError == 'timeout' || lastError == 'network') {
      return {
        'success': false,
        'error': 'Serveur injoignable. Vérifiez le Wi-Fi et que le backend tourne.',
      };
    }
    return {
      'success': false,
      'error':
          'Réinitialisation non disponible sur le serveur (aucun endpoint public). Contactez un administrateur.',
    };
  }

  static Future<Map<String, dynamic>> confirmResetPassword({
    required String email,
    required String newPassword,
    String? token,
  }) async {
    final base = await ApiConfig.ensureReachable();
    final paths = [
      '/auth/reset-password',
      '/auth/password/reset',
      '/users/reset-password',
    ];
    final bodies = [
      {
        'email': email,
        'password': newPassword,
        'newPassword': newPassword,
        if (token != null && token.isNotEmpty) 'token': token,
        if (token != null && token.isNotEmpty) 'code': token,
      },
    ];

    Object? lastError;
    for (final path in paths) {
      try {
        final response = await http
            .post(
              Uri.parse('$base$path'),
              headers: ApiConfig.defaultHeaders,
              body: jsonEncode(bodies.first),
            )
            .timeout(const Duration(seconds: 12));
        print('📡 Reset $path => ${response.statusCode} ${response.body}');

        if (response.statusCode == 200 ||
            response.statusCode == 201 ||
            response.statusCode == 204) {
          return {
            'success': true,
            'message': 'Mot de passe mis à jour. Vous pouvez vous connecter.',
          };
        }
        if (response.statusCode == 404 || response.statusCode == 401) {
          lastError = 'endpoint';
          continue;
        }
        String error = 'Réinitialisation refusée (${response.statusCode})';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded['message'] != null) {
            error = decoded['message'].toString();
          }
        } catch (_) {}
        return {'success': false, 'error': error};
      } catch (e) {
        lastError = e;
      }
    }

    return {
      'success': false,
      'error': lastError == 'endpoint'
          ? 'Le serveur n\'accepte pas encore la confirmation du nouveau mot de passe.'
          : 'Erreur de connexion au serveur.',
    };
  }

  // 🎯 VERSION COMPATIBLE AVEC L'ANCIEN CODE
  static Future<bool> registerOld({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
    required String role,
    String? matricule,
    String? department,
  }) async {
    final result = await register(
      nom: lastName,
      prenom: firstName,
      email: email,
      matricule: matricule ?? '',
      departement: department ?? '',
      role: role,
      password: password,
    );
    
    return result['success'] ?? false;
  }

  // Mapping des rôles français vers anglais
  static String _mapRole(String frenchRole) {
    switch (frenchRole) {
      case 'Employé':
        return 'Employee';
      case 'Responsable':
        return 'Manager';
      default:
        return 'Employee';
    }
  }

  static Future<void> _storeAuthData(LoginResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', response.accessToken);
    await prefs.setString('token_type', response.tokenType);
    await prefs.setInt('expires_in', response.expiresIn);
    await prefs.setString('user_data', jsonEncode(response.user.toJson()));

    final expiresIn = response.expiresIn;
    final expiresDuration = expiresIn > 100000
        ? Duration(milliseconds: expiresIn)
        : Duration(seconds: expiresIn);
    final expirationTime = DateTime.now().add(expiresDuration);
    await prefs.setString('token_expiration', expirationTime.toIso8601String());
  }

  static Future<void> updateStoredUser(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  static Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<UserProfile?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    
    if (userData != null) {
      try {
        return UserProfile.fromJson(jsonDecode(userData));
      } catch (e) {
        print('Error parsing stored user: $e');
      }
    }
    return null;
  }

  static Future<bool> isLoggedIn() async {
    final token = await getStoredToken();
    return token != null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('token_type');
    await prefs.remove('expires_in');
    await prefs.remove('user_data');
    await prefs.remove('token_expiration');
  }

  // Pour la gestion des erreurs
  static String getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 401:
        return 'Email ou mot de passe incorrect';
      case 403:
        return 'Accès refusé';
      case 404:
        return 'Service non disponible';
      case 500:
        return 'Erreur serveur, veuillez réessayer';
      default:
        return 'Erreur de connexion';
    }
  }
}