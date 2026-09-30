// 🎯 TEST COMPLET DE CONNEXION FLUTTER ↔ SPRING BOOT + MYSQL
// Ce script vérifie tous les endpoints et la connectivité complète

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// 🔧 CONFIGURATION
class TestConfig {
  static const String baseUrl = 'http://10.148.173.19:3000/api';
  static const String testUrl = 'http://10.148.173.19:3000/api/flutter/test';
  
  // Données de test pour l'authentification
  static const String testEmail = 'chaimaa.rz@xtensus.com';
  static const String testPassword = 'chaimaa123';
}

// 📋 CLASSE DE TESTS
class BackendIntegrationTest {
  String? authToken;
  int? userId;
  
  // 🎯 LANCER TOUS LES TESTS
  Future<void> runAllTests() async {
    print('🔥 DÉMARRAGE DES TESTS DE CONNEXION FLUTTER ↔ BACKEND');
    print('=' * 60);
    
    await testBasicConnectivity();
    await testAuthentication();
    await testLeaveTypes();
    await testLeaveRequests();
    await testLeaveBalance();
    await testManagerEndpoints();
    
    print('\n🎉 TESTS TERMINÉS !');
    print('=' * 60);
  }
  
  // TEST 1: Connectivité de base
  Future<void> testBasicConnectivity() async {
    print('\n📡 TEST 1: Connectivité de base');
    print('-' * 30);
    
    try {
      // Test ping backend
      final response = await http.get(Uri.parse(TestConfig.testUrl))
          .timeout(Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        print('✅ Backend accessible (${response.statusCode})');
        print('   Réponse: ${response.body}');
      } else {
        print('❌ Backend non accessible (${response.statusCode})');
      }
    } catch (e) {
      print('❌ Erreur de connexion: $e');
      print('💡 Vérifiez que le backend Spring Boot fonctionne sur 10.148.173.19:3000');
    }
  }
  
  // TEST 2: Authentification
  Future<void> testAuthentication() async {
    print('\n🔐 TEST 2: Authentification');
    print('-' * 30);
    
    try {
      // Test login
      final loginData = {
        'usernameOrEmail': TestConfig.testEmail,
        'password': TestConfig.testPassword,
      };
      
      final response = await http.post(
        Uri.parse('${TestConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginData),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        authToken = data['accessToken'];
        userId = data['user']['id'];
        
        print('✅ Authentification réussie');
        print('   Token obtenu: ${authToken?.substring(0, 20)}...');
        print('   User ID: $userId');
      } else {
        print('❌ Échec authentification (${response.statusCode})');
        print('   Réponse: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur authentification: $e');
    }
  }
  
  // TEST 3: Types de congé
  Future<void> testLeaveTypes() async {
    print('\n📋 TEST 3: Types de congé');
    print('-' * 30);
    
    if (authToken == null) {
      print('❌ Pas de token d\'authentification');
      return;
    }
    
    // Tester plusieurs endpoints possibles
    final endpoints = [
      '/conge-types',
      '/leave-types', 
      '/leave-types/all'
    ];
    
    for (String endpoint in endpoints) {
      try {
        print('   Testant: ${TestConfig.baseUrl}$endpoint');
        
        final response = await http.get(
          Uri.parse('${TestConfig.baseUrl}$endpoint'),
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ).timeout(Duration(seconds: 10));
        
        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          print('✅ Types de congé récupérés depuis $endpoint');
          print('   Nombre de types: ${data.length}');
          
          if (data.isNotEmpty) {
            print('   Exemple: ${data[0]}');
          }
          break; // Sortir de la boucle si succès
        } else {
          print('❌ Échec $endpoint (${response.statusCode})');
        }
      } catch (e) {
        print('❌ Erreur $endpoint: $e');
      }
    }
  }
  
  // TEST 4: Demandes de congé
  Future<void> testLeaveRequests() async {
    print('\n📝 TEST 4: Demandes de congé');
    print('-' * 30);
    
    if (authToken == null || userId == null) {
      print('❌ Pas d\'authentification ou d\'user ID');
      return;
    }
    
    try {
      // Test GET - Récupérer les demandes de l'utilisateur
      final getResponse = await http.get(
        Uri.parse('${TestConfig.baseUrl}/leave-requests/requester/$userId'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));
      
      if (getResponse.statusCode == 200) {
        final requests = jsonDecode(utf8.decode(getResponse.bodyBytes));
        print('✅ Demandes récupérées');
        print('   Nombre de demandes: ${requests.length}');
        
        if (requests.isNotEmpty) {
          print('   Exemple: ${requests[0]}');
        }
      } else {
        print('❌ Échec récupération demandes (${getResponse.statusCode})');
        print('   Réponse: ${getResponse.body}');
      }
      
      // Test POST - Créer une demande de test
      await testCreateLeaveRequest();
      
    } catch (e) {
      print('❌ Erreur demandes: $e');
    }
  }
  
  // TEST 4b: Création d'une demande
  Future<void> testCreateLeaveRequest() async {
    print('\n   📝 TEST 4b: Création de demande');
    
    try {
      final tomorrow = DateTime.now().add(Duration(days: 7));
      final dayAfter = tomorrow.add(Duration(days: 1));
      
      final requestData = {
        'requesterId': userId,
        'leaveTypeId': 1, // ID par défaut, peut nécessiter ajustement
        'startDate': _formatDate(tomorrow),
        'endDate': _formatDate(dayAfter),
        'reason': 'Test automatique Flutter - ${DateTime.now()}',
      };
      
      final response = await http.post(
        Uri.parse('${TestConfig.baseUrl}/leave-requests'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        print('✅ Demande créée avec succès');
        print('   ID de la demande: ${responseData['id'] ?? 'N/A'}');
      } else {
        print('❌ Échec création demande (${response.statusCode})');
        print('   Réponse: ${response.body}');
        print('   Données envoyées: $requestData');
      }
    } catch (e) {
      print('❌ Erreur création demande: $e');
    }
  }
  
  // TEST 5: Solde de congés
  Future<void> testLeaveBalance() async {
    print('\n💰 TEST 5: Solde de congés');
    print('-' * 30);
    
    if (authToken == null || userId == null) {
      print('❌ Pas d\'authentification ou d\'user ID');
      return;
    }
    
    try {
      final response = await http.get(
        Uri.parse('${TestConfig.baseUrl}/leave-balances/user/$userId'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final balances = jsonDecode(utf8.decode(response.bodyBytes));
        print('✅ Soldes récupérés');
        print('   Nombre de types: ${balances.length}');
        
        if (balances.isNotEmpty) {
          for (var balance in balances) {
            print('   ${balance['leaveTypeName'] ?? 'Inconnu'}: ${balance['remainingDays'] ?? 0} jours restants');
          }
        }
      } else {
        print('❌ Échec récupération soldes (${response.statusCode})');
        print('   Réponse: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur soldes: $e');
    }
  }
  
  // TEST 6: Endpoints Manager
  Future<void> testManagerEndpoints() async {
    print('\n👨‍💼 TEST 6: Endpoints Manager');
    print('-' * 30);
    
    if (authToken == null || userId == null) {
      print('❌ Pas d\'authentification ou d\'user ID');
      return;
    }
    
    try {
      // Test récupération demandes équipe
      final response = await http.get(
        Uri.parse('${TestConfig.baseUrl}/leave-requests/approver/$userId'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final teamRequests = jsonDecode(utf8.decode(response.bodyBytes));
        print('✅ Demandes équipe récupérées');
        print('   Nombre de demandes: ${teamRequests.length}');
        
        if (teamRequests.isNotEmpty) {
          print('   Exemple: ${teamRequests[0]}');
        }
      } else {
        print('❌ Échec récupération demandes équipe (${response.statusCode})');
        print('   Réponse: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur endpoints manager: $e');
    }
  }
  
  // Utilitaire pour formater les dates
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// 🎯 FONCTION PRINCIPALE POUR LANCER LES TESTS
Future<void> main() async {
  print('🚀 SCRIPT DE TEST COMPLET FLUTTER ↔ SPRING BOOT + MYSQL');
  print('📍 Backend URL: ${TestConfig.baseUrl}');
  print('👤 Compte de test: ${TestConfig.testEmail}');
  
  final tester = BackendIntegrationTest();
  await tester.runAllTests();
  
  // Résumé final
  print('\n📊 RÉSUMÉ DES TESTS:');
  print('✅ Si tous les tests passent → Flutter est connecté au backend');
  print('❌ Si des tests échouent → Vérifiez les endpoints Spring Boot');
  print('💡 Consultez les logs du backend pour plus de détails');
  
  exit(0);
}

// 🎯 UTILISATION:
// 1. Sauvegardez ce fichier comme test_backend_integration_complete.dart
// 2. Exécutez: dart test_backend_integration_complete.dart
// 3. Observez les résultats pour identifier les problèmes