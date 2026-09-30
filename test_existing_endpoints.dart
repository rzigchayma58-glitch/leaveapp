// 🎯 TEST DES ENDPOINTS EXISTANTS DE VOTRE BACKEND
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> testExistingBackendEndpoints() async {
  print('🎯 TEST ENDPOINTS EXISTANTS - VOTRE BACKEND');
  print('=' * 50);
  
  // 1. LOGIN pour récupérer le token
  print('\n🔐 ÉTAPE 1: Login...');
  
  final loginResponse = await http.post(
    Uri.parse('http://10.186.31.19:3000/api/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'usernameOrEmail': 'aa.bb@xtensus.com',
      'password': '123456',
    }),
  );

  if (loginResponse.statusCode != 200) {
    print('❌ Login échoué: ${loginResponse.statusCode}');
    return;
  }

  final loginData = jsonDecode(loginResponse.body);
  final token = loginData['accessToken'];
  final userId = loginData['user']['id'];
  
  print('✅ Login réussi ! User ID: $userId');

  // Headers avec token
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // 2. TESTER TOUS LES ENDPOINTS POSSIBLES
  final endpointsToTest = [
    '/api/conge-types',
    '/api/conge-demandes',
    '/api/conge-requests', 
    '/api/leave-types',
    '/api/leave-requests',
    '/api/demandes',
    '/api/types-conge',
    '/api/flutter/leave-types',
    '/api/flutter/leave-requests',
  ];

  print('\n🔍 ÉTAPE 2: Test de tous les endpoints possibles...');
  
  for (final endpoint in endpointsToTest) {
    print('\n🌐 Test: http://10.186.31.19:3000$endpoint');
    
    try {
      final response = await http.get(
        Uri.parse('http://10.186.31.19:3000$endpoint'),
        headers: headers,
      ).timeout(Duration(seconds: 5));

      print('📡 Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ ENDPOINT FONCTIONNE !');
        
        try {
          final data = jsonDecode(response.body);
          if (data is List) {
            print('📊 Données: ${data.length} éléments');
            if (data.isNotEmpty) {
              print('📋 Premier élément:');
              print('   ${JsonEncoder.withIndent("   ").convert(data.first)}');
            }
          } else if (data is Map) {
            print('📋 Réponse: ${data.keys.join(", ")}');
          }
        } catch (e) {
          print('📋 Réponse (texte): ${response.body.substring(0, 100)}...');
        }
        
        // Si c'est un endpoint de types, testons la création
        if (endpoint.contains('type') && response.statusCode == 200) {
          await testCreateLeaveRequest(endpoint, token, userId);
        }
      } else {
        print('❌ Échec: ${response.body.substring(0, 50)}...');
      }
      
    } catch (e) {
      print('❌ Erreur: ${e.toString().substring(0, 50)}...');
    }
  }

  print('\n📋 ÉTAPE 3: Test structure base de données...');
  await testDatabaseStructure();
}

Future<void> testCreateLeaveRequest(String typesEndpoint, String token, int userId) async {
  print('\n✅ Test création demande avec types de: $typesEndpoint');
  
  final createEndpoint = typesEndpoint
      .replaceAll('types', 'demandes')
      .replaceAll('type', 'request');
  
  final testData = {
    'requesterId': userId,
    'employeeId': userId,
    'userId': userId,
    'leaveTypeId': 1,
    'congeTypeId': 1,
    'typeId': 1,
    'startDate': '2026-08-12',
    'endDate': '2026-08-16',
    'dateDebut': '2026-08-12',
    'dateFin': '2026-08-16',
    'reason': 'Test depuis Flutter',
    'raison': 'Test depuis Flutter',
    'motif': 'Test depuis Flutter',
  };

  try {
    final response = await http.post(
      Uri.parse('http://10.186.31.19:3000$createEndpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(testData),
    ).timeout(Duration(seconds: 10));

    print('📡 Create Status: ${response.statusCode}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ CRÉATION RÉUSSIE !');
      print('🎉 CET ENDPOINT FONCTIONNE POUR CRÉER DES DEMANDES !');
    } else {
      print('❌ Création échouée: ${response.body.substring(0, 100)}...');
    }
  } catch (e) {
    print('❌ Erreur création: ${e.toString().substring(0, 50)}...');
  }
}

Future<void> testDatabaseStructure() async {
  print('\n📋 STRUCTURE BASE ATTENDUE :');
  print('1. Table: conge_types ou leave_types');
  print('2. Table: conge_demandes ou leave_requests');
  print('3. Colonnes possibles:');
  print('   - employee_id / requester_id / user_id');
  print('   - conge_type_id / leave_type_id / type_id');
  print('   - date_debut / start_date');
  print('   - date_fin / end_date');
  print('   - raison / reason / motif');
}

Future<void> main() async {
  await testExistingBackendEndpoints();
  
  print('\n' + '=' * 50);
  print('🎯 PROCHAINES ÉTAPES :');
  print('1. Identifiez quel endpoint fonctionne pour les types');
  print('2. Identifiez quel endpoint fonctionne pour créer des demandes');
  print('3. Adaptez votre Flutter pour utiliser ces endpoints');
  print('4. Votre app pourra enregistrer les demandes ! 🎉');
}