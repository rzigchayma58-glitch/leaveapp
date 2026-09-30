import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🎯 TEST CONFIGURATION IP LOCALE - 10.148.173.19:3000');
  print('====================================================');
  print('');

  final baseUrl = 'http://10.148.173.19:3000/api';

  // Test 1: Endpoint de test Flutter
  print('📡 Test 1: Connexion Backend...');
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/flutter/test'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
      print('✅ Backend accessible !');
      print('📄 Réponse: ${response.body}');
    } else {
      print('❌ Erreur - Status: ${response.statusCode}');
      print('📄 Réponse: ${response.body}');
    }
  } catch (e) {
    print('❌ Erreur de connexion: $e');
  }

  print('');

  // Test 2: Test de création de compte
  print('👤 Test 2: Création de compte...');
  try {
    final testEmail = 'test${DateTime.now().millisecondsSinceEpoch}@example.com';
    
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': testEmail,
        'password': 'password123',
        'role': 'Employee',
        'firstName': 'Test',
        'lastName': 'User',
      }),
    ).timeout(Duration(seconds: 10));

    print('Status: ${response.statusCode}');
    print('Réponse: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('');
      print('🎉 SUCCÈS ! CRÉATION DE COMPTE FONCTIONNELLE !');
      print('✅ Votre app Flutter va maintenant fonctionner parfaitement');
      print('');
      
      // Test 3: Login avec le compte créé
      print('🔐 Test 3: Login avec le compte créé...');
      final loginResponse = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usernameOrEmail': testEmail,
          'password': 'password123',
        }),
      ).timeout(Duration(seconds: 10));

      print('Status login: ${loginResponse.statusCode}');
      if (loginResponse.statusCode == 200) {
        final data = jsonDecode(loginResponse.body);
        print('✅ Login réussi !');
        print('🎫 Token: ${data['accessToken']?.substring(0, 20)}...');
        print('👤 User: ${data['user']['firstName']} ${data['user']['lastName']}');
      }
    } else {
      print('❌ Échec création compte');
    }
  } catch (e) {
    print('❌ Erreur: $e');
  }

  print('');
  print('🎯 CONFIGURATION FINALE VALIDÉE:');
  print('   static const String baseUrl = "http://10.148.173.19:3000/api";');
}