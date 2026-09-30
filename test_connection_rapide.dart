// 🚀 TEST RAPIDE DE CONNEXION FLUTTER → BACKEND
// Script simple pour vérifier rapidement si tout fonctionne

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  print('🔥 TEST RAPIDE DE CONNEXION');
  print('=' * 40);
  
  // URL de votre backend
  const baseUrl = 'http://10.148.173.19:3000';
  
  // TEST 1: Ping du serveur
  print('\n📡 1. Test ping serveur...');
  try {
    final response = await http.get(Uri.parse('$baseUrl/api/flutter/test'))
        .timeout(Duration(seconds: 5));
    
    if (response.statusCode == 200) {
      print('✅ Serveur accessible !');
      print('   Status: ${response.statusCode}');
      print('   Réponse: ${response.body}');
    } else {
      print('⚠️  Serveur répond mais erreur: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Serveur non accessible: $e');
    print('💡 Vérifiez que Spring Boot fonctionne sur port 3000');
  }
  
  // TEST 2: Test authentification avec votre compte
  print('\n🔐 2. Test authentification...');
  try {
    final loginData = {
      'usernameOrEmail': 'chaimaa.rz@xtensus.com',
      'password': 'chaimaa123'
    };
    
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(loginData),
    ).timeout(Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Authentification réussie !');
      print('   User: ${data['user']['firstName']} ${data['user']['lastName']}');
      print('   Token reçu: Oui');
      
      // TEST 3: Test endpoint avec authentification
      await testAuthenticatedEndpoint(data['accessToken'], data['user']['id']);
      
    } else {
      print('❌ Échec authentification: ${response.statusCode}');
      print('   Réponse: ${response.body}');
    }
  } catch (e) {
    print('❌ Erreur authentification: $e');
  }
  
  print('\n🎉 TEST TERMINÉ !');
  print('=' * 40);
}

Future<void> testAuthenticatedEndpoint(String token, int userId) async {
  print('\n📋 3. Test endpoint protégé...');
  
  try {
    final response = await http.get(
      Uri.parse('http://10.148.173.19:3000/api/leave-requests/requester/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).timeout(Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final requests = jsonDecode(response.body);
      print('✅ Endpoint protégé accessible !');
      print('   Demandes trouvées: ${requests.length}');
    } else {
      print('⚠️  Endpoint protégé - Erreur: ${response.statusCode}');
      print('   Réponse: ${response.body}');
    }
  } catch (e) {
    print('❌ Erreur endpoint protégé: $e');
  }
}