import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🚀 Test de connexion Backend XCongés');
  print('📍 Backend URL: http://10.0.2.2:3000');
  print('');

  // Test 1: Connexion backend
  await testConnection();
  
  // Test 2: Test de création de compte
  await testRegister();
  
  // Test 3: Test de login
  await testLogin();
}

Future<void> testConnection() async {
  print('📡 Test 1: Connexion Backend...');
  try {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/api/flutter/test'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
      print('✅ Backend connecté - Status: ${response.statusCode}');
      print('📄 Réponse: ${response.body}');
    } else {
      print('❌ Erreur connexion - Status: ${response.statusCode}');
      print('📄 Réponse: ${response.body}');
    }
  } catch (e) {
    print('❌ Erreur de connexion: $e');
    print('💡 Vérifiez que le backend est démarré sur le port 3000');
  }
  print('');
}

Future<void> testRegister() async {
  print('👤 Test 2: Création de compte...');
  try {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': 'test@example.com',
        'password': 'password123',
        'role': 'Employee',
        'firstName': 'Test',
        'lastName': 'User',
      }),
    ).timeout(Duration(seconds: 10));

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ Création de compte réussie - Status: ${response.statusCode}');
      print('📄 Réponse: ${response.body}');
    } else {
      print('❌ Erreur création compte - Status: ${response.statusCode}');
      print('📄 Réponse: ${response.body}');
    }
  } catch (e) {
    print('❌ Erreur création compte: $e');
  }
  print('');
}

Future<void> testLogin() async {
  print('🔐 Test 3: Authentification...');
  try {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usernameOrEmail': 'test@example.com',
        'password': 'password123',
      }),
    ).timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Authentification réussie');
      print('🎫 Token reçu: ${data['accessToken']?.substring(0, 20)}...');
      print('👤 Utilisateur: ${data['user']['firstName']} ${data['user']['lastName']}');
      print('🎭 Rôle: ${data['user']['role']}');
    } else {
      print('❌ Échec authentification - Status: ${response.statusCode}');
      print('📄 Réponse: ${response.body}');
    }
  } catch (e) {
    print('❌ Erreur authentification: $e');
  }
  print('');
}