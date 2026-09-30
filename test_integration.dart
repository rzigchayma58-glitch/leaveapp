#!/usr/bin/env dart

// Script de test d'intégration Flutter XCongés ↔ Backend Spring Boot
// Usage: dart test_integration.dart

import 'dart:io';
import 'dart:convert';

void main() async {
  print('🚀 Test d\'intégration Flutter XCongés ↔ Backend Spring Boot PORT 8082');
  print('=' * 70);
  
  await testBackendConnection();
  await testFlutterEndpoint();
  await testAuthentication();
  await testLeaveRequests();
  
  print('\n✅ Tests d\'intégration terminés !');
}

Future<void> testBackendConnection() async {
  print('\n📡 Test de connexion au backend PORT 8082...');
  
  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('http://localhost:8082/api/auth/me'));
    request.headers.set('Content-Type', 'application/json');
    
    final response = await request.close();
    
    if (response.statusCode == 401) {
      print('✅ Backend Spring Boot accessible sur PORT 8082 (401 - non authentifié attendu)');
    } else {
      print('⚠️  Backend répond avec code: ${response.statusCode}');
    }
    
    client.close();
  } catch (e) {
    print('❌ Erreur de connexion backend PORT 8082: $e');
    print('💡 Vérifiez que le backend Spring Boot tourne sur localhost:8082');
  }
}

Future<void> testFlutterEndpoint() async {
  print('\n🔥 Test endpoint Flutter spécial /api/flutter/test...');
  
  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('http://localhost:8082/api/flutter/test'));
    request.headers.set('Content-Type', 'application/json');
    
    final response = await request.close();
    
    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      print('✅ Endpoint Flutter TEST accessible: $responseBody');
    } else {
      print('⚠️  Endpoint Flutter TEST code: ${response.statusCode}');
    }
    
    client.close();
  } catch (e) {
    print('❌ Erreur test endpoint Flutter: $e');
  }
}

Future<void> testAuthentication() async {
  print('\n🔐 Test d\'authentification sur PORT 8082...');
  
  try {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse('http://localhost:8082/api/auth/login'));
    request.headers.set('Content-Type', 'application/json');
    
    final loginData = {
      'usernameOrEmail': 'test@example.com',
      'password': 'password123'
    };
    
    request.add(utf8.encode(jsonEncode(loginData)));
    final response = await request.close();
    
    if (response.statusCode == 200) {
      print('✅ Format de requête login correct');
      
      final responseBody = await response.transform(utf8.decoder).join();
      final data = jsonDecode(responseBody);
      
      if (data.containsKey('accessToken') && data.containsKey('user')) {
        print('✅ Format de réponse login correct');
      } else {
        print('⚠️  Format de réponse inattendu: $data');
      }
    } else {
      print('⚠️  Login failed (${response.statusCode}) - normal si utilisateur test n\'existe pas');
    }
    
    client.close();
  } catch (e) {
    print('❌ Erreur test authentification: $e');
  }
}

Future<void> testLeaveRequests() async {
  print('\n📝 Test des demandes de congé sur PORT 8082...');
  
  try {
    final client = HttpClient();
    
    // Test GET sans authentification (doit retourner 401)
    final request = await client.getUrl(Uri.parse('http://localhost:8082/api/leave-requests/requester/1'));
    request.headers.set('Content-Type', 'application/json');
    
    final response = await request.close();
    
    if (response.statusCode == 401) {
      print('✅ Endpoint leave-requests protégé correctement sur PORT 8082');
    } else {
      print('⚠️  Endpoint leave-requests code: ${response.statusCode}');
    }
    
    client.close();
  } catch (e) {
    print('❌ Erreur test leave requests: $e');
  }
}