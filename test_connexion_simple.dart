import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 DIAGNOSTIC COMPLET - XCongés Backend');
  print('==========================================');
  print('');

  // Test des différents ports possibles
  final ports = [3000, 8080, 8081, 8082];
  
  for (final port in ports) {
    await testPort(port);
  }
  
  print('');
  print('🧪 TEST DE CRÉATION DE COMPTE');
  await testRegisterOnWorkingPort();
}

Future<void> testPort(int port) async {
  print('📡 Test port $port...');
  
  try {
    // Test 1: Endpoint de test Flutter
    final testResponse = await http.get(
      Uri.parse('http://10.0.2.2:$port/api/flutter/test'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(Duration(seconds: 5));
    
    if (testResponse.statusCode == 200) {
      print('✅ PORT $port: Backend accessible');
      print('   Response: ${testResponse.body}');
      
      // Test 2: Endpoint d'authentification
      final authResponse = await http.get(
        Uri.parse('http://10.0.2.2:$port/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 5));
      
      print('   Auth endpoint status: ${authResponse.statusCode}');
      return;
    }
  } catch (e) {
    if (e is SocketException) {
      print('❌ PORT $port: Connexion refusée');
    } else {
      print('❌ PORT $port: ${e.toString()}');
    }
  }
}

Future<void> testRegisterOnWorkingPort() async {
  final ports = [3000, 8080, 8081, 8082];
  
  for (final port in ports) {
    try {
      print('🧪 Test création compte sur port $port...');
      
      final response = await http.post(
        Uri.parse('http://10.0.2.2:$port/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'test${DateTime.now().millisecondsSinceEpoch}@example.com',
          'password': 'password123',
          'role': 'Employee',
          'firstName': 'Test',
          'lastName': 'User',
        }),
      ).timeout(Duration(seconds: 10));
      
      print('   Status: ${response.statusCode}');
      print('   Response: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ CRÉATION DE COMPTE RÉUSSIE SUR PORT $port!');
        print('');
        print('🎯 SOLUTION: Changez votre baseUrl vers:');
        print('   static const String baseUrl = "http://10.0.2.2:$port/api";');
        return;
      }
    } catch (e) {
      print('   Erreur: $e');
    }
  }
  
  print('❌ Aucun port ne fonctionne pour la création de compte');
}